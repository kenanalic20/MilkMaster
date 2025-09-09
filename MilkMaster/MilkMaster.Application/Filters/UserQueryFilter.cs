using MilkMaster.Application.Common;

namespace MilkMaster.Application.Filters
{
    public class UserQueryFilter:PaginationRequest
    {
        public string? Search { get; set; }
        public string? OrderBy { get; set; }
    }
}
