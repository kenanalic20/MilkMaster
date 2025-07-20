using AutoMapper;
using Microsoft.AspNetCore.Http;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Services
{
    public class OrderItemsService : BaseService<OrderItems, OrderItemsDto, OrderItemsCreateDto, OrderItemsUpdateDto, OrderItemsQueryFilter, int>, IOrderItemsService
    {
        private readonly IOrderItemsRepository _orderItemsRepository;
        private readonly IAuthService _authService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public OrderItemsService(
            IOrderItemsRepository orderItemsRepository,
            IAuthService authService,
            IHttpContextAccessor httpContextAccessor,
            IMapper mapper
        ) : base(orderItemsRepository, mapper)
        {
            _orderItemsRepository = orderItemsRepository;
            _authService = authService;
            _httpContextAccessor = httpContextAccessor;
        }
        protected override IQueryable<OrderItems> ApplyFilter(IQueryable<OrderItems> query, OrderItemsQueryFilter? filter)
        {

            return query;
        }
    }
}
