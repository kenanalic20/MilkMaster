

using Microsoft.AspNetCore.Identity;

namespace MilkMaster.Domain.Models
{
    public class User:IdentityUser
    {
        public int OrderCount { get; set; }
        public DateTime? LastOrderDate { get; set; }
        public ICollection<Orders> Orders { get; set; } = new List<Orders>();
        public virtual ICollection<UserRole> UserRoles { get; set; }

    }
}
