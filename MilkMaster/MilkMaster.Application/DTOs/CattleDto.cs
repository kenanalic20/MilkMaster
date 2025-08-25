
namespace MilkMaster.Application.DTOs
{
    public class CattleDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string ImageUrl { get; set; }
        public string MilkCartonUrl { get; set; }
        public string TagNumber { get; set; }
        public CattleCategoriesDto CattleCategory { get; set; } = null!;
        public string? BreedOfCattle { get; set; }
        public int Age { get; set; }
        public float LitersPerDay { get; set; }
        public float MonthlyValue { get; set; }
        public DateTime BirthDate { get; set; }
        public DateTime HealthCheck { get; set; }
        public CattleOverviewDto? Overview { get; set; }
        public BreedingStatusDto? BreedingStatus { get; set; }
    }

    public class CattleCreateDto
    {
        public string Name { get; set; }
        public string ImageUrl { get; set; }
        public string MilkCartonUrl { get; set; }
        public string TagNumber { get; set; }
        public int CattleCategoryId { get; set; }
        public string? BreedOfCattle { get; set; }
        public float LitersPerDay { get; set; }
        public float MonthlyValue { get; set; }
        public DateTime BirthDate { get; set; }
        public DateTime HealthCheck { get; set; }
        public CattleOverviewDto? Overview { get; set; }
        public BreedingStatusDto? BreedingStatus { get; set; }
    }

    public class CattleUpdateDto
    {
        public string Name { get; set; }
        public string ImageUrl { get; set; }
        public string MilkCartonUrl { get; set; }
        public string TagNumber { get; set; }
        public int CattleCategoryId { get; set; }
        public string? BreedOfCattle { get; set; }
        public float LitersPerDay { get; set; }
        public float MonthlyValue { get; set; }
        public DateTime BirthDate { get; set; }
        public DateTime HealthCheck { get; set; }
        public CattleOverviewDto? Overview { get; set; }
        public BreedingStatusDto? BreedingStatus { get; set; }
    }

    public class CattleSeederDto : CattleCreateDto
    {
        public int Age { get; set; }
    }

}
