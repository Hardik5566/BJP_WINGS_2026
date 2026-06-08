using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using static System.Net.WebRequestMethods;

/// <summary>
/// Summary description for WebService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class WebService : System.Web.Services.WebService
{
    string result = "{\"Success\":\"1\",\"result\":";
    string fail_result = "{\"Success\":\"0\"}";
    public AuthUser User;
    string server_url = "";

    public WebService()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string display_admin(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {

                DataSet ds = BAL_Admin.display_admin(app_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string display_sub_admin(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {

                DataSet ds = BAL_Admin.display_sub_admin(app_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string display_karyakarta(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {

                DataSet ds = BAL_Admin.display_karyakarta(app_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string insert_user(string app_id, string name, string mobile_no, string user_type, string booth_no, string booth_list, string start_voter_no, string end_voter_no, string create_by)
    {
        if (User == null) return "Please Provide User Detail";
        if (!User.IsValid()) return "Invalid User";

        try
        {
            DataSet ds = BAL_Admin.insert_user(app_id, name, mobile_no, user_type, booth_no, booth_list, start_voter_no, end_voter_no, create_by);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                string statusCode = ds.Tables[0].Rows[0]["SuccessCode"].ToString();

                if (statusCode == "2")
                {
                    // User Exists: Return Success 2
                    return "{\"Success\":\"2\",\"Message\":\"User Already Exists\"}";
                }
                else if (statusCode == "1")
                {
                    // New User Inserted: Use your global result variable
                    // Result becomes: {"Success":"1","result":[...]}
                    return result + JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                }
            }

            return fail_result;
        }
        catch (Exception)
        {
            return fail_result;
        }
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string update_user(
    string user_id,
    string app_id,
    string name,
    string mobile_no,
    string user_type,
    string booth_no,
    string booth_list,
    string start_voter_no, string end_voter_no,
    string modify_by
)
    {
        string result = "";

        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.upd_user(
                    user_id,
                    app_id,
                    name,
                    mobile_no,
                    user_type,
                    booth_no,
                    booth_list,
                    start_voter_no,
                    end_voter_no,
                    modify_by
                );

                if (ds != null && ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        int spResult = Convert.ToInt32(ds.Tables[0].Rows[0]["result"]);

                        if (spResult == 1)
                        {
                            result = "{\"Success\":\"1\",\"Message\":\"User updated successfully\"}";
                        }
                        else if (spResult == -1)
                        {
                            result = "{\"Success\":\"2\",\"Message\":\"Mobile number already exists\"}";
                        }
                        else
                        {
                            result = fail_result;
                        }
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string user_login(string mobile_no, string is_login, string device_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.user_login(mobile_no, device_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        DataColumn dcm_otp = new DataColumn("otp");

                        if (is_login == "1")
                        {
                            string message = "";
                            string OTP = General_Class.generat_otp();
                            //string OTP = "000000";
                            message += "Dear Customer, Your OTP for CQPPLE app login is " + OTP;
                            General_Class.send_sms(mobile_no, message);

                            dcm_otp.DefaultValue = OTP;
                        }
                        else
                        {
                            dcm_otp.DefaultValue = "";
                        }

                        ds.Tables[0].Columns.Add(dcm_otp);

                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_pramukh_and_total_booth_list(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_pramukh_and_total_booth_list(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_pramukh(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_pramukh(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_captain(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_captain(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string sel_user(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.sel_user(app_id, user_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_total_booth(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_total_booth(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_saktikendra(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_saktikendra(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_party_cadre_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_party_cadre_dash(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_personal_cadre_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_personal_cadre_dash(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_cadre_dash(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_cadre_dash(app_id, user_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_war_pramukh(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_war_pramukh(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dlt_user(string user_id, string delete_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dlt_user(user_id, delete_by);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_call_center_user(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_call_center_user(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_list_for_sakti_creation(string app_id, string type)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_list_for_sakti_creation(app_id, type);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string master_search(string app_id, string f_name, string m_name, string surname, string mobile_no, string id_card_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.master_search(app_id, f_name, m_name, surname, mobile_no, id_card_no);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string speak_and_search_sp(string app_id, string search)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.speak_and_search_sp(app_id, search);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string scan_and_search(string app_id, string id_card_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.scan_and_search(app_id, id_card_no);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string age_wise_search(string app_id, string from_age, string to_age)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.age_wise_search(app_id, from_age, to_age);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_all_surname(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.dis_all_surname(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_all_match_surname_list(string app_id, string search_input)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.get_all_match_surname_list(app_id, search_input);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string surname_wise_search(string app_id, string surname_list)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.surname_wise_search(app_id, surname_list);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_all_polling_location(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.dis_all_polling_location(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_polling_location_wise_voter(string app_id, string polling_location)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.dis_polling_location_wise_voter(app_id, polling_location);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_search(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.dis_booth_wise_search(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_pramukh_cadre_with_voter(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_pramukh_cadre_with_voter(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_captain_cadre_with_voter(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_captain_cadre_with_voter(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_captain_cadre(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_captain_cadre(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_captain_voter(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_captain_voter(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_pramukh_cadre(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_pramukh_cadre(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string display_booth_pramukh_by_sakti_pramuk(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.display_booth_pramukh_by_sakti_pramuk(app_id, user_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_all_user(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_all_user(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string add_contact_group_member(string app_id, string user_id, string contact_no_list)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Phonebook.add_contact_group_member(app_id, user_id, contact_no_list);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_all_contact_match_admin(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Phonebook.dis_all_contact_match_admin(app_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_contact_group_member(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Phonebook.dis_contact_group_member(app_id, user_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_my_group(string app_id, string user_id, string idcard)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_My_Voter.ins_my_group(app_id, user_id, idcard);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_my_group_member(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_My_Voter.dis_my_group_member(app_id, user_id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string del_my_group_member(string id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_My_Voter.del_my_group_member(id);

                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_prachar_master(
    string app_id,
    string prachar_type,
    string base64,
    string content,
    string create_by
)
    {
        if (User != null)
        {
            if (User.IsValid())
            {

                // Only IMAGE / SELFIE / SLEEP use base64
                if ((prachar_type == "IMAGE" || prachar_type == "SELFIE" || prachar_type == "SLEEP" || prachar_type == "AUDIO" || prachar_type == "PRINT") && base64 != "")
                {
                    content = General_Class.save_file_from_base64(content, base64, Server.MapPath("img/prachar/"));
                }

                DataSet ds = BAL_Prachar_Setting.ins_prachar_master(
                    app_id,
                    prachar_type,
                    content,
                    create_by
                );

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_prachar_master(
    string app_id,
    string prachar_type
)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar_Setting.dis_prachar_master(
                    app_id,
                    prachar_type
                );

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string del_prachar_master(
    string app_id,
    string id,
    string delete_by
)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar_Setting.del_prachar_master(
                    app_id,
                    id,
                    delete_by
                );

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }



    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_user_list_by_create_group(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_My_Voter.dis_user_list_by_create_group(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_surname_group(
        string app_id,
        string user_id,
        string group_name,
        string seed_surname,
        string surname_list,
        string idcard_list,
        string create_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Surname_Group.ins_surname_group(
                    app_id,
                    user_id,
                    group_name,
                    seed_surname,
                    surname_list,
                    idcard_list,
                    create_by);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string upd_surname_group(
        string app_id,
        string user_id,
        string group_id,
        string group_name,
        string seed_surname,
        string surname_list,
        string idcard_list,
        string modify_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Surname_Group.upd_surname_group(
                    app_id,
                    user_id,
                    group_id,
                    group_name,
                    seed_surname,
                    surname_list,
                    idcard_list,
                    modify_by);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_my_surname_group(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Surname_Group.dis_my_surname_group(app_id, user_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_surname_group_wise_voter(string app_id, string user_id, string group_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Surname_Group.dis_surname_group_wise_voter(app_id, user_id, group_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_surname_group_edit(string app_id, string user_id, string group_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Surname_Group.dis_surname_group_edit(app_id, user_id, group_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dlt_surname_group(string app_id, string user_id, string group_id, string delete_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Surname_Group.dlt_surname_group(app_id, user_id, group_id, delete_by);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string insert_surname_group(string app_id, string user_id, string surname_list)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Surname_Group.insert_surname_group(app_id, user_id, surname_list);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string display_surname_group(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Surname_Group.display_surname_group_sp(app_id, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string display_surname_match_admin(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Surname_Group.display_surname_match_admin(app_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_no_phonebook_match_user(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Phonebook.dis_no_phonebook_match_user(app_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_phonebook(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Phonebook.dis_booth_wise_phonebook(app_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_phonebook_member(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Phonebook.dis_booth_wise_phonebook_member(app_id, booth_no);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_admin_dash(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_admin_dash(app_id, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + ",";
                        result += "\"result3\":" + JsonConvert.SerializeObject(ds.Tables[2]) + ",";
                        result += "\"result4\":" + JsonConvert.SerializeObject(ds.Tables[3]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string change_profile_photo(string user_id, string photo, string base64)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                if (base64 != "")
                {
                    photo = General_Class.save_file_from_base64(photo, base64, Server.MapPath("img/admin/"));
                }
                DataSet ds = BAL_Admin.change_profile_photo(user_id, photo);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string user_login_for_splace(string app_id, string user_id, string device_id)
    {
        string fallback_success = "{\"Success\":\"1\",\"result\":[{\"status\":\"1\"}],\"result2\":[]}";

        if (User != null)
        {
            if (User.IsValid())
            {

                DataSet ds = BAL_Admin.user_login_for_splace(app_id, user_id, device_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }

            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string print_receipt_in_printer(string app_id, string voter_id, string idcard_no, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.print_receipt_in_printer(app_id, voter_id, idcard_no, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string print_bulk_receipt_in_printer(string app_id, string booth_no, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.print_bulk_receipt_in_printer(app_id, booth_no, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_receipt_in_all_family_for_wtsp(string app_id, string voter_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.get_receipt_in_all_family_for_wtsp(app_id, voter_id, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_receipt_in_single_for_wtsp(string app_id, string voter_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.get_receipt_in_single_for_wtsp(app_id, voter_id, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_family_member(string app_id, string voter_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.dis_family_member(app_id, voter_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_receipt_in_all_family_for_sms(string app_id, string voter_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.get_receipt_in_all_family_for_sms(app_id, voter_id, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_receipt_in_single_for_sms(string app_id, string voter_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.get_receipt_in_single_for_sms(app_id, voter_id, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_prachar_with_log(string app_id, string user_id, string prachar_type, string idcard)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.dis_prachar_with_log(app_id, user_id, prachar_type, idcard);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_log(string app_id, string user_id, string prachar_type, string idcard)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.ins_log(app_id, user_id, prachar_type, idcard);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_live_voting_user(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_live_voting_user(app_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string change_user_temp_status(string app_id, string user_id, string modify_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.change_user_temp_status(app_id, user_id, modify_by);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_voter_survey(string app_id,
    string voter_idcard,
    string booth_no,
    string survey_by,
    string survey_by_designation,
    string voter_available,
    string not_available_reason,
    string not_available_note,
    string contact_no,
    string voter_status,
    string note,
    string lat_long,
    string visit_location)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.ins_voter_survey(app_id,
    voter_idcard,
    booth_no,
    survey_by,
    survey_by_designation,
    voter_available,
    not_available_reason,
    not_available_note,
    contact_no,
    voter_status,
    note,
    lat_long,
    visit_location);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_survey_dash_for_admin(string app_id, string survey_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_survey_dash_for_admin(app_id, survey_by);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_survey_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_booth_wise_survey_dash(app_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_user_wise_survey_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_user_wise_survey_dash(app_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_user_type_wise_survey_dash(string app_id, string type)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_user_type_wise_survey_dash(app_id, type);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string GetAIElectionData(string user_question, string app_id)
    {
        if (User == null || !User.IsValid()) return "Invalid User";

        try
        {
            // Use Task.Run to execute the async method from your sync web service
            string generatedSql = Task.Run(async () => await AIQueryEngine.GetGeneratedSql(user_question, app_id)).Result;

            DataTable dt = ExecuteAndBind(generatedSql);

            if (dt.Rows.Count > 0)
            {
                return "{\"status\":\"1\", \"data\":" + JsonConvert.SerializeObject(dt) + "}";
            }
            return "{\"status\":\"0\", \"message\":\"No data found\"}";
        }
        catch (Exception ex)
        {
            // Handle inner exceptions from Task.Run
            //return "{\"status\":\"0\", \"message\":\"" + (ex.InnerException != null ? ex.InnerException.Message : ex.Message) + "\"}";

            return "{\"status\":\"0\", \"message\":\"I’m sorry, I didn’t quite understand that. Could you explain it a bit more?\"}";
        }
    }

    private DataTable ExecuteAndBind(string sql)
    {
        using (SqlConnection conn = connection.open_connection())
        {
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            DataTable dt = new DataTable();
            da.Fill(dt);
            return dt;
        }
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_family_slip_photo_with_log(string app_id, string voter_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.get_family_slip_photo_with_log(app_id, voter_id, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_slip_photo_with_log(string app_id, string voter_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.get_slip_photo_with_log(app_id, voter_id, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_star_karykarta(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_star_karykarta(app_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_scheme()
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_scheme();

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_community()
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_community();

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_caste()
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_caste();

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_scheme_community_caste_data()
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_scheme_community_caste_data();
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + ",";
                        result += "\"result3\":" + JsonConvert.SerializeObject(ds.Tables[2]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string view_star_karykarta_detail(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.view_star_karykarta_detail(app_id, user_id);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_cast_wise_survey_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_cast_wise_survey_dash(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_community_wise_survey_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_community_wise_survey_dash(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_scheme_wise_survey_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_scheme_wise_survey_dash(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_ration_card_wise_survey_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_ration_card_wise_survey_dash(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_date_wise_survey_dash(string app_id, string month)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_date_wise_survey_dash(app_id, month);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_voter_survey_count_by_month(string app_id, string month)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.get_voter_survey_count_by_month(app_id, month);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_voter_survey_count_by_month_only_call_center(string app_id, string month)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.get_voter_survey_count_by_month_only_call_center(app_id, month);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_phonebook_wise_survey_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_phonebook_wise_survey_dash(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_phonebook_wise_Survey_voter(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_phonebook_wise_Survey_voter(app_id, user_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_analytics_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.dis_analytics_dash(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + ",";
                        result += "\"result3\":" + JsonConvert.SerializeObject(ds.Tables[2]) + ",";
                        result += "\"result4\":" + JsonConvert.SerializeObject(ds.Tables[3]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_post(string app_id, string userId, string content, string mediaListJson)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataTable mediaList = new DataTable();
                if (mediaListJson != "")
                {
                    mediaList = JsonConvert.DeserializeObject<DataTable>(mediaListJson);
                }


                // 1. Save media files from base64 (if any)
                DataTable dt_media = new DataTable();
                dt_media.Columns.AddRange(new DataColumn[] { new DataColumn("media_type", typeof(string)), new DataColumn("media_url", typeof(string)) });
                foreach (DataRow row in mediaList.Rows)
                {
                    string mediaType = row["media_type"].ToString(); // "image", "file", "youtube"
                    string mediaBase64 = row["media_base64"].ToString(); // For image/file
                    string mediaUrl = row["media_url"].ToString(); // For YouTube or already uploaded files


                    dt_media.Rows.Add(mediaType, mediaUrl);

                    //if (!string.IsNullOrEmpty(mediaBase64))
                    //{
                    //    // Save the file and update the media_url in the DataTable
                    //    string savedFile = General_Class.save_file_from_base64(
                    //        row["media_name"].ToString(),
                    //        mediaBase64,
                    //        Server.MapPath("img/post/")
                    //    );
                    //    row["media_url"] = savedFile;

                    //    dt_media.Rows.Add(mediaType, savedFile);

                    //}
                    //else
                    //{
                    //    dt_media.Rows.Add("youtube", "");
                    //}
                }

                // 2. Call the BAL method to insert post + media
                DataSet ds = BAL_Post.ins_post_sp(app_id, userId, content, dt_media);

                // 3. Return JSON result
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string upd_post(string userId, string postId, string content, string mediaListJson)
    {
        if (User != null && User.IsValid())
        {

            DataTable mediaList = new DataTable();
            if (mediaListJson != "")
            {
                mediaList = JsonConvert.DeserializeObject<DataTable>(mediaListJson);
            }

            DataTable dt_media = new DataTable();
            dt_media.Columns.AddRange(new DataColumn[]
{
    new DataColumn("media_type", typeof(string)),
    new DataColumn("media_url", typeof(string))
});

            // Save media files from base64
            foreach (DataRow row in mediaList.Rows)
            {
                string mediaType = row["media_type"].ToString();
                string mediaBase64 = row["media_base64"].ToString();
                string mediaUrl = row["media_url"].ToString();

                if (!string.IsNullOrEmpty(mediaBase64))
                {
                    string savedFile = General_Class.save_file_from_base64(
                        row["media_name"].ToString(),
                        mediaBase64,
                        Server.MapPath("img/post/")
                    );
                    row["media_url"] = savedFile;
                    dt_media.Rows.Add("image", savedFile);
                }
                else
                {
                    dt_media.Rows.Add("youtube", "");
                }
            }

            // Call BAL method
            DataSet ds = BAL_Post.upd_post_sp(userId, postId, content, dt_media);

            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
            }
            else
            {
                result = fail_result;
            }
        }
        else
        {
            return "Invalid User or User not provided";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dlt_post(string userId, string postId)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Post.dlt_post_sp(userId, postId);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string sel_post_by_id(string postId)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Post.sel_post_by_id_sp(postId);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string display_posts(string app_id, string currentUserId, string offset, string fetch)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Post.dis_post_sp(app_id, currentUserId, offset, fetch);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string display_timeline(string app_id, string userId, string offset, string fetch)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Post.dis_post_timeline_sp(app_id, userId, offset, fetch);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dlt_post_media(string media_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Post.dlt_post_media(media_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_user_wise_survey_voter(string app_id, string admin_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_user_wise_survey_voter(app_id, admin_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_survey_voter(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_booth_wise_survey_voter(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_date_wise_survey_voter(string app_id, string date)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_date_wise_survey_voter(app_id, date);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_scheme_wise_survey_voter(string app_id, string scheme_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_scheme_wise_survey_voter(app_id, scheme_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_ration_card_wise_survey_voter(string app_id, string ration_card)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_ration_card_wise_survey_voter(app_id, ration_card);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_commuinity_wise_survey_voter(string app_id, string commuinity_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_commuinity_wise_survey_voter(app_id, commuinity_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_cast_wise_survey_voter(string app_id, string cast_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_cast_wise_survey_voter(app_id, cast_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_death_voter(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_death_voter(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_shifted_out_voter(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_shifted_out_voter(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_wrong_mobile_no_voter(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_wrong_mobile_no_voter(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_call_not_received_voter(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_call_not_received_voter(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_LiveVoting_Dashboard_for_admin(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_LiveVoting.get_LiveVoting_Dashboard_for_admin(app_id, user_id);

                if (ds.Tables.Count > 1)
                {
                    if (ds.Tables[0].Rows.Count > 0 && ds.Tables[1].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_voting_report(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_LiveVoting.dis_booth_wise_voting_report(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_polling_location_wise_voting_report(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_LiveVoting.dis_polling_location_wise_voting_report(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_phonebook_wise_voting_report(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_LiveVoting.dis_phonebook_wise_voting_report(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_live_voting_voter(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_LiveVoting.dis_booth_wise_live_voting_voter(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_polling_location_wise_live_voting_voter(string app_id, string polling_location)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_LiveVoting.dis_polling_location_wise_live_voting_voter(app_id, polling_location);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_phonebook_wise_live_voting_voter(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_LiveVoting.dis_phonebook_wise_live_voting_voter(app_id, user_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    /// <summary>
    /// Bulk live voting insert. json_rows: JSON array as DataTable columns app_id, part_no, slnoinpart (same as ins_post / DeserializeObject).
    /// </summary>
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_live_voting_bulk(string json_rows, string created_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataTable dtRaw = new DataTable();
                if (json_rows != null && json_rows.Trim() != "")
                {
                    try
                    {
                        dtRaw = JsonConvert.DeserializeObject<DataTable>(json_rows.Trim());
                    }
                    catch (Exception)
                    {
                        result = fail_result;
                        return result;
                    }
                }

                DataTable dt = new DataTable();
                dt.Columns.Add("app_id", typeof(int));
                dt.Columns.Add("part_no", typeof(int));
                dt.Columns.Add("slnoinpart", typeof(int));

                if (dtRaw != null && dtRaw.Rows.Count > 0)
                {
                    try
                    {
                        foreach (DataRow r in dtRaw.Rows)
                        {
                            dt.Rows.Add(
                                Convert.ToInt32(r["app_id"], System.Globalization.CultureInfo.InvariantCulture),
                                Convert.ToInt32(r["part_no"], System.Globalization.CultureInfo.InvariantCulture),
                                Convert.ToInt32(r["slnoinpart"], System.Globalization.CultureInfo.InvariantCulture));
                        }
                    }
                    catch (Exception)
                    {
                        result = fail_result;
                        return result;
                    }
                }

                if (dt.Rows.Count == 0)
                {
                    result = fail_result;
                    return result;
                }

                DataSet ds;
                try
                {
                    ds = BAL_LiveVoting.ins_live_voting_bulk_sp(dt, created_by);
                }
                catch (Exception)
                {
                    result = fail_result;
                    return result;
                }

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_total_slip_distribution_count(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.get_total_slip_distribution_count(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string phonebook_wise_slip_sending(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.phonebook_wise_slip_sending(app_id, user_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_phonebook_wise_slip_send_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.dis_phonebook_wise_slip_send_dash(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_slip_send_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.dis_booth_wise_slip_send_dash(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string AllocateUserBalance(string app_id, string user_id, string total_messege, string action_type, string remarks, string create_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Bulk_Wtsp.AllocateUserBalance(app_id, user_id, total_messege, action_type, remarks, create_by);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_wtsp_msg_admin_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Bulk_Wtsp.dis_wtsp_msg_admin_dash(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + ",";
                        result += "\"result3\":" + JsonConvert.SerializeObject(ds.Tables[2]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_wtsp_user_wallets(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Bulk_Wtsp.dis_wtsp_user_wallets(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_list_for_send_bulk_sleep_wtsp(string app_id, string user_id, string type)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Bulk_Wtsp.dis_booth_list_for_send_bulk_sleep_wtsp(app_id, user_id, type);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_voter_survey_log(string app_id, string voter_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_voter_survey_log(app_id, voter_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string sel_survey_detail(string survey_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.sel_survey_detail(survey_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_polling_location_wise_slip_send_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_polling_location_wise_slip_send_dash(app_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string polling_location_wise_slip_sending_voter(string app_id, string polling_location)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.polling_location_wise_slip_sending_voter(app_id, polling_location);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_user_wise_slip_distribution(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_user_wise_slip_distribution(app_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_date_wise_slip_distribution(string app_id, string month)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_date_wise_slip_distribution(app_id, month);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string date_wise_slip_sending_voter(string app_id, string date)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.date_wise_slip_sending_voter(app_id, date);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string master_search_for_slip_send(string app_id, string f_name, string m_name, string surname, string mobile_no, string id_card_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.master_search_for_slip_send(app_id, f_name, m_name, surname, mobile_no, id_card_no);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_my_slip_sending_voter(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_my_slip_sending_voter(app_id, user_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string booth_wise_slip_sending(string app_id, string part_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.booth_wise_slip_sending(app_id, part_no);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_pramukh_by_sakti_pramukh(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_pramukh_by_sakti_pramukh(app_id, user_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_captain_by_warroom_pramukh(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_captain_by_warroom_pramukh(app_id, user_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_slip_send_dash_for_saktikendra(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.dis_booth_wise_slip_send_dash_for_saktikendra(app_id, booth_no);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_saktikendra_survey_dashboard(string app_id, string booth)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_saktikendra_survey_dashboard(app_id, booth);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_all_address(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.dis_all_address(app_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_address_wise_voter(string app_id, string address)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.dis_address_wise_voter(app_id, address);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_volunteer_slip_sending_count(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.dis_volunteer_slip_sending_count(app_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_offline_user(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.ins_offline_user(app_id, user_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string offline_syc_complete(string syc_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.offline_syc_complete(syc_id);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string get_app_urls(string link_type)
    {
        // Define a default failure response in JSON
        string result = "";
        string fail_result = "{\"status\":\"0\",\"message\":\"Invalid link type requested\"}";

        if (User != null)
        {
            if (User.IsValid())
            {
                string targetUrl = "";

                // Check what type of URL the mobile app is requesting
                switch (link_type.ToLower())
                {
                    case "video_help":
                        targetUrl = "https://hlele.bjpwings.com//Video_Help.aspx"; // Replace with your actual video URL
                        break;
                    case "privacy_policy":
                        targetUrl = "https://hlele.bjpwings.com//bjp-wings-privacy-policy.html"; // Replace with your actual privacy policy URL
                        break;
                    case "contact_us":
                        targetUrl = "https://hlele.bjpwings.com//bjp_wings_contact.html"; // Replace with your actual privacy policy URL
                        break;
                    default:
                        targetUrl = ""; // Unknown type
                        break;
                }

                // If a valid URL was found, return it as a JSON object
                if (!string.IsNullOrEmpty(targetUrl))
                {
                    // Creating a clean JSON response using an anonymous object
                    var responseObj = new { status = 1, url = targetUrl };
                    result = JsonConvert.SerializeObject(responseObj);
                }
                else
                {
                    // Return failure if they passed a type that doesn't exist
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_saktikendra_wise_total_slip_distribution_count(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.dis_saktikendra_wise_total_slip_distribution_count(app_id, booth_no);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_survey_dash_for_saktikendra_pramukh(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_booth_wise_survey_dash_for_saktikendra_pramukh(app_id, booth_no);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_total_slip_distribution_count(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Prachar.dis_booth_wise_total_slip_distribution_count(app_id, booth_no);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_boothpramukh_survey_dashboard(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_boothpramukh_survey_dashboard_sp(app_id, booth_no);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_call_center_dash(string user_id, string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_call_center_dash(user_id, app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_call_center_survey_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_booth_wise_call_center_survey_dash(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_date_wise_call_center_survey_dash(string app_id, string month)
    {
        // Make sure 'result' and 'fail_result' are declared in your class
        // string result = "";
        // string fail_result = "{\"status\":\"fail\"}"; 

        if (User != null)
        {
            if (User.IsValid())
            {
                // Calling the DAL method we just created
                DataSet ds = BAL_Survey.dis_date_wise_call_center_survey_dash(app_id, month);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        // Serializing the datatable to JSON
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_call_center_survey(string app_id, string voter_idcard, string voter_status, string note, string create_by)
    {
        // Assuming 'result' and 'fail_result' are declared globally in your class
        // string result = "";
        // string fail_result = "{\"status\":\"fail\"}"; 

        if (User != null)
        {
            if (User.IsValid())
            {
                // Calling the DAL method we just created
                DataSet ds = BAL_Survey.ins_call_center_survey(app_id, voter_idcard, voter_status, note, create_by);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        // Serializing the datatable to JSON (This will return the 'ok' from your SP)
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_voter_list_for_call_center(string app_id, string booth_no)
    {
        // Make sure 'result' and 'fail_result' are declared globally in your class
        // string result = "";
        // string fail_result = "{\"status\":\"fail\"}"; 

        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_booth_wise_voter_list_for_call_center(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_date_wise_call_center_survey_voter(string app_id, string date)
    {
        // Make sure 'result' and 'fail_result' are declared globally in your class
        // string result = "";
        // string fail_result = "{\"status\":\"fail\"}"; 

        if (User != null)
        {
            if (User.IsValid())
            {
                // Call the highly optimized database method
                DataSet ds = BAL_Survey.dis_date_wise_call_center_survey_voter(app_id, date);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        // Return the data as a JSON array
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        // Return failure if no records match that date for that app
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_date_wise_survey_voter_for_call_center(string app_id, string date)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_date_wise_survey_voter_for_call_center(app_id, date);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_call_center_survey_voter(string app_id, string booth_no)
    {
        // string result = "";
        // string fail_result = "{\"status\":\"fail\"}"; 

        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_booth_wise_call_center_survey_voter(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_user_wise_call_center_survey_voter(string app_id, string user_id)
    {
        // string result = "";
        // string fail_result = "{\"status\":\"fail\"}"; 

        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_user_wise_call_center_survey_voter(app_id, user_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_user_wise_call_center_survey_dash(string app_id, string date)
    {
        // Make sure 'result' and 'fail_result' are declared globally in your class
        // string result = "";
        // string fail_result = "{\"status\":\"fail\"}"; 

        if (User != null)
        {
            if (User.IsValid())
            {
                // Call the database method
                DataSet ds = BAL_Survey.dis_user_wise_call_center_survey_dash(app_id, date);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_admin_call_center_survey_dashboard(string app_id)
    {
        // Assuming 'result' and 'fail_result' are declared globally in your class
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_admin_call_center_survey_dashboard(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string upd_voter_mobile(string app_id, string voter_id, string mobile_no, string modify_by)
    {
        // Assuming 'result' and 'fail_result' are declared globally in your class
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.upd_voter_mobile(app_id, voter_id, mobile_no, modify_by);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_pramukh_voter(string app_id, string booth_no)
    {
        // Assuming 'result' and 'fail_result' are declared globally in your class
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_booth_pramukh_voter(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_voter_capation_wise_voter(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_voter_capation_wise_voter(app_id, user_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string quick_search_from_all_rajkot_ward(string app_id, string search)
    {
        // Assuming 'result' and 'fail_result' are declared globally in your class
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Rajkot.quick_search_from_all_rajkot_ward(app_id, search);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string rajkot_master_admin_login(string mobile_no, string device_id, string is_login)
    {
        // Assuming 'result' and 'fail_result' are declared globally in your class
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Rajkot.rajkot_master_admin_login(mobile_no, device_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {

                        DataColumn dcm_otp = new DataColumn("otp");

                        if (is_login == "1")
                        {
                            string message = "";
                            string OTP = General_Class.generat_otp();
                            //string OTP = "000000";
                            message += "Dear Customer, Your OTP for CQPPLE app login is " + OTP;
                            General_Class.send_sms(mobile_no, message);

                            dcm_otp.DefaultValue = OTP;
                        }
                        else
                        {
                            dcm_otp.DefaultValue = "";
                        }

                        ds.Tables[0].Columns.Add(dcm_otp);

                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_shaktikendra_wise_survey_dash(string app_id, string survey_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_shaktikendra_wise_survey_dash(app_id, survey_by);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_pramukh_wise_survey_dash(string app_id, string survey_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_booth_pramukh_wise_survey_dash_sp(app_id, survey_by);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_karykarta_wise_survey_dash(string app_id, string survey_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_karykarta_wise_survey_dash(app_id, survey_by);
                if (ds.Tables.Count > 0)
                {

                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_survey_for_call_center(string app_id, string booth_no, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_booth_wise_survey_for_call_center(app_id, booth_no, user_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_voter_captain_voter(string app_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Admin.dis_voter_captain_voter(app_id, user_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_social_media_summary(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Voter.dis_booth_wise_social_media_summary(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_facebook_users(string app_id, string booth_no)
    {


        if (User != null)
        {
            if (User.IsValid())
            {
                // Assuming this BAL method is placed inside your BAL_Voter class
                DataSet ds = BAL_Voter.dis_booth_wise_facebook_users(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_insta_users(string app_id, string booth_no)
    {


        if (User != null)
        {
            if (User.IsValid())
            {
                // Calling the corresponding BAL method
                DataSet ds = BAL_Voter.dis_booth_wise_insta_users(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }


    // ==========================================
    // 1. INSERT POPUP ALERT WITH MEDIA
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_popup_alert(string app_id, string userId, string title, string content, string show_status, string isActive, string mediaListJson)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataTable mediaList = new DataTable();
                if (mediaListJson != "")
                {
                    mediaList = JsonConvert.DeserializeObject<DataTable>(mediaListJson);
                }

                // 1. Save media files from base64 (if any)
                DataTable dt_media = new DataTable();
                dt_media.Columns.AddRange(new DataColumn[] { new DataColumn("media_type", typeof(string)), new DataColumn("media_url", typeof(string)) });
                foreach (DataRow row in mediaList.Rows)
                {
                    string mediaType = row["media_type"].ToString();
                    string mediaBase64 = row["media_base64"].ToString();
                    string mediaUrl = row["media_url"].ToString();

                    if (!string.IsNullOrEmpty(mediaBase64))
                    {
                        string folderPath = mediaType.ToLower() == "a" ? "img/popup/audio/" : "img/popup/images/";
                        string savedFile = General_Class.save_file_from_base64(
                            row["media_name"].ToString(),
                            mediaBase64,
                            Server.MapPath(folderPath)
                        );
                        row["media_url"] = savedFile;

                        dt_media.Rows.Add(mediaType, savedFile);
                    }
                    else
                    {
                        dt_media.Rows.Add(mediaType, mediaUrl);
                    }
                }

                // 2. Call the BAL method to insert popup + media
                DataSet ds = BAL_PopupAlert.ins_popup_alert_with_media_sp(app_id, userId, title, content, show_status, isActive, dt_media);

                // 3. Return JSON result
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    // ==========================================
    // 2. UPDATE POPUP ALERT WITH MEDIA
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string upd_popup_alert(string app_id, string userId, string popupId, string title, string content, string show_status, string isActive, string mediaListJson)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataTable mediaList = new DataTable();
                if (mediaListJson != "")
                {
                    mediaList = JsonConvert.DeserializeObject<DataTable>(mediaListJson);
                }

                DataTable dt_media = new DataTable();
                dt_media.Columns.AddRange(new DataColumn[] { new DataColumn("media_type", typeof(string)), new DataColumn("media_url", typeof(string)) });
                foreach (DataRow row in mediaList.Rows)
                {
                    string mediaType = row["media_type"].ToString();
                    string mediaBase64 = row["media_base64"].ToString();
                    string mediaUrl = row["media_url"].ToString();

                    if (!string.IsNullOrEmpty(mediaBase64))
                    {
                        string folderPath = mediaType.ToLower() == "audio" ? "img/popup/audio/" : "img/popup/images/";
                        string savedFile = General_Class.save_file_from_base64(
                            row["media_name"].ToString(),
                            mediaBase64,
                            Server.MapPath(folderPath)
                        );
                        row["media_url"] = savedFile;

                        dt_media.Rows.Add(mediaType, savedFile);
                    }
                    else
                    {
                        dt_media.Rows.Add(mediaType, mediaUrl);
                    }
                }

                DataSet ds = BAL_PopupAlert.upd_popup_alert_with_media_sp(app_id, userId, popupId, title, content, show_status, isActive, dt_media);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    // ==========================================
    // 3. SOFT DELETE POPUP ALERT
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dlt_popup_alert(string app_id, string userId, string popupId)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_PopupAlert.dlt_popup_alert_sp(app_id, userId, popupId);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    // ==========================================
    // 4. SELECT FOR EDIT
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string sel_popup_alert_for_edit(string app_id, string popupId)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_PopupAlert.sel_popup_alert_for_edit_sp(app_id, popupId);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    // ==========================================
    // 5. DISPLAY ALL POPUP ALERTS
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_popup_alert_all(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_PopupAlert.dis_popup_alert_all_sp(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_survey_dash_for_sakti_and_warroom(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Survey.dis_survey_dash_for_sakti_and_warroom(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + ",";
                        result += "\"result2\":" + JsonConvert.SerializeObject(ds.Tables[1]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dlt_popup_alert_media(string media_id, string delete_by)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_PopupAlert.dlt_popup_alert_media(media_id, delete_by);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }
        return result;
    }

    // ==========================================
    // 8. DISPLAY NOT AVAILABLE VOTERS BY REASON AND BOOTH
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_not_availabe_voter(string app_id, string reason, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                // BAL મેથડને કોલ કરીને ડેટાસેટ મેળવ્યો
                DataSet ds = BAL_Survey.dis_not_availabe_voter_sp(app_id, reason, booth_no);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        // તમારા એક્ઝેક્ટ ફોર્મેટ મુજબ - JSON કન્વર્ટ કરી છેલ્લે બ્રેકેટ એપેન્ડ થશે
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    // ==========================================
    // DISPLAY ALL VIDEOS
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_all_video()
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_VideoUpload.dis_all_video_sp();

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    // ==========================================
    // 9. DISPLAY GOVT SCHEME BENEFICIARY DASHBOARD
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_scheme_beneficiary_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                // ૨ અલગ ટેબલ વાળો આખો ડેટાસેટ મેળવવા BAL કોલ કર્યો
                DataSet ds = BAL_Gov_Scheme.dis_scheme_beneficiary_dash_sp(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        // તમારા એક્ઝેક્ટ ફોર્મેટ મુજબ - આખો ડેટાસેટ ઓબ્જેક્ટ કન્વર્ટ થઈને પ્લસ થશે
                        result += JsonConvert.SerializeObject(ds) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    // ==========================================
    // 10. DISPLAY BOOTH WISE BENEFICIARY COUNT
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_booth_wise_beneficiary_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Gov_Scheme.dis_booth_wise_beneficiary_dash_sp(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    // ==========================================
    // 11. GET SCHEME BENEFICIARIES BY BOOTH WITH SURVEY STATUS
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string sel_scheme_beneficiary_by_booth(string app_id, string booth_no)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Gov_Scheme.sel_scheme_beneficiary_by_booth_sp(app_id, booth_no);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    // ==========================================
    // 13. DISPLAY ADDRESS WISE BENEFICIARY COUNT (OPTIMIZED)
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string dis_address_wise_beneficiary_dash(string app_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Gov_Scheme.dis_address_wise_beneficiary_dash_sp(app_id);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        // સિંગલ ટેબલ હોવાથી ડાયરેક્ટ સીરીયલાઇઝ કરીને બ્રેકેટ એપેન્ડ થશે
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    // ==========================================
    // 14. GET SCHEME BENEFICIARIES BY ADDRESS WITH SURVEY STATUS
    // ==========================================
    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string sel_scheme_beneficiary_by_address(string app_id, string address_text)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                DataSet ds = BAL_Gov_Scheme.sel_scheme_beneficiary_by_address_sp(app_id, address_text);

                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    [SoapHeader("User", Required = true)]
    [WebMethod]
    public string ins_sleep_log(string app_id, string voter_id, string user_id)
    {
        if (User != null)
        {
            if (User.IsValid())
            {
                // BAL લેયરમાંથી ઇન્સર્ટ પ્રોસિજર અને ઈમેજ ફેચ કૉલ (તમારા સ્ટાન્ડર્ડ ફોર્મેટ મુજબ)
                DataSet ds = BAL_Prachar.ins_sleep_log(app_id, voter_id, user_id);

                if (ds != null && ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        // પ્રોસિજરમાંથી મળતી 'img' કોલમ સહિતના ડેટાને JSON માં કન્વર્ટ કરો
                        result += JsonConvert.SerializeObject(ds.Tables[0]) + "}";
                    }
                    else
                    {
                        result = fail_result;
                    }
                }
                else
                {
                    result = fail_result;
                }
            }
            else
            {
                return "Invalid User";
            }
        }
        else
        {
            return "Please Provide User Detail";
        }

        return result;
    }

    /// <summary>
    /// New Election AI (uses App_Code/AI only — does not call AIQueryEngine).
    /// </summary>
    //[SoapHeader("User", Required = true)]
    //[WebMethod]
    //public string AskElectionAI(string user_question, string app_id)
    //{
    //    if (User == null || !User.IsValid())
    //        return ElectionAIResponse.ToJsonFail("Invalid User");

    //    int appId;
    //    if (!int.TryParse(app_id, out appId) || appId <= 0)
    //        return ElectionAIResponse.ToJsonFail("Invalid app_id");

    //    try
    //    {
    //        ElectionAIResponse response = ElectionAIService.Ask(user_question, appId);
    //        return response.ToJson();
    //    }
    //    catch (Exception ex)
    //    {
    //        return ElectionAIResponse.ToJsonFail(ex.Message);
    //    }
    //}
}


