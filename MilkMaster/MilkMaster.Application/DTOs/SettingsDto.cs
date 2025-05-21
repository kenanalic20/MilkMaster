namespace MilkMaster.Application.DTOs
{
    public class SettingsDto
    {
        public bool NotificationsEnabled { get; set; }
        public bool PushNotificationsEnabled { get; set; }
    }
    public class SettingsCreateDto : SettingsDto
    {
        public string UserId { get; set; }
    }
    public class SettingsUpdateDto : SettingsDto
    {
    }
}
