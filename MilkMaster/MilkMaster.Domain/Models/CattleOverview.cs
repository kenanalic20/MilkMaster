
namespace MilkMaster.Domain.Models
{
    public class CattleOverview
    {
        public int Id { get; set; }
        public int CattleId { get; set; }
        public Cattle Cattle { get; set; } = null;
        public string? Description { get; set; }
        public float? Weight { get; set; }
        public float? Height { get; set; }
        public string? Diet { get; set; }

    }
}
