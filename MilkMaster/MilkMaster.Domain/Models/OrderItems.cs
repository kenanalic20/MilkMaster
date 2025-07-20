
using Microsoft.EntityFrameworkCore;

namespace MilkMaster.Domain.Models
{
    public class OrderItems
    {
        public int Id { get; set; }

        public int OrderId { get; set; }
        public Orders Order { get; set; }

        public int ProductId { get; set; }
        public Products Product { get; set; }

        public int Quantity { get; set; }
        [Precision(18, 2)]
        public decimal UnitSize { get; set; }
        public int UnitId { get; set; }
        public Units Unit { get; set; } = default!;
        [Precision(18, 2)]
        public decimal PricePerUnit { get; set; }
        [Precision(18, 2)]
        public decimal TotalPrice => Quantity * UnitSize * PricePerUnit;
    }
}
