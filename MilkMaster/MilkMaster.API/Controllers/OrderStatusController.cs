using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Data;

namespace MilkMaster.API.Controllers
{
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("[controller]")]
    public class OrderStatusController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public OrderStatusController(ApplicationDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<UnitsDto>>> GetAll()
        {
            var units = await _context.Units.ToListAsync();
            var result = _mapper.Map<List<OrderStatusDto>>(units);
            return Ok(result);
        }
    }
}
