using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net;
using System.Threading;
using ScreeningONE.DomainModels;
using RestSharp;

namespace ScreeningONE.Objects
{
    public class MailGun
    {
        //Use this method to send to a Billing Contact and lookup the message text from a message template
        public static void SendEmailToClientContactFromTemplate(int _MessageActionType, int _MessageTemplateClientID, string _MessageTemplateName, int _ClientID, int _ToClientContactID, int _FromUserID,
            string _Subject, Dictionary<string, string> _MessageValues)
        {
           // Thread t1 = new Thread(delegate ()
           // {
                //var User = Users.GetUserFromUserID(_ToUserID);
                var ClientContact = ClientContacts.GetClientContactFromClientContactID(_ToClientContactID);

                if (ClientContact == null)
                {
                    return; //Error
                }

                string EmailTo = ClientContact.BillingContactEmail;

                if (String.IsNullOrEmpty(EmailTo))
                {
                    return; //Error
                }

                string UserFullName = ClientContact.ClientContactFirstName + " " + ClientContact.ClientContactLastName;

                string FromName = System.Configuration.ConfigurationManager.AppSettings["BillingEmailName"];
                string FromEmail = System.Configuration.ConfigurationManager.AppSettings["BillingEmail"];

                string MessageBody = ScreeningONESendMail.GetMessageTemplate(_MessageTemplateClientID, _MessageTemplateName, _MessageValues);

                int FromUserType = 1;
                if (_FromUserID == 0)
                {
                    FromUserType = 3;
                }

                if (MessageBody != null)
                {
                    Guid? MessageGUID = Messages.AddMessage(_MessageActionType, _Subject, MessageBody, _ToClientContactID, 2, _FromUserID, FromUserType, EmailTo);
                    SendEmailAsScreeningOne(EmailTo, _Subject, MessageBody, true, MessageGUID, UserFullName, FromEmail, FromName);
                }
            //});

            //t1.IsBackground = true;
            //t1.Start();
        }

        //Use this method to send to a UserID and lookup the message text from a message template
        public static void SendEmailToUserFromTemplate(int _MessageActionType, int _MessageTemplateClientID, string _MessageTemplateName, int _ClientID, int _ToUserID, int _FromUserID,
            string _Subject, Dictionary<string, string> _MessageValues)
        {
            // Thread t1 = new Thread(delegate ()
            // {
            var User = Security.GetUserFromUserID(_ToUserID);

            string EmailTo = User.LoweredEmail;

            if (String.IsNullOrEmpty(EmailTo))
            {
                return; //Error
            }

            string UserFullName = User.UserFirstName + " " + User.UserLastName;

            string FromName = System.Configuration.ConfigurationManager.AppSettings["BillingEmailName"];
            string FromEmail = System.Configuration.ConfigurationManager.AppSettings["BillingEmail"];

            string MessageBody = ScreeningONESendMail.GetMessageTemplate(_MessageTemplateClientID, _MessageTemplateName, _MessageValues);

            int FromUserType = 1;
            if (_FromUserID == 0)
            {
                FromUserType = 3;
            }

            if (MessageBody != null)
            {
                Guid? MessageGUID = Messages.AddMessage(_MessageActionType, _Subject, MessageBody, _ToUserID, 1, _FromUserID, FromUserType, EmailTo);
                SendEmailAsScreeningOne(EmailTo, _Subject, MessageBody, true, MessageGUID, UserFullName, FromEmail, FromName);
            }
            //});

            //t1.IsBackground = true;
            //t1.Start();
        }

        //Use this method to send to an email address, but lookup the message text from a message template
        public static void SendEmailToEmailAddressFromTemplate(int _MessageActionType, int _MessageTemplateClientID, string _MessageTemplateName, int _ClientID, string _ToEmailAddress,
            string _Subject, string _ToName, Dictionary<string, string> _MessageValues)
        {
            Thread t1 = new Thread(delegate ()
            {
                if (String.IsNullOrEmpty(_ToEmailAddress))
                {
                    return; //Error
                }

                string FromName = System.Configuration.ConfigurationManager.AppSettings["BillingEmailName"];
                string FromEmail = System.Configuration.ConfigurationManager.AppSettings["BillingEmail"];

                string MessageBody = ScreeningONESendMail.GetMessageTemplate(_MessageTemplateClientID, _MessageTemplateName, _MessageValues);

                if (MessageBody != null)
                {
                    SendEmailToEmailAddressAsScreeningOne(_MessageActionType, _ClientID, _ToEmailAddress, _Subject, MessageBody, _ToName, FromEmail, FromName);
                }
            });

            t1.IsBackground = true;
            t1.Start();
        }

        //Use this method to send to an email address when you don't need to lookup the message text from a message template
        public static void SendEmailToEmailAddressAsScreeningOne(int _MessageActionType, int _ClientID, string _ToEmailAddress, string _Subject, string _Message,
            string _ToName, string _FromEmail, string _FromName)
        {
            Guid? MessageGUID = Messages.AddMessage(_MessageActionType, _Subject, _Message, 0, 3, 0, 3, _ToEmailAddress);
            SendEmailAsScreeningOne(_ToEmailAddress, _Subject, _Message, true, MessageGUID, _ToName, _FromEmail, _FromName);
        }
        
        //DO NOT CALL THIS METHOD!
        public static void SendEmailAsScreeningOne(string to, string subject, string body, bool IsBodyHtml, Guid? MessageGUID, string ToName,
            string FromEmail, string FromName)
        {
            RestClient client = new RestClient();
            client.BaseUrl = new Uri(System.Configuration.ConfigurationManager.AppSettings["MailGunBaseURL"]);
            client.Authenticator =
                   new RestSharp.Authenticators.HttpBasicAuthenticator("api",
                                              System.Configuration.ConfigurationManager.AppSettings["MailGunApiKey"]);
            RestRequest request = new RestRequest();
            request.AddParameter("domain",
                                System.Configuration.ConfigurationManager.AppSettings["MailGunEmailDomain"], ParameterType.UrlSegment);
            request.Resource = "/messages";
            request.AddParameter("from", String.Format("{0} <{1}>", FromName, FromEmail));
           // request.AddParameter("cc", String.Format("{0} <{1}>", FromName, FromEmail));
            request.AddParameter("to", String.Format("{0} <{1}>", ToName, to));
            request.AddParameter("subject", subject);
            request.AddParameter("html", body);

            if (MessageGUID.HasValue)
            {
                request.AddParameter("v:my-custom-data", "{ \"MessageGUID\": \"" + MessageGUID.Value.ToString() + "\"}");
            }
            request.Method = Method.POST;
            client.Execute(request);
        }

    }
}