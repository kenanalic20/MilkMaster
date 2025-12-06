using MilkMaster.Application.DTOs;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IPaymentService
    {
        Task<PaymentIntentResponse> CreatePaymentIntentAsync(decimal amount, string currency = "usd");
        Task<bool> ConfirmPaymentAsync(string paymentIntentId);
        string GetPublishableKey();
    }
}
