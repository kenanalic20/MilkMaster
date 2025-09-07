using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
using MilkMaster.Infrastructure.Repositories;
using MilkMaster.Messages;

namespace MilkMaster.Infrastructure.Services
{
    public class OrderItemsService : BaseService<OrderItems, OrderItemsDto, OrderItemsCreateDto, OrderItemsUpdateDto, OrderItemsQueryFilter, int>, IOrderItemsService
    {
        private readonly IOrderItemsRepository _orderItemsRepository;
        private readonly IOrdersService _ordersService;
        private readonly IAuthService _authService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IEmailService _emailService;
        public OrderItemsService(
            IOrderItemsRepository orderItemsRepository,
            IAuthService authService,
            IOrdersService ordersService,
            IHttpContextAccessor httpContextAccessor,
            IMapper mapper,
            IEmailService emailService
        ) : base(orderItemsRepository, mapper)
        {
            _orderItemsRepository = orderItemsRepository;
            _authService = authService;
            _httpContextAccessor = httpContextAccessor;
            _emailService = emailService;
            _ordersService = ordersService;
        }
        protected override async Task AfterGetAsync(OrderItems entity)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }

        protected override async Task BeforeUpdateAsync(OrderItems entity, OrderItemsUpdateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            entity.TotalPrice = dto.Quantity * dto.UnitSize * dto.PricePerUnit;
        }
        protected override async Task AfterUpdateAsync(OrderItems entity, OrderItemsUpdateDto dto)
        {
            await _ordersService.RecalculateOrderTotalAsync(entity.OrderId);
            var order = await _ordersService.GetByIdAsync(entity.OrderId);

            var userClaim = _httpContextAccessor.HttpContext?.User!;
            var user = await _authService.GetUserAsync(userClaim);
            var email = new EmailMessage
            {
                Email = user.Email,
                Subject = $"Order Item Updated",
                Body = $"Your order item for order : {order.OrderNumber} is updated!\n\n" +
                $"Total: {order.Total}. \n" +
                $"We will notify you of any updates regarding your order.\n\n" +
                $"If you have any questions, feel free to contact us at any time."
            };
            await _emailService.SendEmailAsync(user.Id, email);
        }

        protected override async Task BeforeCreateAsync(OrderItems entity, OrderItemsCreateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

        }
        protected override async Task BeforeDeleteAsync(OrderItems entity)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }
        protected override async Task AfterDeleteAsync(OrderItems entity)
        {
            await _ordersService.RecalculateOrderTotalAsync(entity.OrderId);
        }

        protected override IQueryable<OrderItems> ApplyFilter(IQueryable<OrderItems> query, OrderItemsQueryFilter? filter)
        {
            query = query.Include(o => o.Order);

            if (filter == null)
            {
                return query;
            }

            if (filter.OrderId > 0)
            {
                query = query.Where(x => x.OrderId == filter.OrderId);
            }

            return query;
        }

        public async Task<int> GetTotalSoldProductsCountAsync()
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            return await _orderItemsRepository.AsQueryable()
                .Include(o => o.Order)
                .Where(o => o.Order.Status.Name == "Completed")
                .SumAsync(oi => oi.Quantity);
        }
    }
}
