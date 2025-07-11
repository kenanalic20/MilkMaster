using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Mappings
{
    public class ProductMappingProfile : Profile
    {
        public ProductMappingProfile()
        {
            CreateMap<Products, ProductsDto>()
                .ForMember(dest => dest.ProductCategories, opt => opt.MapFrom(src =>
                    src.ProductCategories != null
                    ? src.ProductCategories.Select(pc => pc.ProductCategory.Name).ToList()
                    :new List<string>()))
                .ForMember(dest => dest.CattleCategory, opt => opt.MapFrom(src => src.CattleCategory != null ? src.CattleCategory.Name : null));

            CreateMap<ProductsCreateDto, Products>()
                .ForMember(dest => dest.ProductCategories, opt => opt.MapFrom(src =>
                     src.ProductCategories != null
                    ? src.ProductCategories.Select(id => new ProductCategoriesProducts { ProductCategoryId = id }).ToList()
                    : new List<ProductCategoriesProducts>()))
                .ForMember(dest => dest.CattleCategory, opt => opt.Ignore());

            CreateMap<ProductsUpdateDto, Products>()
                .ForMember(dest => dest.ProductCategories, opt => opt.MapFrom(src =>
                    src.ProductCategories != null
                    ? src.ProductCategories.Select(id => new ProductCategoriesProducts { ProductCategoryId = id }).ToList()
                    : new List<ProductCategoriesProducts>()))
                .ForMember(dest => dest.CattleCategory, opt => opt.Ignore());
        }
    }
}
