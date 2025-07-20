
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace MilkMaster.Domain.Models
{
    public class Orders
    {
        public int Id { get; set; }
        public string OrderNumber { get; set; }
        public string UserId { get; set; }
        public IdentityUser? User { get; set; }

        public ICollection<OrderItems> Items { get; set; } = new List<OrderItems>();
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Precision(18, 2)]
        public decimal Total { get; set; }
        public string Status { get; set; } = "Pending";
    }
}
