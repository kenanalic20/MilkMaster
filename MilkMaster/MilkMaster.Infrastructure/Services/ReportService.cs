using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using QuestPDF.Fluent;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkMaster.Infrastructure.Services
{
    public class ReportService:IReportService
    {
        private readonly IProductsService _productsService;
        private readonly IOrdersService _ordersService;
        private readonly UserManager<IdentityUser> _userManager;
        private readonly IOrderItemsService _orderItemsService;
        private readonly IOrdersRepository _ordersRepository;
        public ReportService
        (
            IProductsService productsService,
            IOrdersService ordersService,
            UserManager<IdentityUser> userManager,
            IOrderItemsService orderItemsService,
            IOrdersRepository ordersRepository
        ) 
        { 
            _productsService = productsService;
            _ordersService = ordersService;
            _userManager = userManager;
            _orderItemsService = orderItemsService;
            _ordersRepository = ordersRepository;
        }

        public async Task<byte[]> GenerateReport(SalesReportOptionsDto options)
        {
            var totalRevenue = await _ordersService.GetTotalRevenueAsync();
            var totalOrders = _ordersRepository.AsQueryable().Count();
            var totalProductsSold = await _orderItemsService.GetTotalSoldProductsCountAsync();
            var totalCustomers = await _userManager.Users.CountAsync();

            var topProducts =await _productsService.GetTopSellingProductsAsync(options.TopProductsCount);
            var recentOrders = _ordersRepository.AsQueryable().OrderByDescending(o => o.CreatedAt).Take(options.RecentOrdersCount);


            var lowestSellingProduct = options.IncludeLowestSellingProduct
                ? await _productsService.GetLowestSellingProductAsync()
                : null;

            var topOrder = options.IncludeTopOrder
                ? _ordersRepository.AsQueryable().OrderByDescending(o => o.Total).FirstOrDefault()
                : null;

            var topCustomer = options.IncludeTopCustomer
                ? await _ordersService.GetTopCustomerAsync()
                : null;

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(40);

                    page.Header()
                        .Text($"Sales Report - {options.Name}")
                        .FontSize(20)
                        .Bold();

                    page.Content().Column(col =>
                    {
                        col.Item().Text(options.Description).Italic();

                        col.Item().PaddingVertical(10).LineHorizontal(1);

                        col.Item().Text($"Total Revenue: {totalRevenue} BAM");
                        col.Item().Text($"Total Orders: {totalOrders}");
                        col.Item().Text($"Products Sold: {totalProductsSold}");
                        col.Item().Text($"Total Customers: {totalCustomers}");

                        col.Item().PaddingVertical(10).LineHorizontal(1);

                        if (!topProducts.IsNullOrEmpty())
                        {
                            col.Item().Text("Top Selling Products").Bold();
                            foreach (var product in topProducts)
                            {
                                col.Item().Text($"- {product.Title} ({product.TotalSales} BAM)");
                            }
                            col.Item().PaddingVertical(10).LineHorizontal(1);
                        }

                        if(!recentOrders.IsNullOrEmpty())
                        {
                            col.Item().Text("Recent Orders").Bold();
                            foreach (var order in recentOrders)
                            {
                                col.Item().Text($"- Order #{order.Id} - {order.Total} BAM");
                            }

                        }

                        if (lowestSellingProduct != null)
                        {
                            col.Item().PaddingVertical(10).LineHorizontal(1);
                            col.Item().Text("Lowest Selling Product").Bold();
                            col.Item().Text($"{lowestSellingProduct.Title} ({lowestSellingProduct.TotalSales} BAM)");
                        }

                        if (topOrder != null)
                        {
                            col.Item().PaddingVertical(10).LineHorizontal(1);
                            col.Item().Text("Top Order").Bold();
                            col.Item().Text($"Order {topOrder.OrderNumber} - {topOrder.Total} BAM");
                        }

                        if (topCustomer != null)
                        {
                            col.Item().PaddingVertical(10).LineHorizontal(1);
                            col.Item().Text("Top Customer").Bold();
                            col.Item().Text($"{topCustomer.FullName} - {topCustomer.TotalOrders} orders - {topCustomer.TotalSpent} BAM");
                            col.Item().Text($"Phone number: {topCustomer.PhoneNumber}, Email: {topCustomer.Email}");

                        }
                    });
                });
            });

            return document.GeneratePdf();
        }
    }
}
