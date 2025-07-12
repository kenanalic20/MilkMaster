using System.Net;
using System.Text.Json;

namespace MilkMaster.API.Middleware
{
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;

        public ExceptionHandlingMiddleware(RequestDelegate next) => _next = next;

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex);
            }
        }

        private static Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            var statusCode = (int)HttpStatusCode.InternalServerError;
            string message = "An unexpected error occurred.";

            switch (exception)
            {
                case UnauthorizedAccessException:
                    statusCode = (int)HttpStatusCode.Forbidden;
                    message = exception.Message;
                    break;

                case ArgumentNullException:
                case ArgumentException:
                    statusCode = (int)HttpStatusCode.BadRequest;
                    message = exception.Message;
                    break;

                case KeyNotFoundException:
                    statusCode = (int)HttpStatusCode.NotFound;
                    message = exception.Message;
                    break;


                default:
                    break;
            }

            context.Response.ContentType = "application/json";
            context.Response.StatusCode = statusCode;

            var result = JsonSerializer.Serialize(new
            {
                error = message,
                statusCode = statusCode
            });

            return context.Response.WriteAsync(result);
        }
    }
}
