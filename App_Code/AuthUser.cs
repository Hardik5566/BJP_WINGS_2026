using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;

/// <summary>
/// Summary description for AuthUser
/// </summary>
public class AuthUser : System.Web.Services.Protocols.SoapHeader
{

    public string UserName { get; set; }
    public string Password { get; set; }
    public string Token { get; set; }

    public bool IsValid()
    {
        bool result = false;
        if (UserName == "Election@2026" && Password == "2026#2026" && Token == "Elect@2026#")
        {
            result = true;
        } 
        return result;
    }

}