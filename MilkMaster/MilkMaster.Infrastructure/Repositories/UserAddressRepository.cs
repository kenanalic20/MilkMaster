using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Domain.Data;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Repositories
{
    public class UserAddressRepository:BaseRepository<UserAddress, string>, IUserAddressRepository
    {
        private readonly ApplicationDbContext _context;
        public UserAddressRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
        public override async Task<UserAddress> GetByIdAsync(string id)
        {
            return await _context.UserAddresses
                .Include(s => s.User).
                FirstOrDefaultAsync(s => s.UserId == id);
        }
    }
}
