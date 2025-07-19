using MilkMaster.Application.Common;

namespace MilkMaster.Application.Filters
{
    public class ProductQueryFilter : PaginationRequest
    {
        public string? Title { get; set; }
        public int? ProductCategoryId { get; set; }
        public int? CattleCategoryId { get; set; }
        public bool SortDescending { get; set; } = true;
    }
}
