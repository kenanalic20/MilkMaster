using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;


namespace MilkMaster.Domain.Models
{
    public class UserAddress
    {
        [Key]
        public string UserId { get; set; }
        public string? Street { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? ZipCode { get; set; }
        public string? Country { get; set; }

        public User User { get; set; }
    }
}
