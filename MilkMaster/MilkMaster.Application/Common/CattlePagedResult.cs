using MilkMaster.Application.DTOs;

namespace MilkMaster.Application.Common
{
    public class CattlePagedResult:PagedResult<CattleDto>
    {
        public double TotalRevenue { get; set; }
        public double TotalLiters { get; set; }
    }
}
