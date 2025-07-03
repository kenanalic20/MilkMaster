

using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.Infrastructure.Seeders
{
    public class ProductCategoriesSeeder
    {
        private readonly IProductCategoriesService _productCategoriesService;

        public ProductCategoriesSeeder(IProductCategoriesService productCategoriesService)
        {
            _productCategoriesService = productCategoriesService;
        }   

    }
}
