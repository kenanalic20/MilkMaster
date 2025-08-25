
namespace MilkMaster.Domain.Models
{
    public class Cattle
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string ImageUrl { get; set; }
        public string MilkCartonUrl { get; set; }
        public string TagNumber { get; set; }
        public int CattleCategoryId { get; set; }
        public CattleCategories CattleCategory { get; set; } = null!;
        public string? BreedOfCattle { get; set; }
        public int Age { get; set; }
        public float LitersPerDay { get; set; }
        public float MonthlyValue { get; set; }
        public DateTime BirthDate { get; set; }
        public DateTime HealthCheck { get; set; }
        public CattleOverview? Overview { get; set; }
        public BreedingStatus? BreedingStatus { get; set; }
    }
}
