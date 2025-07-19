
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.Infrastructure.Services
{
    public class GeneralSearchService:IGeneralSearchService
    {
        private readonly IProductsRepository _productRepository;
        private readonly ICattleRepository _cattleRepository;
        private readonly IMapper _mapper;

        public GeneralSearchService(
            IProductsRepository productRepository,
            ICattleRepository cattleRepository,
            IMapper mapper)
        {
            _productRepository = productRepository;
            _cattleRepository = cattleRepository;
            _mapper = mapper;
        }

        public async Task<GeneralSearchResultDto> GeneralSearchAsync(string query)
        {
            var productResults = await _productRepository.AsQueryable()
                .Where(p => p.Title.Contains(query) || p.Description.Contains(query))
                .Take(10)
                .ToListAsync();

            var cattleResults = await _cattleRepository.AsQueryable().Include(c => c.CattleCategory)
                .Where(c => c.Name.Contains(query) || c.CattleCategory.Title.Contains(query))
                .Take(10)
                .ToListAsync();

            return new GeneralSearchResultDto
            {
                Products = _mapper.Map<List<ProductsDto>>(productResults),
                Cattles = _mapper.Map<List<CattleDto>>(cattleResults)
            };
        }
    }
}
