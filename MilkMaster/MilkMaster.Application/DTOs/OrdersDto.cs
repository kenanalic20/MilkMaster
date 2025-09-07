

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
        public IEnumerable<OrderItemsCreateDto> Items { get; set; } = new List<OrderItemsCreateDto>();
    }

    public class OrdersUpdateDto
    {
        public string Customer { get; set; }
        public string PhoneNumber { get; set; }
        public int StatusId { get; set; }
    }

    public class  OrdersSeederDto:OrdersCreateDto
    {
        public string UserId { get; set; }
        public string OrderNumber { get; set; }
        public string Customer { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public DateTime CreatedAt { get; set; }
        public decimal Total { get; set; }
        public int ItemCount { get; set; }
        public int StatusId { get; set; }

    }
}
