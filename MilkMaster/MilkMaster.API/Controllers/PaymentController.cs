using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpPost("create-payment-intent")]
        [Authorize]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] CreatePaymentIntentRequest request)
        {
            try
            {
                var result = await _paymentService.CreatePaymentIntentAsync(request.Amount, request.Currency);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("confirm-payment")]
        [Authorize]
        public async Task<IActionResult> ConfirmPayment([FromBody] ConfirmPaymentRequest request)
        {
            try
            {
                var isConfirmed = await _paymentService.ConfirmPaymentAsync(request.PaymentIntentId);
                
                if (isConfirmed)
                {
                    // TODO: Update order status in database
                    return Ok(new { success = true, message = "Payment confirmed successfully" });
                }
                
                return BadRequest(new { success = false, message = "Payment not confirmed" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("config")]
        public IActionResult GetPublishableKey()
        {
            return Ok(new { publishableKey = _paymentService.GetPublishableKey() });
        }
    }
}
