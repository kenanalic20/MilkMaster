using System.Text.Json.Serialization;

namespace MilkMaster.Application.DTOs
{
    public class SettingsCreateDto:SettingsDto
    {
        public string UserId { get; set; }
    }
}
