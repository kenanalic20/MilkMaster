using MilkMaster.Application.Common;

namespace MilkMaster.Application.Filters
{
    public class OrderItemsQueryFilter : PaginationRequest
    {
        public int OrderId { get; set; }
    }
}
