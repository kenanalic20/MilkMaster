namespace MilkMaster.Application.DTOs
{
    public class UserDetailsDto
    {
        public string? UserName { get; set; }
        public string? Email { get; set; }
        public IList<string>? Roles { get; set; }
    }
}
