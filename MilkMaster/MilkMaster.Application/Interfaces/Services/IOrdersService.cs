using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IOrdersService : IService<Orders, OrdersDto, OrdersCreateDto, OrdersUpdateDto, OrderQueryFilter, int>
    {
        Task RecalculateOrderTotalAsync(int orderId);
        Task<string> GenerateOrderNumberAsync();
        Task<decimal> GetTotalRevenueAsync();
        Task<TopCustomerDto?> GetTopCustomerAsync();
    }
}
