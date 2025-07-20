namespace MilkMaster.Application.DTOs
{
    public class ProductsDto
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; }
        public string Title { get; set; }
        public decimal PricePerUnit { get; set; }
        public UnitsDto? Unit { get; set; }
        public int Quantity { get; set; }
        public string? Description { get; set; }
        public ICollection<ProductCategoriesDto>? ProductCategories { get; set; } = new List<ProductCategoriesDto>();
        public CattleCategoriesDto? CattleCategory { get; set; }
        public NutritionsDto? Nutrition { get; set; }
    }
    public class ProductsCreateDto
    {
        public string ImageUrl { get; set; }
        public string Title { get; set; }
        public decimal PricePerUnit { get; set; }
        public int UnitId { get; set; }
        public int Quantity { get; set; }
        public string? Description { get; set; }
        public ICollection<int>? ProductCategories { get; set; } = new List<int>();
        public int? CattleCategoryId { get; set; }
        public NutritionsDto? Nutrition { get; set; }
    }
    public class ProductsUpdateDto
    {
        public string ImageUrl { get; set; }
        public string Title { get; set; }
        public decimal PricePerUnit { get; set; }
        public int UnitId { get; set; }
        public int Quantity { get; set; }
        public string? Description { get; set; }
        public ICollection<int>? ProductCategories { get; set; } = new List<int>();
        public int? CattleCategoryId { get; set; }
        public NutritionsDto? Nutrition { get; set; }

    }
}
