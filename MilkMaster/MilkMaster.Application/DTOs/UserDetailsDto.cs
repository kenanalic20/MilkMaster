namespace MilkMaster.Application.DTOs
{

    public class UserDetailsDto
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? ImageUrl { get; set; }
    }
    public class UserDetailsCreateDto : UserDetailsDto
    {
        public string UserId { get; set; }
    }
    public class UserDetailsUpdateDto : UserDetailsDto
    {
    }
}
