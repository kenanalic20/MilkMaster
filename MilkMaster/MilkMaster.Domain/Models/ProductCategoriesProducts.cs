namespace MilkMaster.Domain.Models
{
    public class ProductCategoriesProducts
    {
        public int ProductId { get; set; }
        public Products Product { get; set; }

        public int ProductCategoryId { get; set; }
        public ProductCategories ProductCategory { get; set; }
    }
}
