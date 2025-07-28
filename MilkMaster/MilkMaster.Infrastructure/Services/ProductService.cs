using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Exceptions;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Services
{
    public class ProductService : BaseService<Products, ProductsDto, ProductsCreateDto, ProductsUpdateDto, ProductQueryFilter, int>, IProductsService
    {
        private readonly IProductsRepository _productRepository;
        private readonly IOrdersRepository _ordersRepository;
        private readonly IAuthService _authService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public ProductService(
            IProductsRepository productRepository,
            IOrdersRepository ordersRepository,
            IMapper mapper,
            IAuthService authService,
            IHttpContextAccessor httpContextAccessor
            )
            : base(productRepository, mapper)
        {
            _productRepository = productRepository;
            _ordersRepository = ordersRepository;
            _authService = authService;
            _httpContextAccessor = httpContextAccessor;
        }

        protected override async Task BeforeUpdateAsync(Products entity, ProductsUpdateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            if (string.IsNullOrEmpty(dto.ImageUrl))
                throw new MilkMasterValidationException("Image URL cannot be empty.");

            if (string.IsNullOrEmpty(dto.Title))
                throw new MilkMasterValidationException("Product name cannot be empty.");


            if (dto.Nutrition != null)
            {
                if (entity.Nutrition == null)
                    entity.Nutrition = _mapper.Map<Nutritions>(dto.Nutrition);
                else
                    _mapper.Map(dto.Nutrition, entity.Nutrition);
            }
        }
        protected override async Task AfterUpdateAsync(Products entity, ProductsUpdateDto dto)
        {
            await _productRepository.RecalculateCategoryCountsAsync();
        }
        protected override async Task BeforeCreateAsync(Products entity, ProductsCreateDto dto)
        {
            if (_isSeeding)
                return;

            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            if (string.IsNullOrEmpty(dto.ImageUrl))
                throw new MilkMasterValidationException("Image URL cannot be empty.");

            if (string.IsNullOrEmpty(dto.Title))
                throw new MilkMasterValidationException("Product name cannot be empty.");


            if (dto.Nutrition != null)
            {
                entity.Nutrition = _mapper.Map<Nutritions>(dto.Nutrition);
            }
        }
        protected override async Task AfterCreateAsync(Products entity, ProductsCreateDto dto)
        {
            await _productRepository.RecalculateCategoryCountsAsync();
        }

        protected override async Task BeforeDeleteAsync(Products entity)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }
        protected override async Task AfterDeleteAsync(Products entity)
        {
            await _productRepository.RecalculateCategoryCountsAsync();
        }
        protected override IQueryable<Products> ApplyFilter(IQueryable<Products> query, ProductQueryFilter? filter)
        {
            query = query.Include(p => p.ProductCategories)
                            .ThenInclude(pc => pc.ProductCategory)
                        .Include(p => p.CattleCategory).
                        Include(p => p.Unit);

            if (filter == null)
                return query;

            if (!string.IsNullOrWhiteSpace(filter.Title))
                query = query.Where(p => p.Title.ToLower().Contains(filter.Title.ToLower()));

            if (filter.ProductCategoryId.HasValue)
                query = query.Where(p => p.ProductCategories.Any(pc => pc.ProductCategoryId == filter.ProductCategoryId));

            if (filter.CattleCategoryId.HasValue)
                query = query.Where(p => p.CattleCategoryId == filter.CattleCategoryId);

            query = filter.SortDescending
                ? query.OrderByDescending(p => p.CreatedAt)
                : query.OrderBy(p => p.CreatedAt);

            return query;
        }

        static object isLocked = new object();
        static MLContext mlContext = null;
        static ITransformer model = null;

        public async Task<List<ProductsDto>> Recommand(int id)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var realUserId = await _authService.GetUserIdAsync(user);
            var numericUserId = MapUserId(realUserId); // convert to uint

            lock (isLocked)
            {
                if (mlContext == null)
                {
                    mlContext = new MLContext();

                    var orders = _ordersRepository.AsQueryable().Include(o => o.Items).ToList();
                    var ratings = new List<ProductEntry>();

                    foreach (var order in orders)
                    {
                        if (order.UserId == null) continue;

                        var mappedUserId = MapUserId(order.UserId); // convert to uint

                        foreach (var item in order.Items)
                        {
                            ratings.Add(new ProductEntry
                            {
                                UserId = mappedUserId,
                                ProductId = (uint)item.ProductId,
                                Label = 1f
                            });
                        }
                    }

                    var traindata = mlContext.Data.LoadFromEnumerable(ratings);

                    var options = new MatrixFactorizationTrainer.Options
                    {
                        MatrixColumnIndexColumnName = nameof(ProductEntry.UserId),
                        MatrixRowIndexColumnName = nameof(ProductEntry.ProductId),
                        LabelColumnName = nameof(ProductEntry.Label),
                        LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                        Alpha = 0.01,
                        Lambda = 0.025,
                        NumberOfIterations = 100,
                        C = 0.00001
                    };

                    var estimator = mlContext.Recommendation().Trainers.MatrixFactorization(options);
                    model = estimator.Fit(traindata);
                }
            }

            var allProducts = _productRepository.AsQueryable().ToList();
            var predictionResults = new List<(Products, float)>();

            foreach (var product in allProducts)
            {
                var predictionEngine = mlContext.Model.CreatePredictionEngine<ProductEntry, ProductScore>(model);

                var prediction = predictionEngine.Predict(new ProductEntry
                {
                    UserId = (uint)numericUserId,
                    ProductId = (uint)product.Id
                });

                predictionResults.Add((product, prediction.Score));
            }

            var finalResults = predictionResults
                .OrderByDescending(x => x.Item2)
                .Take(5)
                .Select(x => _mapper.Map<ProductsDto>(x.Item1))
                .ToList();

            return finalResults;
        }

        static Dictionary<string, uint> _userIdMap = new();
        static uint _userCounter = 0;

        private static uint MapUserId(string userId)
        {
            if (!_userIdMap.TryGetValue(userId, out var mappedId))
            {
                mappedId = _userCounter++;
                _userIdMap[userId] = mappedId;
            }
            return mappedId;
        }

    }
    public class ProductScore
    {
        public float Score { get; set; }
    }
    public class ProductEntry 
    {
        [KeyType(count: 10)] 
        public uint UserId { get; set; }
        [KeyType(count:10)]
        public uint ProductId { get; set; }
        public float Label { get; set; }
    }
}
