<%@ WebHandler Language="C#" Class="handle" %>

using System;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Linq;
using System.Xml.Linq;
using System.Text;
using System.Xml.XPath;

public class handle : IHttpHandler {
    public class groups {
        public string name;
        public string special;
        public string defined;
        public string group_pic_url;
        public IEnumerable<XElement> islands;
        public groups(XElement e) {
            this.name = e.Element("name").Value.ToString();
            this.special = e.Element("special").Value.ToString();
            this.defined = e.Element("defined").Value.ToString();
            this.group_pic_url = e.Element("group-pic-url").Value.ToString();
            this.islands = e.Element("islands").Elements("island");
        }
    }
    public class islandClass
    {
        public string island_pic_url;
        public string island_name_en;
        public string island_name_zh;
        public string className;
        public string location_zh;
        public string location_en;
        public string rooms;
        public string distance;
        public string price_one;
        public string chinese;
        public islandClass(XElement e)
        {
            this.island_pic_url = e.Element("island-pic-url").Value.ToString();
            this.island_name_en = e.Element("island-name-en").Value.ToString();
            this.island_name_zh = e.Element("island-name-zh").Value.ToString();
            this.className = e.Element("class").Value.ToString();
            this.location_zh = e.Element("location-zh").Value.ToString();
            this.location_en = e.Element("location-en").Value.ToString();
            this.rooms = e.Element("rooms").Value.ToString();
            this.distance = e.Element("distance").Value.ToString();
            this.price_one = e.Element("price-one").Value.ToString();
            this.chinese = e.Element("chinese").Value.ToString();
        }
    }
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        context.Request.ContentEncoding = Encoding.GetEncoding("utf-8");
        context.Response.ContentEncoding = Encoding.GetEncoding("utf-8");
        var page = Convert.ToInt16(context.Request.Form["pageIdx"]);
        //var key = context.Request.Form["key"].Trim() != null ? HttpUtility.UrlDecode(context.Request.Form["key"].Trim()) : "*";
        var key = "*";
        try
        {
            key = HttpUtility.UrlDecode(context.Request.Form["key"].Trim());
            if (key == "")
                key = "*";
        }
        catch
        {
            key = "*";
        }
        //var keyString = context.Request.Form["key"];
        string xmlPath = "/subject/140227_mdv_hotels/data/hotel-data.xml";
        int gt=page*4;
        int lt=page*4+4;
        try
        {
            var data = XDocument.Load(context.Server.MapPath(xmlPath));
            var root = data.Element("root");
            IEnumerable<XElement> result=null;
            if (key == "*")
            {
                result = root.XPathSelectElements("/root/group[position()>" + gt + " and position()<=" + lt + "]");
            }
            else {
                var searchKey = from g in root.Elements("group")
                                from island in g.Element("islands").Elements("island")
                                where g.Element("name").Value.ToLower().Contains(key.ToLower()) || island.Element("island-name-en").Value.ToLower().Contains(key.ToLower()) || island.Element("island-name-zh").Value.ToLower().Contains(key.ToLower()) || island.Element("location-zh").Value.ToLower().Contains(key.ToLower()) || island.Element("location-en").Value.ToLower().Contains(key.ToLower())
                                select g;
                XElement tepl = new XElement("root", searchKey);
                result = tepl.XPathSelectElements("/group[position()>" + gt + " and position()<=" + lt + "]");
                //tepl = new XElement("");
            }
            String resultHTML="Null";
            foreach(var item in result){
                    var group = new groups(item);
                    if (resultHTML == "Null")
                        resultHTML = "";
                    resultHTML += "<div class=\"group layout\">";
                    resultHTML += "<div class=\"lfColumn\">";
                    resultHTML += "<dt><img src=\"" + group.group_pic_url + "\" alt=\"" + group.name + "\" title=\"" + group.name + " width=\"147\" height=\"147\"\"/></dt></div>";
                    resultHTML += "<div class=\"rgColumn mainCont\"><div class=\"intro\">";

                    resultHTML += "<h1 class=\"summary keyword\">" + group.name + "</h1>";
                    resultHTML += "<div class=\"block\"><div class=\"title18\"><h4>行程特色</h4></div>";
                    resultHTML += group.special.Replace("[p]", "<p>").Replace("[/p]", "</p>");
                    resultHTML += "</div><div class=\"block\"><div class=\"title18\"><h4>酒店集团说明</h4></div>";
                    resultHTML += group.defined.Replace("[p]", "<p>").Replace("[/p]", "</p>"); ;
                    resultHTML += "</div></div>";
                    resultHTML += "<div class=\"islands\">";
                    foreach (XElement island in group.islands)
                    {
                        var _island = new islandClass(island);
                        resultHTML += "<div class=\"islands_detail layout\">";
                        resultHTML += "<div class=\"lfColumn\"><img width=\"126\" height=\"126\" src=\"" + _island.island_pic_url + "\" alt=\"\"/></div>";
                        resultHTML += "<div class=\"rgColumn\"><h4 class=\"keyword\">" + _island.island_name_en + "</h4><p class=\"keyword\">" + _island.island_name_zh + "</p>";
                        resultHTML += "<div class=\"detail layout\">";
                        resultHTML += "<dl><dt>岛屿级别：</dt><dd>" + _island.className + "</dd><dt>所属环礁：</dt><dd><p class=\"keyword\">" + _island.location_zh + "</p><p class=\"keyword\">" + _island.location_en + "</p></dd></dl>";
                        resultHTML += "<dl><dt>房间总数：</dt><dd>" + _island.rooms + "</dd><dt>距离马累：</dt><dd>" + _island.distance + "</dd></dl>";
                        resultHTML += "<dl><dt>一价全包：</dt><dd>" + _island.price_one + "</dd><dt>中文服务：</dt><dd>" + _island.chinese + "</dd></dl>";
                        resultHTML += "</div></div></div>";
                    }
                    resultHTML += "</div></div></div>";
            }
            context.Response.Write(resultHTML);
        }
        catch (ArgumentException ex)
        {
            context.Response.Write("Null");
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}