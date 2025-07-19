

namespace MilkMaster.Domain.Models
{
    public class BreedingStatus
    {
        public int Id{ get; set; }
        public int CattleId { get; set; }
        public Cattle Cattle { get; set; } = null;
        public bool PragnancyStatus { get; set; }
        public DateTime LastCalving { get; set; }
        public int NumberOfCalves { get; set; }
    }
}
