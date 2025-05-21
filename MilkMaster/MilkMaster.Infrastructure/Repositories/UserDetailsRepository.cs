using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Domain.Data;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Repositories
{
    public class UserDetailsRepository:BaseRepository<UserDetails,string>,IUserDetailsRepository
    {
        private readonly ApplicationDbContext _context;
        public UserDetailsRepository(ApplicationDbContext context) : base(context) 
        {
            _context = context;
        }

        public override async Task<UserDetails> GetByIdAsync(string id)
        {
            return await _context.UserDetails
                .Include(s => s.User).
                FirstOrDefaultAsync(s => s.UserId == id);
        }
    }
}
