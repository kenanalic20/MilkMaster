
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
                .ForMember(dest => dest.CattleCategory, opt => opt.MapFrom(src => src.CattleCategory))
                .ForMember(dest => dest.Overview, opt => opt.MapFrom(src => src.Overview))
                .ForMember(dest => dest.BreedingStatus, opt => opt.MapFrom(src => src.BreedingStatus));

            CreateMap<CattleCreateDto, Cattle>()
                .ForMember(dest => dest.CattleCategoryId, opt => opt.MapFrom(src => src.CattleCategoryId))
                .ForMember(dest => dest.Overview, opt => opt.MapFrom(src => src.Overview))
                .ForMember(dest => dest.BreedingStatus, opt => opt.MapFrom(src => src.BreedingStatus))
                .ForMember(dest => dest.Age, opt => opt.Ignore());

            CreateMap<CattleUpdateDto, Cattle>()
                .ForMember(dest => dest.CattleCategoryId, opt => opt.MapFrom(src => src.CattleCategoryId))
                .ForMember(dest => dest.Overview, opt => opt.MapFrom(src => src.Overview))
                .ForMember(dest => dest.BreedingStatus, opt => opt.MapFrom(src => src.BreedingStatus));
                .ForMember(dest => dest.Age, opt => opt.Ignore());
        }
    }
}
