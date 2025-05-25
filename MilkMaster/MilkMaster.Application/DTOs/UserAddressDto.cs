namespace MilkMaster.Application.DTOs
{
    public class UserAddressDto
    {
        public string? Street { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? ZipCode { get; set; }
        public string? Country { get; set; }
    }
    public class UserAddressCreateDto : UserAddressDto
    {
        public string UserId { get; set; }
    }
    public class UserAddressUpdateDto : UserAddressDto 
    {
    }
}
