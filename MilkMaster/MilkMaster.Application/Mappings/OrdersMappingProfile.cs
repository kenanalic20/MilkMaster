using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;


namespace MilkMaster.Application.Mappings
{
    public class OrdersMappingProfile : Profile
    {
        public OrdersMappingProfile() 
        {
            CreateMap<Orders, OrdersDto>().ReverseMap();
            CreateMap<OrdersCreateDto, Orders>();
            CreateMap<OrdersUpdateDto, Orders>();
        }
    }
}
