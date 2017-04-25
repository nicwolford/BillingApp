using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using System.Net.Mail;
using System.Threading;
using System.IO;
using ScreeningONE.Models;
using ScreeningONE.DomainModels;

namespace ScreeningONE.Objects
{
    public static class ScreeningONESendMail
    {

        private static readonly string AdminEmail = ConfigurationManager.AppSettings["adminEmail"];
        private static readonly string AdminName = ConfigurationManager.AppSettings["adminName"];

        public static void SendMailCC(string to, string CC, string subject, string body, bool IsBodyHtml)
        {
            #region no sure what this is
            /*try
            {
                var t1 = new Thread(SendMailAsync);
                t1.Start(new string[] { to, subject, body });
            }
            catch (Exception ex)
            {
                // TODO: exception handling
                Clients.LogAction("INVOICES_SendMail_ErrorCreatingNewThread", "To: " + to + " | Subject: " + subject + " | Exception: " + ex.Message);
            }*/
            #endregion

            try
            {
                var c = new System.Net.NetworkCredential();
                c.Password = "8BB26$7BEB6D^D471981";
                c.UserName = "NoReplyS1_Email@screeningone.com";

                using (MailMessage message = new MailMessage())
                {
                    message.From = new MailAddress(AdminEmail, AdminName);
                    message.To.Add(new MailAddress(to));
                    if (!string.IsNullOrEmpty(CC))
                    {
                        message.CC.Add(CC);
                    }
                    message.Bcc.Add(new MailAddress("noreplys1_email@screeningone.com"));
                    message.Subject = subject;
                    message.Body = body;
                    message.IsBodyHtml = IsBodyHtml;

                    var mailClient = new SmtpClient();
                    mailClient.UseDefaultCredentials = false;
                    mailClient.Credentials = c;
                    mailClient.DeliveryMethod = SmtpDeliveryMethod.Network;
                    mailClient.EnableSsl = true;
                    mailClient.Port = 587;
                    mailClient.Host = "smtp.gmail.com";

                    Clients.LogAction("INVOICES_SendMail_Send", "To: " + to + " | Subject: " + subject);
                    mailClient.Send(message);
                }
            }
            catch (Exception ex)
            {
                // TODO: exception handling
                Clients.LogAction("INVOICES_SendMailAsync_ErrorCreatingEmail", "To: " + to + " | Subject: " + subject + " | Exception: " + ex.Message);
            }
        }

        public static void SendMail(string to, string subject, string body, bool IsBodyHtml)
        {
            #region no sure what this is
            /*try
            {
                var t1 = new Thread(SendMailAsync);
                t1.Start(new string[] { to, subject, body });
            }
            catch (Exception ex)
            {
                // TODO: exception handling
                Clients.LogAction("INVOICES_SendMail_ErrorCreatingNewThread", "To: " + to + " | Subject: " + subject + " | Exception: " + ex.Message);
            }*/
            #endregion

            try
            {
                    var c = new System.Net.NetworkCredential();
                    c.Password = "8BB26$7BEB6D^D471981";
                    c.UserName = "NoReplyS1_Email@screeningone.com";

                    using (MailMessage message = new MailMessage())
                    {
                        message.From = new MailAddress(AdminEmail, AdminName);
                        message.To.Add(new MailAddress(to));
                        message.Bcc.Add(new MailAddress("noreplys1_email@screeningone.com"));
                        message.Subject = subject;
                        message.Body = body;
                        message.IsBodyHtml = IsBodyHtml;

                        var mailClient = new SmtpClient();
                        mailClient.UseDefaultCredentials = false;
                        mailClient.Credentials = c;
                        mailClient.DeliveryMethod = SmtpDeliveryMethod.Network;
                        mailClient.EnableSsl = true;
                        mailClient.Port = 587;
                        mailClient.Host = "smtp.gmail.com";

                        Clients.LogAction("INVOICES_SendMail_Send", "To: " + to + " | Subject: " + subject);
                        mailClient.Send(message);
                    }
            }
            catch (Exception ex)
            {
                // TODO: exception handling
                Clients.LogAction("INVOICES_SendMailAsync_ErrorCreatingEmail", "To: " + to + " | Subject: " + subject + " | Exception: " + ex.Message);
            }
        }

        private static void SendMailAsync(object emailInfo)
        {
            try
            {

                var paramArray = emailInfo as string[];
                if (paramArray != null)
                {
                    var to = paramArray[0];
                    var subject = paramArray[1];
                    var body = paramArray[2];
                    var c = new System.Net.NetworkCredential();
                    c.Password = "8BB26$7BEB6D^D471981";
                    c.UserName = "NoReplyS1_Email@screeningone.com";
                  
                    using (MailMessage message = new MailMessage())
                    {
                        message.From = new MailAddress(AdminEmail,
                                                       AdminName);
                        message.To.Add(new MailAddress(to));
                        message.Bcc.Add(new MailAddress("noreplys1_email@screeningone.com"));
                        message.Subject = subject;
                        message.Body = body;
                        message.IsBodyHtml = false;

                        var mailClient = new SmtpClient();
                        mailClient.UseDefaultCredentials = false;
                        mailClient.Credentials = c;
                        mailClient.DeliveryMethod = SmtpDeliveryMethod.Network;
                        mailClient.EnableSsl = true;
                        mailClient.Port = 587;
                        mailClient.Host = "smtp.gmail.com";

                        mailClient.Send(message);
                    }
                }
            }
            catch (Exception ex)
            {
                // TODO: exception handling
                var paramArray = emailInfo as string[];
                if (paramArray != null && paramArray.Length > 2)
                {
                    var to = paramArray[0];
                    var subject = paramArray[1];
                    Clients.LogAction("INVOICES_SendMailAsync_ErrorCreatingEmail", "To: " + to + " | Subject: " + subject + " | Exception: " + ex.Message);
                }
                else
                {
                    Clients.LogAction("INVOICES_SendMailAsync_ErrorCreatingEmail", "paramArray is NULL | Exception: " + ex.Message);
                }
            }
        }

        public static string GetMessageTemplate(int clientid, string messagetemplatename, Dictionary<string, string> messagevalues)
        {
            var db = new MessagesDataContext();
            var result = db.S1_Messages_GetMessageTemplate(clientid, messagetemplatename).SingleOrDefault();

            if (result != null)
            {
                string body = result.MessageText.ToString();

                foreach (var item in messagevalues)
                {
                    body = body.Replace(item.Key, item.Value);
                }
                
                return body;
            }
            else
            {
                return null;
            }
        }
 
    }
}
