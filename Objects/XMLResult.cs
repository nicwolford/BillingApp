using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ScreeningONE.Objects
{
    public class XmlResult : ActionResult
    {
        private string outputXML;

        /// <summary> 
        /// Initializes a new instance of the <see cref="XmlResult"/> class. 
        /// </summary> 
        /// <param name="objectToSerialize">The object to serialize to XML.</param> 
        public XmlResult(string _OutputXML)
        {
            this.outputXML = _OutputXML;
        }

        /// <summary> 
        /// Gets the object to be serialized to XML. 
        /// </summary> 
        public object OutputXML
        {
            get { return this.outputXML; }
        }

        /// <summary> 
        /// Serialises the object that was passed into the constructor to XML and writes the corresponding XML to the result stream. 
        /// </summary> 
        /// <param name="context">The controller context for the current request.</param> 
        public override void ExecuteResult(ControllerContext context)
        {
            if (!string.IsNullOrEmpty(this.outputXML))
            {
                context.HttpContext.Response.Clear();
                //var xs = new System.Xml.Serialization.XmlSerializer(this.objectToSerialize.GetType());
                context.HttpContext.Response.ContentType = "text/xml";
                //xs.Serialize(context.HttpContext.Response.Output, this.objectToSerialize);
                context.HttpContext.Response.Output.Write("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
                context.HttpContext.Response.Output.Write(outputXML);
            }
        }
    } 
}

