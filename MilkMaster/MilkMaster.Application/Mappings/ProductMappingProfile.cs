using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Mappings
{
    public class ProductMappingProfile : Profile
    {
        public ProductMappingProfile()
        {
            CreateMap<Units, UnitsDto>().ReverseMap();
            CreateMap<Nutritions, NutritionsDto>().ReverseMap();

            CreateMap<Products, ProductsDto>()
                .ForMember(dest => dest.ProductCategories,
                    opt => opt.MapFrom(src => src.ProductCategories.Select(pc => pc.ProductCategory)));

            CreateMap<ProductsCreateDto, Products>()
                .ForMember(dest => dest.ProductCategories, opt => opt.MapFrom(src =>
                     src.ProductCategories != null
                    ? src.ProductCategories.Select(id => new ProductCategoriesProducts { ProductCategoryId = id }).ToList()
                    : new List<ProductCategoriesProducts>()))
                .ForMember(dest => dest.CattleCategoryId, opt => opt.MapFrom(src => src.CattleCategoryId))
                .ForMember(dest => dest.UnitId, opt => opt.MapFrom(src => src.UnitId));

            CreateMap<ProductsUpdateDto, Products>()
                .ForMember(dest => dest.ProductCategories, opt => opt.MapFrom(src =>
                    src.ProductCategories != null
                    ? src.ProductCategories.Select(id => new ProductCategoriesProducts { ProductCategoryId = id }).ToList()
                    : new List<ProductCategoriesProducts>()))
                .ForMember(dest => dest.CattleCategoryId, opt => opt.MapFrom(src => src.CattleCategoryId))
                .ForMember(dest => dest.UnitId, opt => opt.MapFrom(src => src.UnitId));

        }
    }
}
