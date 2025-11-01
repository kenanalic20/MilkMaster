using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IOrderItemsService : IService<OrderItems, OrderItemsDto, OrderItemsCreateDto, OrderItemsUpdateDto, OrderItemsQueryFilter, int>
    {
        Task<int> GetTotalSoldProductsCountAsync();
    }
}
