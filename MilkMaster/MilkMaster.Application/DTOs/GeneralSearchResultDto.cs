

namespace MilkMaster.Application.DTOs
{
    public class GeneralSearchResultDto
    {
        public List<ProductsDto> Products { get; set; } = new();
        public List<CattleDto> Cattles { get; set; } = new();
    }
}
