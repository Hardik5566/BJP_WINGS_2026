using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Survey
/// </summary>
public class BAL_Survey
{
    public BAL_Survey()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static DataSet ins_voter_survey(
    string app_id,
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
    string visit_location
)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_voter_survey";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@voter_idcard", voter_idcard));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        cmd.Parameters.Add(param.intparam("@survey_by", survey_by));
        cmd.Parameters.Add(param.stringparam("@survey_by_designation", survey_by_designation));
        cmd.Parameters.Add(param.stringparam("@voter_available", voter_available));

        cmd.Parameters.Add(param.stringparam("@not_available_reason", not_available_reason));
        cmd.Parameters.Add(param.stringparam("@not_available_note", not_available_note));

        cmd.Parameters.Add(param.stringparam("@contact_no", contact_no));
        cmd.Parameters.Add(param.stringparam("@voter_status", voter_status));
        cmd.Parameters.Add(param.stringparam("@note", note));

        cmd.Parameters.Add(param.stringparam("@lat_long", lat_long));
        cmd.Parameters.Add(param.stringparam("@visit_location", visit_location));

        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_survey_dash_for_admin(string app_id, string survey_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_survey_dash_for_admin_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@survey_by", survey_by ?? string.Empty));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_survey_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_survey_dash_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_user_wise_survey_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_user_wise_survey_dash_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_user_type_wise_survey_dash(string app_id, string type)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_user_type_wise_survey_dash_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@type", type));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_scheme()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_scheme_sp";

        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_community()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_community_sp";

        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_caste()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_caste_sp";

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_scheme_community_caste_data()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_scheme_community_caste_data_sp";

        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_cast_wise_survey_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_cast_wise_survey_dash_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_community_wise_survey_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_community_wise_survey_dash_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_scheme_wise_survey_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_scheme_wise_survey_dash";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_ration_card_wise_survey_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_ration_card_wise_survey_dash_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_date_wise_survey_dash(string app_id, string month)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_date_wise_survey_dash_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.datetimeparam("@month", month));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_phonebook_wise_survey_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_phonebook_wise_survey_dash_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_phonebook_wise_Survey_voter(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_phonebook_wise_Survey_voter_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_user_wise_survey_voter(string app_id, string admin_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_user_wise_survey_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@admin_id", admin_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_survey_voter(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_survey_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_date_wise_survey_voter(string app_id, string date)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_date_wise_survey_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.datetimeparam("@date", date));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_scheme_wise_survey_voter(string app_id, string scheme_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_scheme_wise_survey_voter_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@scheme_id", scheme_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_ration_card_wise_survey_voter(string app_id, string ration_card)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_ration_card_wise_survey_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@ration_card", ration_card));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_commuinity_wise_survey_voter(string app_id, string commuinity_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_commuinity_wise_survey_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@commuinity_id", commuinity_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_cast_wise_survey_voter(string app_id, string cast_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_cast_wise_survey_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@cast_id", cast_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_death_voter(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_death_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_shifted_out_voter(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_shifted_out_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_wrong_mobile_no_voter(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_wrong_mobile_no_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_call_not_received_voter(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_call_not_received_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_voter_survey_log(string app_id, string voter_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_voter_survey_log_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@voter_id", voter_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_survey_detail(string survey_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_survey_detail_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@survey_id", survey_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_polling_location_wise_slip_send_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_polling_location_wise_slip_send_dash_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet polling_location_wise_slip_sending_voter(string app_id, string polling_location)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "polling_location_wise_slip_sending_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@polling_location", polling_location));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_user_wise_slip_distribution(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_user_wise_slip_distribution_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_date_wise_slip_distribution(string app_id, string month)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_date_wise_slip_distribution_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@month", month));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet date_wise_slip_sending_voter(string app_id, string date)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "date_wise_slip_sending_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@date", date));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet master_search_for_slip_send(string app_id, string f_name, string m_name, string surname, string mobile_no, string id_card_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "master_search_for_slip_send_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@f_name", f_name));
        cmd.Parameters.Add(param.stringparam("@m_name", m_name));
        cmd.Parameters.Add(param.stringparam("@surname", surname));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.stringparam("@id_card_no", id_card_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_my_slip_sending_voter(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_my_slip_sending_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet booth_wise_slip_sending(string app_id, string part_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "booth_wise_slip_sending_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@part_no", part_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_saktikendra_survey_dashboard(string app_id, string booth)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_saktikendra_survey_dashboard";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@booth", booth));
        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_booth_wise_survey_dash_for_saktikendra_pramukh(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_survey_dash_for_saktikendra_pramukh_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_boothpramukh_survey_dashboard_sp(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_boothpramukh_survey_dashboard_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_call_center_dash(string user_id, string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_call_center_dash_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_call_center_survey_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_call_center_survey_dash_sp";

        parameter param = new parameter();

        // Passing the single required parameter
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_date_wise_call_center_survey_dash(string app_id, string month)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_date_wise_call_center_survey_dash_sp";

        parameter param = new parameter();

        // Passing both required parameters
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@month", month));

        return command.ExtQueryDS(cmd);
    }


    public static DataSet ins_call_center_survey(string app_id, string voter_idcard, string voter_status, string note, string create_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_call_center_survey";

        parameter param = new parameter();

        // Mapping all the parameters
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@voter_idcard", voter_idcard));
        cmd.Parameters.Add(param.stringparam("@voter_status", voter_status));
        cmd.Parameters.Add(param.stringparam("@note", note));
        cmd.Parameters.Add(param.intparam("@create_by", create_by));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_voter_list_for_call_center(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_voter_list_for_call_center_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_date_wise_call_center_survey_voter(string app_id, string date)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_date_wise_call_center_survey_voter_sp";

        parameter param = new parameter();

        // Passing both the App ID and the Target Date
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@date", date));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_call_center_survey_voter(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_call_center_survey_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_user_wise_call_center_survey_voter(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_user_wise_call_center_survey_voter_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_user_wise_call_center_survey_dash(string app_id, string date)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_user_wise_call_center_survey_dash_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        // Safely handle the optional date parameter
        if (string.IsNullOrEmpty(date))
        {
            // If the app sends nothing, pass NULL to SQL so it returns all records
            cmd.Parameters.AddWithValue("@date", DBNull.Value);
        }
        else
        {
            // Otherwise, pass the specific date
            cmd.Parameters.Add(param.stringparam("@date", date));
        }

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_admin_call_center_survey_dashboard(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_admin_call_center_survey_dashboard_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_shaktikendra_wise_survey_dash(string app_id, string survey_by)
    {
        SqlCommand cmd = new SqlCommand();
        // Using the exact name of the modified stored procedure
        cmd.CommandText = "dis_shaktikendra_wise_survey_dash_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@survey_by", survey_by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_pramukh_wise_survey_dash_sp(string app_id, string survey_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_pramukh_wise_survey_dash_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@survey_by", survey_by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_karykarta_wise_survey_dash(string app_id, string survey_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_karykarta_wise_survey_dash_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@survey_by", survey_by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_survey_for_call_center(string app_id, string booth_no, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dbo.dis_booth_wise_survey_for_call_center";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_voter_survey_count_by_month(string app_id, string month)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sp_GetVoterSurveyCountByMonth";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.datetimeparam("@month", month));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_voter_survey_count_by_month_only_call_center(string app_id, string month)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sp_GetVoterSurveyCountByMonthOnlyCallCenter";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.datetimeparam("@month", month));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_date_wise_survey_voter_for_call_center(string app_id, string date)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_date_wise_survey_voter_for_call_center_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.datetimeparam("@date", date));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_survey_dash_for_sakti_and_warroom(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_survey_dash_for_sakti_and_warroom_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@booth_no", booth_no));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_not_availabe_voter_sp(string app_id, string reason, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_not_availabe_voter_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@reason", reason));
        cmd.Parameters.Add(param.stringparam("@booth_no", booth_no)); // કૉમા સેપરેટેડ બૂથ નંબર અથવા બ્લેન્ક સ્ટ્રિંગ

        return command.ExtQueryDS(cmd);
    }
}