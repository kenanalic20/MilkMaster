

using System.ComponentModel.DataAnnotations;

namespace MilkMaster.Application.DTOs
{
    public class CattleCategoriesDto
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; }
        public string Name { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
    }
    public class CattleCategoriesCreateDto
    {
        public string ImageUrl { get; set; }
        public string Title { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
    }
    public class CattleCategoriesUpdateDto
    {
        public string ImageUrl { get; set; }
        public string Name { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
    }
}
