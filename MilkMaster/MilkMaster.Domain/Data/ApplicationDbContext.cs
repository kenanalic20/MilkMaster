using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Domain.Models;

namespace MilkMaster.Domain.Data
{
    public class ApplicationDbContext : IdentityDbContext<IdentityUser>
    {
        public DbSet<UserDetails> UserDetails { get; set; }
        public DbSet<Settings> Settings { get; set; }
        public DbSet<UserAddress> UserAddresses { get; set; }

        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }
        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // User Details - IdentityUsers
            builder.Entity<UserDetails>()
            .HasOne(p => p.User)
            .WithOne()
            .HasForeignKey<UserDetails>(p => p.UserId)
            .IsRequired();

            // User Address - IdentityUsers
            builder.Entity<UserAddress>()
            .HasOne(a => a.User)
            .WithOne()
            .HasForeignKey<UserAddress>(a => a.UserId)
            .IsRequired();

            // User Settings - IdentityUsers
            builder.Entity<Settings>().
                HasOne(s => s.User)
                .WithOne()
                .HasForeignKey<Settings>(s => s.UserId)
                .IsRequired();
        }
    }
}
