

namespace MilkMaster.Application.DTOs
{
    public class OrdersDto
    {
        public int Id { get; set; }
        public string OrderNumber { get; set; }
        public string Username { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public decimal Total { get; set; }
        public List<OrderItemsDto> Items { get; set; } = new();
    }

    public class OrdersCreateDto
    {
        public List<OrderItemsCreateDto> Items { get; set; } = new();
    }

    public class OrdersUpdateDto
    {
        public string Status { get; set; }
    }
}
