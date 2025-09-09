

using Microsoft.AspNetCore.Identity;

namespace MilkMaster.Domain.Models
{
    public class User:IdentityUser
    {
        public int OrderCount { get; set; }
        public DateTime? LastOrderDate { get; set; }
    }
}
