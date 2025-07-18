
using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Mappings
{
    public class CattleMappingProfile : Profile
    {
        public CattleMappingProfile() {
            CreateMap<CattleOverview, CattleOverviewDto>().ReverseMap();
            CreateMap<BreedingStatus, BreedingStatusDto>().ReverseMap();

            CreateMap<Cattle, CattleDto>()
                .ForMember(dest => dest.CattleCategory, opt => opt.MapFrom(src => src.CattleCategory));

            CreateMap<CattleCreateDto, Cattle>()
                .ForMember(dest => dest.CattleCategoryId, opt => opt.MapFrom(src => src.CattleCategoryId));

            CreateMap<CattleUpdateDto, Cattle>()
                .ForMember(dest => dest.CattleCategoryId, opt => opt.MapFrom(src => src.CattleCategoryId));
        }
    }
}
