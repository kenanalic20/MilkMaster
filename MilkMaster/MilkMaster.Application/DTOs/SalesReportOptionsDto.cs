namespace MilkMaster.Application.DTOs
{
    public class SalesReportOptionsDto
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public int TopProductsCount { get; set; } = 4;
        public int RecentOrdersCount { get; set; } = 10;
        public bool IncludeTopOrder { get; set; } = true;
        public bool IncludeTopCustomer { get; set; } = true;
        public bool IncludeLowestSellingProduct { get; set; } = true;
    }
}
