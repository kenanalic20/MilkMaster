
using MilkMaster.Application.Common;

namespace MilkMaster.Application.Filters
{
    public class OrderQueryFilter : PaginationRequest
    {
        public string? OrderNumber { get; set; }
        public string? OrderStatus { get; set; }
        public string? OrderBy { get; set; }
        public string? Customer { get; set; }
    }
}
