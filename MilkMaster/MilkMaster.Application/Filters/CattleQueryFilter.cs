
using MilkMaster.Application.Common;

namespace MilkMaster.Application.Filters
{
    public class CattleQueryFilter : PaginationRequest
    {
        public string? Search { get; set; }
        public int? CattleCategoryId { get; set; }
        public string? OrderBy { get; set; }

    }
}
