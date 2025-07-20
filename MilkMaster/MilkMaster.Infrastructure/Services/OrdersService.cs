using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Services
{
    public class OrdersService : BaseService<Orders, OrdersDto, OrdersCreateDto, OrdersUpdateDto, OrderQueryFilter, int>, IOrdersService
    {
        private readonly IOrdersRepository _orderRepository;
        private readonly IAuthService _authService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public OrdersService(
            IOrdersRepository orderRepository,
            IMapper mapper,
            IAuthService authService,
            IHttpContextAccessor httpContextAccessor
            )
            : base(orderRepository, mapper)
        {
            _orderRepository = orderRepository;
            _authService = authService;
            _httpContextAccessor = httpContextAccessor;
        }

        protected override IQueryable<Orders> ApplyFilter(IQueryable<Orders> query, OrderQueryFilter? filter)
        {

            return query;
        }
    }
}
