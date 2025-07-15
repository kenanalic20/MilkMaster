
namespace MilkMaster.Domain.Models
{
    public class Products
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; }
        public string Title { get; set; }
        public int CattleCategoryId { get; set; }
        public CattleCategories? CattleCategory { get; set; }
        public Nutritions? Nutrition { get; set; }
        public ICollection<ProductCategoriesProducts>? ProductCategories { get; set; } = new List<ProductCategoriesProducts>();
        public decimal PricePerUnit { get; set; }
        public string Unit { get; set; }
        public int Quantity { get; set; }
        public string? Description { get; set; }
    }
}
