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
                .ForMember(dest => dest.ProductCategories,
                    opt => opt.MapFrom(src => src.ProductCategories.Select(pc => pc.ProductCategory)))
                .ForMember(dest => dest.CattleCategory,
                    opt => opt.MapFrom(src => src.CattleCategory))
                .ForMember(dest => dest.Nutrition,
                    opt => opt.MapFrom(src => src.Nutrition));
            
            CreateMap<ProductsCreateDto, Products>()
                .ForMember(dest => dest.ProductCategories, opt => opt.MapFrom(src =>
                     src.ProductCategories != null
                    ? src.ProductCategories.Select(id => new ProductCategoriesProducts { ProductCategoryId = id }).ToList()
                    : new List<ProductCategoriesProducts>()))
                .ForMember(dest => dest.CattleCategoryId, opt => opt.MapFrom(src => src.CattleCategoryId))
                .ForMember(dest => dest.Nutrition, opt => opt.MapFrom(src => src.Nutrition));

            CreateMap<ProductsUpdateDto, Products>()
                .ForMember(dest => dest.ProductCategories, opt => opt.MapFrom(src =>
                    src.ProductCategories != null
                    ? src.ProductCategories.Select(id => new ProductCategoriesProducts { ProductCategoryId = id }).ToList()
                    : new List<ProductCategoriesProducts>()))
                .ForMember(dest => dest.CattleCategoryId, opt => opt.MapFrom(src => src.CattleCategoryId))
                .ForMember(dest => dest.Nutrition, opt => opt.MapFrom(src => src.Nutrition));

            CreateMap<NutritionsDto, Nutritions>().ReverseMap();
        }
    }
}
