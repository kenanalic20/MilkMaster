using Microsoft.AspNetCore.Identity;

namespace MilkMaster.Domain.Models
{
    public class Role:IdentityRole
    {
        public virtual ICollection<UserRole> UserRoles { get; set; }
    }
    public class UserRole : IdentityUserRole<string>
    {
        public virtual User User { get; set; }
        public virtual Role Role { get; set; }
    }
}
