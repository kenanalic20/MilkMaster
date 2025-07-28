using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Exceptions;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
using MilkMaster.Messages;

namespace MilkMaster.Infrastructure.Services
{
    public class OrdersService : BaseService<Orders, OrdersDto, OrdersCreateDto, OrdersUpdateDto, OrderQueryFilter, int>, IOrdersService
    {
        private readonly IOrdersRepository _orderRepository;
        private readonly IProductsRepository _productRepository;
        private readonly IUserDetailsRepository _userDetailsRepository;
        private readonly IAuthService _authService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IEmailService _emailService;
        public OrdersService(
            IOrdersRepository orderRepository,
            IProductsRepository productRepository,
            IUserDetailsRepository userDetailsRepository,
            IMapper mapper,
            IAuthService authService,
            IHttpContextAccessor httpContextAccessor,
            IEmailService emailService
            )
            : base(orderRepository, mapper)
        {
            _orderRepository = orderRepository;
            _productRepository = productRepository;
            _userDetailsRepository = userDetailsRepository;
            _authService = authService;
            _httpContextAccessor = httpContextAccessor;
            _emailService = emailService;
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

        protected override async Task AfterUpdateAsync(Orders entity, OrdersUpdateDto dto)
        {
            var email = new EmailMessage
            {
                Email = entity.Email,
                Subject = $"Order: {entity.OrderNumber} updated",
                Body = $"Your order is updated!\n\n" +
                $"Order Number: {entity.OrderNumber}.\n" +
                $"Status: {entity.Status?.Name}.\n\n" +
                $"We will notify you of any updates regarding your order.\n\n" +
                $"If you have any questions, feel free to contact us at any time."
            };

            await _emailService.SendEmailAsync(entity.UserId, email);
        }

        protected override async Task BeforeCreateAsync(Orders entity, OrdersCreateDto dto)
        {
            if (_isSeeding)
                return;

            var userClaim = _httpContextAccessor.HttpContext?.User;

            if (userClaim == null)
                throw new UnauthorizedAccessException("User is not authenticated.");

            var user =await _authService.GetUserAsync(userClaim);
            var userName = user.UserName;
            var userId = user.Id;
            var userEmail = user.Email;
            var userPhone = user.PhoneNumber;

            if (string.IsNullOrEmpty(userName) || string.IsNullOrEmpty(userEmail) || string.IsNullOrEmpty(userId))
                throw new UnauthorizedAccessException("User is not authenticated.");

            var userDetails = await _userDetailsRepository.GetByIdAsync(userId);
            
            if (userDetails == null || (string.IsNullOrEmpty(userDetails.FirstName) && string.IsNullOrEmpty(userDetails.LastName)))
                entity.Customer = userName;
            else
                entity.Customer = $"{userDetails.FirstName} {userDetails.LastName}".Trim();

            entity.UserId = userId;

            entity.Email = userEmail;

            entity.PhoneNumber = string.IsNullOrEmpty(userPhone) ? "Phone number not set" : userPhone;

            entity.OrderNumber = await GenerateOrderNumberAsync();

            var originalQuantities = new Dictionary<int, int>();

            try
            {
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

                    if (!originalQuantities.ContainsKey(product.Id))
                    {
                        originalQuantities[product.Id] = product.Quantity;
                    }

                    var orderItem = new OrderItems
                    {
                        ProductId = product.Id,
                        Quantity = item.Quantity,
                        UnitSize = item.UnitSize,
                        PricePerUnit = product.PricePerUnit,
                        TotalPrice = item.Quantity * product.PricePerUnit * item.UnitSize,
                    };

                    entity.Items.Add(orderItem);

                    product.Quantity -= item.Quantity;
                    await _productRepository.UpdateAsync(product);
                }

                entity.ItemCount = entity.Items.Count;
                entity.Total = entity.Items.Sum(i => i.TotalPrice);
            }
            catch (Exception ex)
            {
                foreach (var kvp in originalQuantities)
                {
                    var product = await _productRepository.GetByIdAsync(kvp.Key);
                    if (product != null)
                    {
                        product.Quantity = kvp.Value;
                        await _productRepository.UpdateAsync(product);
                    }
                }
                throw new MilkMasterValidationException($"Quantity limit exceeded!");

            }
        }

        protected override async Task AfterCreateAsync(Orders entity, OrdersCreateDto dto) 
        {
            if (_isSeeding)
                return;
            var orderWithStatus = await _orderRepository.AsQueryable()
                .Include(o => o.Status)
                .FirstOrDefaultAsync(o => o.Id == entity.Id);

            var email = new EmailMessage
            {
                Email = entity.Email,
                Subject = $"Order: {entity.OrderNumber} created",
                Body = $"Thank you for your order!\n\n" +
               $"Order Number: {entity.OrderNumber}.\n" +
               $"Status: {orderWithStatus.Status.Name}.\n\n" +
               $"We will notify you of any updates regarding your order.\n\n" +
               $"If you have any questions, feel free to contact us at any time."
            };

            await _emailService.SendEmailAsync(entity.UserId, email);

        }

        protected override async Task BeforeDeleteAsync(Orders entity)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
            
            foreach (var item in entity.Items) 
            {
                var product = await _productRepository.GetByIdAsync(item.ProductId);

                if(product == null)
                    throw new KeyNotFoundException($"Product with ID {item.ProductId} not found.");

                product.Quantity += item.Quantity;
                await _productRepository.UpdateAsync(product);
            }
        }
        protected override async Task AfterDeleteAsync(Orders entity)
        {
            var email = new EmailMessage
            {
                Email = entity.Email,
                Subject = $"Order: {entity.OrderNumber} removed",
                Body = $"Your order is permenantly removed!\n\n" +
               $"Order Number: {entity.OrderNumber}.\n" +
               $"We will notify you of any updates regarding your order.\n\n" +
               $"If you have any questions, feel free to contact us at any time."
            };

            await _emailService.SendEmailAsync(entity.UserId, email);
        }


        protected override IQueryable<Orders> ApplyFilter(IQueryable<Orders> query, OrderQueryFilter? filter)
        {
            query = query.Include(o => o.Items)
                         .ThenInclude(i => i.Product)
                         .ThenInclude(p => p.Unit)
                         .Include(s => s.Status);

            if(filter == null)
                return query;
            if (!string.IsNullOrEmpty(filter.OrderNumber))
                query = query.Where(o => o.OrderNumber.Contains(filter.OrderNumber));

            if (!string.IsNullOrEmpty(filter.Customer))
                query = query.Where(o => o.Customer.Contains(filter.Customer));

            if (!string.IsNullOrEmpty(filter.OrderStatus))
                query = query.Where(o => o.Status.Name == filter.OrderStatus);

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                switch (filter.OrderBy.ToLower())
                {
                    case "date_asc":
                        query = query.OrderBy(o => o.CreatedAt);
                        break;
                    case "date_desc":
                        query = query.OrderByDescending(o => o.CreatedAt);
                        break;
                    case "total_asc":
                        query = query.OrderBy(o => o.Total);
                        break;
                    case "total_desc":
                        query = query.OrderByDescending(o => o.Total);
                        break;
                    case "itemscount_asc":
                        query = query.OrderBy(o => o.ItemCount);
                        break;
                    case "itemscount_desc":
                        query = query.OrderByDescending(o => o.ItemCount);
                        break;
                }
            }
            return query;
        }

        public async Task RecalculateOrderTotalAsync(int orderId)
        {
            var order = await _orderRepository.AsQueryable()
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order != null)
            {
                order.Total = order.Items.Sum(i => i.TotalPrice);
                order.ItemCount = order.Items.Count;
                await _orderRepository.UpdateAsync(order);
            }
        }

        public async Task<string> GenerateOrderNumberAsync()
        {
            var lastOrder = await _orderRepository.AsQueryable()
                .OrderByDescending(o => o.Id)
                .FirstOrDefaultAsync();

            var nextNumber = (lastOrder?.Id ?? 0) + 1;

            return $"#{nextNumber.ToString("D4")}";
        }
    }
}
