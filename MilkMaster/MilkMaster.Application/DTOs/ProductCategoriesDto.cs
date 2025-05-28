namespace MilkMaster.Application.DTOs
{
    public class ProductCategoriesDto
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; }
        public string Name { get; set; }
    }
    public class ProductCategoriesAdminDto : ProductCategoriesDto
    {
       public int Count { get; set; }
    }
    public class ProductCategoriesCreateDto
    {
        public string ImageUrl { get; set; }
        public string Name { get; set; }
    }
    public class ProductCategoriesUpdateDto
    {
        public string ImageUrl { get; set; }
        public string Name { get; set; }
    }

}
