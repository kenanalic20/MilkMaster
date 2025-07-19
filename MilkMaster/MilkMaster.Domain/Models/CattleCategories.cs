using System.ComponentModel.DataAnnotations;

namespace MilkMaster.Domain.Models
{
    public class CattleCategories
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public string ImageUrl { get; set; }
        [Required]
        public string Name { get; set; }
        [Required]
        public string Title { get; set; }
        public string Description { get; set; }

        public ICollection<Products> Products { get; set; }=new List<Products>();
        public ICollection<Cattle> Cattle { get; set; } = new List<Cattle>();
    }
}
