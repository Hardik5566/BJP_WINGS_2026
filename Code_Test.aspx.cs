using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Code_Test : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

        DataSet ds = BAL_Voter.master_search("1", "priya", "", "", "", "");


        //string message = "";
        //string OTP = General_Class.generat_otp();
        ////string OTP = "000000";
        //message += "Dear Customer, Your OTP for CQPPLE app login is " + OTP;
        //General_Class.send_sms("9558001712", message);

        //string captchaText = GenerateRandomText();
        //Session["CaptchaCode"] = captchaText;

        //Bitmap bmp = new Bitmap(150, 40);
        //Graphics g = Graphics.FromImage(bmp);

        //g.Clear(Color.White);
        //Font font = new Font("Arial", 20, FontStyle.Bold);
        //g.DrawString(captchaText, font, Brushes.Black, 10, 5);

        //Response.ContentType = "image/jpeg";
        //bmp.Save(Response.OutputStream, ImageFormat.Jpeg);

        //g.Dispose();
        //bmp.Dispose();
    }

    private string GenerateRandomText()
    {
        string chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        Random rand = new Random();
        string result = "";

        for (int i = 0; i < 5; i++)
        {
            result += chars[rand.Next(chars.Length)];
        }

        return result;
    }

    
}