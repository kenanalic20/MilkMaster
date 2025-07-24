
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace MilkMaster.Domain.Models
{
    public class Orders
    {
        public int Id { get; set; }
        public string OrderNumber { get; set; }
        public string Customer { get; set; }
        public string Email {  get; set; }
        public string PhoneNumber { get; set; }

        public ICollection<OrderItems> Items { get; set; } = new List<OrderItems>();
        public int ItemCount { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Precision(18, 2)]
        public decimal Total { get; set; }
        public int StatusId { get; set; } = 1;
        public OrderStatus? Status { get; set; }
    }
}
