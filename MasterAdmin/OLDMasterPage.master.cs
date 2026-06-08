using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MasterPage : System.Web.UI.MasterPage
{


    protected void Page_Init(object sender, EventArgs e)
    {
        try
        {

            //if (!IsPostBack)
            //{

            //    if (Request.Cookies["user_id"] != null)
            //    {
            //        string userId = Request.Cookies["user_id"].Value;
                   
            //        Session["user_id"] = userId;
            //    }
            //    else
            //    {
            //        Response.Redirect("Default.aspx");
            //    }
            //}

        }
        catch (Exception)
        {

            throw;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
}
