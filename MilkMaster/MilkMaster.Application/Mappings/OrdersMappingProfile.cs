using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;


namespace MilkMaster.Application.Mappings
{
    public class OrdersMappingProfile : Profile
    {
        public OrdersMappingProfile() 
        {
            CreateMap<OrderStatus,OrderStatusDto>().ReverseMap();
            CreateMap<Orders, OrdersDto>();
            CreateMap<OrdersCreateDto, Orders>()
                .ForMember(dest => dest.Items, opt => opt.Ignore());
            CreateMap<OrdersUpdateDto, Orders>();
            CreateMap<OrdersSeederDto, Orders>();
        }
    }
}
