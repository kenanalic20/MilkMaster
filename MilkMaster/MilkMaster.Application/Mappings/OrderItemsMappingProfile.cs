using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Mappings
{
    public class OrderItemsMappingProfile : Profile
    {
        public OrderItemsMappingProfile()
        {
            CreateMap<OrderItems, OrderItemsDto>().ReverseMap();
            CreateMap<OrderItemsCreateDto, OrderItems>();
            CreateMap<OrderItemsUpdateDto, OrderItems>()
                .ForMember(dest => dest.TotalPrice, opt => opt.Ignore());
        }
    }
}
