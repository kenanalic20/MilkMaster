using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkMaster.Application.DTOs
{
    public class UserDto
    {
        public string? Id { get; set; }
        public string? UserName { get; set; } 
        public string? CustomerName { get; set; } 
        public string? Email { get; set; }
        public string? PhoneNumber { get; set; }
        public int OrderCount { get; set; }
        public DateTime? LastOrderDate { get; set; }
        public string? Street { get; set; }
        public string? ImageUrl { get; set; }
    }
}
