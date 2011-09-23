using System;
using System.Net;
using System.Xml;
using Microsoft.Practices.EnterpriseLibrary.Caching;
using Microsoft.Practices.EnterpriseLibrary.Caching.Expirations;

namespace PriyomAPI
{
    public class XmlCache
    {
        private readonly ICacheManager _objCacheManager = CacheFactory.GetCacheManager();

        public ICacheManager Manager()
        {
            return _objCacheManager;
        }
    }

    public static class GetXmlDoc
    {
        public static ICacheManager _manager1 { get; set; }
        const string Server = "http://api.priyom.org/api/";
        public static XmlDocument Getme(string url)
        {
            if (!_manager1.Contains(url))
            {
                //if we don't have the key in the database go get it
                GetIntoCache(url);
            }
            else
            {
                Refreshcache(url);
            }
            var priyomDoc = (PriyomDoc)_manager1.GetData(url);
            var doc = priyomDoc.Document;
            return doc;

        }
        private static void Refreshcache(string url)
        {
            try
            {
                var priyomDoc = (PriyomDoc)_manager1.GetData(url);
                var lastmodified = priyomDoc.LastModified;
                var doc = priyomDoc.Document;
                var fullrequesturl = Server + url;
                var request = (HttpWebRequest)WebRequest.Create(fullrequesturl);
                request.IfModifiedSince = Convert.ToDateTime(lastmodified);
                var response = (HttpWebResponse)request.GetHttpResponse();
                var headers = response.Headers;
                var status = response.StatusCode;
                switch (status)
                {
                    case HttpStatusCode.NotModified:
                        //no need to update
                        break;
                    case HttpStatusCode.OK:
                        {
                            //refresh the cache and reload the doc
                            doc.Load(response.GetResponseStream());
                            var lastmodified2 = headers["Last-Modified"];
                            var priyomDoc2 = new PriyomDoc { Url = url, Document = doc, LastModified = lastmodified };
                            _manager1.Add(url, priyomDoc2);
                            break;
                        }
                    default:
                        {
                            break;
                        }
                }
            }
            catch (Exception ex)
            {

                throw new Exception("Failed to load requested data: " + ex.Message, ex.InnerException);
            }
        }

        private static void GetIntoCache(string url)
        {
            try
            {
                var doc = new XmlDocument();
                var fullrequesturl = Server + url;
                var request = (HttpWebRequest)WebRequest.Create(fullrequesturl);
                var response = (HttpWebResponse)request.GetHttpResponse();
                var headers = response.Headers;
                var status = response.StatusCode;
                switch (status)
                {
                    case HttpStatusCode.OK:
                        {
                            doc.Load(response.GetResponseStream());
                            var lastmodified = headers["Last-Modified"];
                            var priyomDoc = new PriyomDoc { Url = url, Document = doc, LastModified = lastmodified };
                            _manager1.Add(url, priyomDoc);
                            break;
                        }
                    case HttpStatusCode.NotFound:
                        {
                            throw new Exception("404");
                        }
                    default:
                        {
                            throw new Exception("Other failure");
                        }
                }

            }
            catch (Exception ex)
            {
                throw new Exception("Failed to load requested data: " + ex.Message, ex.InnerException);
            }

        }
    }
    public class PriyomDoc
    {
        public XmlDocument Document { get; set; }

        public string LastModified { get; set; }

        public string Url { get; set; }
    }
    public static class Request
    {
        //TO OVERIDE DEFAULT 304 EXCEPTION HANDLING
        public static HttpWebResponse GetHttpResponse(this HttpWebRequest request)
        {
            try
            {
                return (HttpWebResponse)request.GetResponse();
            }
            catch (WebException ex)
            {
                if (ex.Response == null || ex.Status != WebExceptionStatus.ProtocolError)
                    throw;

                return (HttpWebResponse)ex.Response;
            }
        }
    }
}