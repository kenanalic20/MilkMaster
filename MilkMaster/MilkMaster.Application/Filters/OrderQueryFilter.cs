
using MilkMaster.Application.Common;

namespace MilkMaster.Application.Filters
{
    public class OrderQueryFilter : PaginationRequest
    {
        public string? OrderStatus { get; set; }
        public string? OrderBy { get; set; }
        public string? Search { get; set; }
    }
}
