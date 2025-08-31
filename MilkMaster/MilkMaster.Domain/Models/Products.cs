
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace MilkMaster.Domain.Models
{
    public class Products
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; }
        public string Title { get; set; }
        public int? CattleCategoryId { get; set; }
        public CattleCategories? CattleCategory { get; set; }
        public Nutritions? Nutrition { get; set; }
        public ICollection<ProductCategoriesProducts>? ProductCategories { get; set; } = new List<ProductCategoriesProducts>();
        [Precision(18, 2)]
        public decimal PricePerUnit { get; set; }
        public int UnitId { get; set; }
        public Units? Unit { get; set; }
        public int Quantity { get; set; }
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public ICollection<OrderItems> OrderItems { get; set; } = new List<OrderItems>();
        [Timestamp]
        public byte[] RowVersion { get; set; }

    }
}
