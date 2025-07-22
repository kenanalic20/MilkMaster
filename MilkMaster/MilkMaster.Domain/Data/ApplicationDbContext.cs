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
        public DbSet<Nutritions> Nutritions { get; set; }
        public DbSet<Cattle> Cattle { get; set; }
        public DbSet<CattleOverview> CattleOverviews { get; set; }
        public DbSet<BreedingStatus> BreedingStatuses { get; set; }
        public DbSet<Orders> Orders { get; set; }
        public DbSet<OrderItems> OrderItems { get; set; }
        public DbSet<Units> Units { get; set; }

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

            // Products-Nutritions
            builder.Entity<Products>()
            .HasOne(p => p.Nutrition)
            .WithOne(n => n.Product)
            .HasForeignKey<Nutritions>(n => n.ProductId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Cascade);

            //Cattle-CattleOverview
            builder.Entity<Cattle>()
           .HasOne(c => c.Overview)
           .WithOne(co => co.Cattle)
           .HasForeignKey<CattleOverview>(co => co.CattleId)
           .IsRequired()
           .OnDelete(DeleteBehavior.Cascade);

            //Cattle-BreedingStatus
            builder.Entity<Cattle>()
            .HasOne(c => c.BreedingStatus)
            .WithOne(bs => bs.Cattle)
            .HasForeignKey<BreedingStatus>(bs => bs.CattleId)
            .IsRequired()
            .OnDelete(DeleteBehavior.Cascade);

            //Orders - OrderItems
            builder.Entity<Orders>()
            .HasMany(o => o.Items)
            .WithOne(i => i.Order)
            .HasForeignKey(i => i.OrderId);


            //Products - OrderItems
            builder.Entity<OrderItems>()
            .HasOne(i => i.Product)
            .WithMany(p => p.OrderItems) 
            .HasForeignKey(i => i.ProductId);

            //Products - Units
            builder.Entity<Products>()
            .HasOne(p => p.Unit)
            .WithMany()
            .HasForeignKey(p => p.UnitId)
            .IsRequired()
            .OnDelete(DeleteBehavior.NoAction);

            //Seed data for units
            builder.Entity<Units>().HasData(
                new Units { Id = 1, Symbol = "L" },
                new Units { Id = 2, Symbol = "kg" },
                new Units { Id = 3, Symbol = "g" },
                new Units { Id = 4, Symbol = "ml" }
             );
        }
    }
}
