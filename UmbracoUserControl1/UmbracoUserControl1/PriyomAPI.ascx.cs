using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Practices.EnterpriseLibrary.Caching;
using System.Xml;

namespace PriyomAPI
{
    public partial class UmbracoUserControl2 : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            GetXmlDoc._manager1 = PriyomAPI.Global.manager1;
            var doc1 = GetXmlDoc.Getme("station/1?flags=broadcasts,broadcast-transmissions");
            Xml1.DocumentContent = doc1.InnerXml;

        }
        public XmlDocument GetTheDoc()
        {
            GetXmlDoc._manager1 = PriyomAPI.Global.manager1;
            return GetXmlDoc.Getme("station/1?flags=broadcasts,broadcast-transmissions");

        }
    }
}