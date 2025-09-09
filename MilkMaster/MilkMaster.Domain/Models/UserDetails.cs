using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace MilkMaster.Domain.Models
{
    public class UserDetails
    {
        [Key]
        public string UserId { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? ImageUrl { get; set; }
        public User? User { get; set; }
    }
}
