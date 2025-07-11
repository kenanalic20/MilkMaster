namespace MilkMaster.Application.DTOs
{
    public class ProductsDto
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; }
        public string Title { get; set; }
        public decimal PricePerUnit { get; set; }
        public string Unit { get; set; }
        public int Quantity { get; set; }
        public string Description { get; set; }
        public ICollection<string>? ProductCategories { get; set; }
        public string? CattleCategory { get; set; }
    }
    public class ProductsCreateDto
    {
        public string ImageUrl { get; set; }
        public string Title { get; set; }
        public decimal PricePerUnit { get; set; }
        public string Unit { get; set; }
        public int Quantity { get; set; }
        public string Description { get; set; }
        public ICollection<int>? ProductCategories { get; set; } 
        public int? CattleCategoryId { get; set; } 
    }
    public class ProductsUpdateDto
    {
        public string ImageUrl { get; set; }
        public string Title { get; set; }
        public decimal PricePerUnit { get; set; }
        public string Unit { get; set; }
        public int Quantity { get; set; }
        public string Description { get; set; }
        public ICollection<int>? ProductCategories { get; set; }
        public int? CattleCategoryId { get; set; }
    }
}
