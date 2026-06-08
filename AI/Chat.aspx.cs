using System;
using System.Text;
using System.Web.Services;
using System.Web.UI;

public partial class AI_Chat : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Charset = "utf-8";
        Response.ContentEncoding = Encoding.UTF8;
        Response.HeaderEncoding = Encoding.UTF8;
    }

    [WebMethod]
    public static string AskElectionAI(string user_question, int app_id)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(user_question))
                return ElectionAIResponse.ToJsonFail("Please enter a question.");

            if (app_id <= 0)
                return ElectionAIResponse.ToJsonFail("Invalid app_id.");

            // Keep sync API surface for UI calls.
            ElectionAIResponse response = ElectionAIService.Ask(user_question.Trim(), app_id);
            return response.ToJson();
        }
        catch (Exception ex)
        {
            return ElectionAIResponse.ToJsonFail(ElectionAIClient.GetDeepMessage(ex));
        }
    }
}

