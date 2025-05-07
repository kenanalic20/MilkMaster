namespace MilkMaster.Application.DTOs
{
    public interface SettingsDto
    {
        public bool NotificationsEnabled { get; set; }
        public bool PushNotificationsEnabled { get; set; }
    }
}
