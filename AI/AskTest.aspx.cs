using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AI_AskTest : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    protected void btnAsk_Click(object sender, EventArgs e)
    {
        lblStatus.Text = "";
        litSql.Text = "";
        litJson.Text = "";
        gvResults.DataSource = null;
        gvResults.DataBind();

        try
        {
            string question = (txtQuestion.Text ?? "").Trim();
            if (string.IsNullOrWhiteSpace(question))
            {
                lblStatus.Text = "Enter a question.";
                lblStatus.CssClass = "err";
                return;
            }

            int appId;
            if (!int.TryParse((txtAppId.Text ?? "").Trim(), out appId) || appId <= 0)
            {
                lblStatus.Text = "Invalid App ID.";
                lblStatus.CssClass = "err";
                return;
            }

            ElectionAIResponse response = ElectionAIService.Ask(question, appId);
            string json = response.ToJson();

            litSql.Text = "<div class='mono'>" + Server.HtmlEncode(response.sql ?? "") + "</div>";
            litJson.Text = "<div class='mono'>" + Server.HtmlEncode(json) + "</div>";

            if (response.status == "1")
            {
                lblStatus.Text = "OK — rows: " + response.row_count;
                lblStatus.CssClass = "ok";
                BindGridFromResponse(response);
            }
            else
            {
                lblStatus.Text = "Error: " + Server.HtmlEncode(response.message);
                lblStatus.CssClass = "err";
            }
        }
        catch (Exception ex)
        {
            lblStatus.Text = "Error: " + Server.HtmlEncode(ElectionAIClient.GetDeepMessage(ex));
            lblStatus.CssClass = "err";
            litJson.Text = "<div class='mono'>" + Server.HtmlEncode(ex.ToString()) + "</div>";
        }
    }

    private void BindGridFromResponse(ElectionAIResponse response)
    {
        if (response.columns == null || response.columns.Count == 0)
            return;

        DataTable dt = new DataTable();
        foreach (string col in response.columns)
            dt.Columns.Add(col);

        if (response.rows != null)
        {
            foreach (var row in response.rows)
            {
                DataRow dr = dt.NewRow();
                for (int i = 0; i < response.columns.Count && i < row.Count; i++)
                    dr[i] = row[i] ?? DBNull.Value;
                dt.Rows.Add(dr);
            }
        }

        gvResults.DataSource = dt;
        gvResults.DataBind();
    }
}
