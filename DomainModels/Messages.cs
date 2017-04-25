using ScreeningONE.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;

namespace ScreeningONE.DomainModels
{
    public class Messages
    {
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

        public static S1_Messages_GetMessageTemplateRecordResult GetMessageTemplateRecord(int clientid, string messagetemplatename, Dictionary<string, string> messagevalues)
        {
            var db = new MessagesDataContext();
            var result = db.S1_Messages_GetMessageTemplateRecord(clientid, messagetemplatename).SingleOrDefault();
            if (result != null)
            {
                string body = result.MessageText;
                foreach (var item in messagevalues)
                {
                    body = body.Replace(item.Key, item.Value);
                }
                result.MessageText = body;
                return result;
            }
            else
            {
                return null;
            }
        }

        public static void CreateMessageWithAction(int? messageactiontype, string messagesubject, string messagetext, int? messageto, int? tocontacttype,
                                                int? messagefrom, int? fromcontacttype, string messageactionpath, DateTime? sentdate, DateTime? receiveddate,
                                                string bodyformat, ref int? messageid, ref Guid? messageguid)
        {
            using (MessagesDataContext dc = new MessagesDataContext())
            {
                dc.S1_Messages_CreateMessageWithAction(messageactiontype, messagesubject, messagetext, messageto, tocontacttype,
                                                       messagefrom, fromcontacttype, messageactionpath, sentdate, receiveddate, bodyformat, ref messageid,
                                                       ref messageguid);
            }
        }

        public static void UpdateMessageAndMarkForSending(int? messageid, string messagesubject, string messagetext)
        {
            using (MessagesDataContext dc = new MessagesDataContext())
            {
                dc.S1_Messages_UpdateMessageAndMarkForSending(messageid, messagesubject, messagetext);
            }

        }

        public static Guid? AddMessage(int _MessageActionTypeID, string _MessageSubject, string _MessageText, int _MessageTo, int _ToContactType, int _MessageFrom,
            int _FromContactType, string _EmailAddressTo)
        {
            Guid? MessageGUID = new Guid?();

            using (MessagesDataContext dc = new MessagesDataContext())
            {
                dc.S1_Messages_AddMessage(_MessageActionTypeID, _MessageSubject, _MessageText, _MessageTo, _ToContactType, _MessageFrom,
                    _FromContactType, _EmailAddressTo, ref MessageGUID);
            }

            return MessageGUID;
        }

        /*
         * Status:
         * 0 = Draft
         * 1 = Waiting to be Sent
         * 2 = Sent
         * 3 = Error
        */
    }
}