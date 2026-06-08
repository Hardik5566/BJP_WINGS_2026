using System;
using System.Text;
using System.Web.UI;

public partial class GroupChat_GroupChat : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Charset = "utf-8";
        Response.ContentEncoding = Encoding.UTF8;
        Response.HeaderEncoding = Encoding.UTF8;
    }
}
