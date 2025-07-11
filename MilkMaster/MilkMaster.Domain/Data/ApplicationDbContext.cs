using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Domain.Models;
using System.Reflection.Emit;

namespace MilkMaster.Domain.Data
{
    public class ApplicationDbContext : IdentityDbContext<IdentityUser>
    {
        public DbSet<UserDetails> UserDetails { get; set; }
        public DbSet<Settings> Settings { get; set; }
        public DbSet<UserAddress> UserAddresses { get; set; }
        public DbSet<ProductCategories> ProductCategories { get; set; }
        public DbSet<CattleCategories> CattleCategories { get; set; }
        public DbSet<Products> Products { get; set; }
        public DbSet<ProductCategoriesProducts> ProductCategoriesProducts { get; set; }

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

            // Product Categories - Products
            builder.Entity<ProductCategoriesProducts>()
            .HasKey(pc => new { pc.ProductId, pc.ProductCategoryId });

            //ProductCategoriesProducts - Product
            builder.Entity<ProductCategoriesProducts>()
                .HasOne(pc => pc.Product)
                .WithMany(p => p.ProductCategories)
                .HasForeignKey(pc => pc.ProductId);

            // ProductCategoriesProducts - ProductCategories
            builder.Entity<ProductCategoriesProducts>()
                .HasOne(pc => pc.ProductCategory)
                .WithMany(c =>c.ProductCategoriesProducts )
                .HasForeignKey(pc => pc.ProductCategoryId);
            //Products decimal price
            builder.Entity<Products>()
                .Property(p => p.PricePerUnit)
                .HasPrecision(18,2);
        }
    }
}
