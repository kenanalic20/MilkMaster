using Microsoft.Extensions.Configuration;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Stripe;

namespace MilkMaster.Infrastructure.Services
{
    public class StripePaymentService : IPaymentService
    {
        private readonly string _secretKey;
        private readonly string _publishableKey;

        public StripePaymentService(IConfiguration configuration)
        {
            _secretKey = configuration["STRIPE_SECRET_KEY"] ?? throw new ArgumentNullException("STRIPE_SECRET_KEY not configured");
            _publishableKey = configuration["STRIPE_PUBLISHABLE_KEY"] ?? throw new ArgumentNullException("STRIPE_PUBLISHABLE_KEY not configured");
            
            StripeConfiguration.ApiKey = _secretKey;
        }

        public async Task<PaymentIntentResponse> CreatePaymentIntentAsync(decimal amount, string currency = "bam")
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)(amount * 100), // Convert to cents/feninga
                Currency = currency.ToLower(),
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true,
                },
            };

            var service = new PaymentIntentService();
            var paymentIntent = await service.CreateAsync(options);

            return new PaymentIntentResponse
            {
                ClientSecret = paymentIntent.ClientSecret,
                PaymentIntentId = paymentIntent.Id,
                PublishableKey = _publishableKey
            };
        }

        public async Task<bool> ConfirmPaymentAsync(string paymentIntentId)
        {
            var service = new PaymentIntentService();
            var paymentIntent = await service.GetAsync(paymentIntentId);
            
            return paymentIntent.Status == "succeeded";
        }

        public string GetPublishableKey()
        {
            return _publishableKey;
        }
    }
}
