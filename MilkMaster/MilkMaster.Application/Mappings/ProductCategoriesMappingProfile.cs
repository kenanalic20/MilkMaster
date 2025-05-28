using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;
using AutoMapper;

namespace MilkMaster.Application.Mappings
{
    public class ProductCategoriesMappingProfile:Profile
    {
        public ProductCategoriesMappingProfile()
        {
            CreateMap<ProductCategories, ProductCategoriesDto>();
            CreateMap<ProductCategories, ProductCategoriesAdminDto>();

            CreateMap<ProductCategoriesCreateDto, ProductCategories>();
            CreateMap<ProductCategoriesUpdateDto, ProductCategories>();
        }
    }
}
