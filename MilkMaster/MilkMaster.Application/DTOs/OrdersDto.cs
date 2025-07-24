

using MilkMaster.Domain.Models;

namespace MilkMaster.Application.DTOs
{
    public class OrdersDto
    {
        public int Id { get; set; }
        public string OrderNumber { get; set; }
        public string Customer { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public DateTime CreatedAt { get; set; }
        public decimal Total { get; set; }
        public List<OrderItemsDto> Items { get; set; } = new();
        public int ItemCount { get; set; }
        public OrderStatusDto? Status { get; set; }
    }

    public class OrdersCreateDto
    {
        public List<OrderItemsCreateDto> Items { get; set; } = new();
    }

    public class OrdersUpdateDto
    {
        public int StatusId { get; set; }
    }
}
