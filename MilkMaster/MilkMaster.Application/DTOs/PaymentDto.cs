namespace MilkMaster.Application.DTOs
{
    public class CreatePaymentIntentRequest
    {
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "usd";
        public int OrderId { get; set; }
    }

    public class PaymentIntentResponse
    {
        public string ClientSecret { get; set; }
        public string PaymentIntentId { get; set; }
        public string PublishableKey { get; set; }
    }

    public class ConfirmPaymentRequest
    {
        public string PaymentIntentId { get; set; }
        public int OrderId { get; set; }
    }
}
