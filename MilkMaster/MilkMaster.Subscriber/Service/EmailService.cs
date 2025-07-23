
using System.Net.Mail;
using System.Net;
using MilkMaster.Messages;

namespace MilkMaster.Subscriber.Service
{
    public class EmailService
    {
        private readonly string _smtpHost;
        private readonly int _smtpPort;
        private readonly string _from;
        private readonly string _password;

        public EmailService(string smtpHost, int smtpPort, string from, string password)
        {
            _smtpHost = smtpHost;
            _smtpPort = smtpPort;
            _from = from;
            _password = password;
        }

        public async Task<bool> SendEmailAsync(EmailMessage email)
        {
            try
            {
                using var smtp = new SmtpClient(_smtpHost, _smtpPort)
                {
                    Credentials = new NetworkCredential(_from, _password),
                    EnableSsl = true,
                    DeliveryMethod = SmtpDeliveryMethod.Network
                };

                var mail = new MailMessage(_from, email.Email, email.Subject, email.Body)
                {
                    IsBodyHtml = true
                };

                await smtp.SendMailAsync(mail);
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Email sending failed: {ex.Message}");
                return false;
            }
        }
    }
}
