using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text.RegularExpressions;

namespace StringExtensions
{
    public static class StringExtensionsClass
    {
        public static string safeHTML(this string _inputString)
        {
            string pattern = @"</?(?i:script|embed|object|frameset|frame|iframe|meta|link|style)(.|\n)*?>";

            return Regex.Replace(_inputString,pattern,"");
        }

        public static string stripHTML(this string _inputString)
        {
            string pattern = @"<(.|\n)*?>";

            return Regex.Replace(_inputString, pattern, "");
        }

        public static string Left(this string s, int count)
        {
            return s.Substring(0, count);
        }

        public static string Right(this string s, int count)
        {
            return s.Substring(s.Length - count, count);
        }

        public static string Mid(this string s, int index, int count)
        {
            return s.Substring(index, count);
        }

        public static int ToInteger(this string s)
        {
            int integerValue = 0;
            int.TryParse(s, out integerValue);
            return integerValue;
        }

        public static bool IsInteger(this string s)
        {
            Regex regularExpression = new Regex("^-[0-9]+$|^[0-9]+$");
            return regularExpression.Match(s).Success;
        }

        public static string cleanFileName(this string _inputString)
        {
            string temp = String.IsNullOrEmpty(_inputString) ? "" : _inputString;

            foreach (char c in System.IO.Path.GetInvalidFileNameChars())
            {
                temp = temp.Replace(c.ToString(), "");
            }

            temp = temp.Trim();

            return temp;
        }

        public static string SingleSpaceOnly(this string _inputString)
        {
            string temp = _inputString.Replace("  ", " ");
            while (temp != temp.Replace("  ", " "))
            {
                temp = temp.Replace("  ", " ");
            }
            temp = temp.Trim();
            return temp;
        }

    }
}
