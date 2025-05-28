using System.ComponentModel.DataAnnotations;

namespace MilkMaster.Domain.Models
{
    public class ProductCategories
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public string ImageUrl { get; set; }
        [Required]
        public string Name { get; set; }
        public int Count { get; set; }

    }
}
