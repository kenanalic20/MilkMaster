using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Repositories
{
    public interface IUserDetailsRepository:IRepository<UserDetails, string>
    {
    }
}
