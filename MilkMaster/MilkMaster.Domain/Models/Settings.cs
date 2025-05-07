using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkMaster.Domain.Models
{
    public class Settings
    {
        [Key]
        public string UserId { get; set; }
        public bool NotificationsEnabled { get; set; }
        public bool PushNotificationsEnabled { get; set; }

        public IdentityUser User { get; set; }
    }
}
