

namespace MilkMaster.Domain.Models
{
    public class Units
    {
        public int Id { get; set; }
        public string Symbol { get; set; } = default!;

        public ICollection<Products> Products { get; set; } = new List<Products>();
        public ICollection<OrderItems> OrderItems { get; set; } = new List<OrderItems>();
    }
}
