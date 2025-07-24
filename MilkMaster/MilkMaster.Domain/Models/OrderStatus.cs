namespace MilkMaster.Domain.Models
{
    public class OrderStatus
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string ColorCode { get; set; } = string.Empty;

        public ICollection<Orders> Orders { get; set; } = new List<Orders>();
    }
}
