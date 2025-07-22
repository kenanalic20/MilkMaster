using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Exceptions;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
using System.Security.Claims;

namespace MilkMaster.Infrastructure.Services
{
    public class OrdersService : BaseService<Orders, OrdersDto, OrdersCreateDto, OrdersUpdateDto, OrderQueryFilter, int>, IOrdersService
    {
        private readonly IOrdersRepository _orderRepository;
        private readonly IProductsRepository _productRepository;
        private readonly IAuthService _authService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public OrdersService(
            IOrdersRepository orderRepository,
            IProductsRepository productRepository,
            IMapper mapper,
            IAuthService authService,
            IHttpContextAccessor httpContextAccessor
            )
            : base(orderRepository, mapper)
        {
            _orderRepository = orderRepository;
            _productRepository = productRepository;
            _authService = authService;
            _httpContextAccessor = httpContextAccessor;
        }
        protected override async Task AfterGetAsync(Orders entity)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }
        protected override async Task BeforePagedAsync(IQueryable<Orders> query)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }

        protected override async Task BeforeUpdateAsync(Orders entity, OrdersUpdateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }
        protected override async Task BeforeCreateAsync(Orders entity, OrdersCreateDto dto)
        {
            var userName = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.Name)?.Value;
            if (string.IsNullOrEmpty(userName))
                throw new UnauthorizedAccessException("User is not authenticated.");

            entity.Username = userName;
            entity.OrderNumber = await GenerateOrderNumberAsync();

            foreach (var item in dto.Items)
            {
                var product = await _productRepository.GetByIdAsync(item.ProductId);
                if (product == null)
                    throw new KeyNotFoundException("Product not found");

                if (item.Quantity <= 0)
                    throw new MilkMasterValidationException("Quantity must be greater than zero.");

                if (item.Quantity > product.Quantity)
                    throw new MilkMasterValidationException($"Product '{product.Title}' out of stock");

                if (item.UnitSize <= 0)
                    throw new MilkMasterValidationException("Unit size must be greater than zero.");


                var orderItem = new OrderItems
                {
                    ProductId = product.Id,
                    Quantity = item.Quantity,
                    UnitSize = item.UnitSize,
                    PricePerUnit = product.PricePerUnit,
                    TotalPrice = item.Quantity * product.PricePerUnit * item.UnitSize,
                };

                entity.Items.Add(orderItem);

                try
                {
                    product.Quantity -= item.Quantity;
                    await _productRepository.UpdateAsync(product);

                }
                catch (DbUpdateConcurrencyException)
                {
                    throw new MilkMasterValidationException($"Product '{product.Title}' is out of stock or has been updated by another user.");
                }
            }

            entity.Total = entity.Items.Sum(i => i.TotalPrice);
        }
        protected override async Task BeforeDeleteAsync(Orders entity)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }
        protected override IQueryable<Orders> ApplyFilter(IQueryable<Orders> query, OrderQueryFilter? filter)
        {
            query = query.Include(o => o.Items)
                         .ThenInclude(i => i.Product)
                         .ThenInclude(p => p.Unit);

            return query;
        }

        private async Task<string> GenerateOrderNumberAsync()
        {
            var lastOrder = await _orderRepository.AsQueryable()
                .OrderByDescending(o => o.Id)
                .FirstOrDefaultAsync();

            var nextNumber = (lastOrder?.Id ?? 0) + 1;

            return $"#{nextNumber.ToString("D4")}";
        }
    }
}
