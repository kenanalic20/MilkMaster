namespace MilkMaster.Application.DTOs
{
    public class OrderItemsDto
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public string ProductTitle { get; set; }
        public int Quantity { get; set; }
        public decimal UnitSize { get; set; }
        public int UnitId { get; set; }
        public string UnitName { get; set; }
        public decimal PricePerUnit { get; set; }
        public decimal TotalPrice { get; set; }
    }

    public class OrderItemsCreateDto
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal UnitSize { get; set; }
        public int UnitId { get; set; }
        public decimal PricePerUnit { get; set; }
    }

    public class OrderItemsUpdateDto
    {
        public int Quantity { get; set; }
        public decimal UnitSize { get; set; }
        public int UnitId { get; set; }
        public decimal PricePerUnit { get; set; }
    }
}
