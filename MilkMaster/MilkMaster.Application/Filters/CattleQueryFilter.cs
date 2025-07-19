
using MilkMaster.Application.Common;

namespace MilkMaster.Application.Filters
{
    public class CattleQueryFilter : PaginationRequest
    {
        public string? Name { get; set; }
        public int? CattleCategoryId { get; set; }
    }
}
