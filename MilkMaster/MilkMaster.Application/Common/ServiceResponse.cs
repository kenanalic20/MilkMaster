namespace MilkMaster.Application.Common
{
    public class ServiceResponse<T>
    {
        public T? Data { get; set; }
        public bool Success { get; set; }
        public string? Message { get; set; }
        public int StatusCode { get; set; }
    
        public static ServiceResponse<T> SuccessResponse(T data, string? message = null, int statusCode = 200)
        {
            return new ServiceResponse<T>
            {
                Data = data,
                Success = true,
                Message = message,
                StatusCode = statusCode
            };
        }
    
        public static ServiceResponse<T> FailureResponse(string message, int statusCode = 400)
        {
            return new ServiceResponse<T>
            {
                Success = false,
                Message = message,
                StatusCode = statusCode
            };
        }
    }
}
