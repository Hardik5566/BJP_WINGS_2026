<%@ Page Title="" Language="C#" MasterPageFile="~/MasterAdmin/MasterPage.master" AutoEventWireup="true" CodeFile="App_Master.aspx.cs" Inherits="MasterAdmin_App_Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="title" runat="Server">
    APP Master
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="head" runat="Server">
    <style>
        .card {
            box-shadow: 0 !important;
            border: 1px solid black !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="body" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="page-breadcrumb d-sm-flex align-items-center mb-3">
        <div class="breadcrumb-title pe-3"><i class="bx bx- cabinet">&nbsp</i>App Settings</div>
        <div class="ms-auto btn_header">
            <div class="btn-group">
                <button type="button" class="btn btn-sm btn-primary btn_add" data-bs-toggle="modal" data-bs-target="#modal_add">+ Add New App</button>
            </div>
        </div>
    </div>
    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 row-cols-xl-4 g-4">
        <asp:Repeater ID="rep_apps" runat="server" OnItemCommand="rep_apps_ItemCommand">
            <ItemTemplate>
                <div class="col">
                    <div class="card h-100 shadow-sm border-0 position-relative overflow-hidden" style="border-radius: 12px; transition: transform 0.2s;">


                        <div class="card-body pt-4">
                            <div class="d-flex align-items-center mb-3">
                                <div class="flex-shrink-0">
                                  <img src='<%# Eval("party_logo_png") %>' 
     class="rounded-3 border"
     style="width: 55px; height: 55px; object-fit: contain; padding: 4px;"
     onerror="this.onerror=null;this.src='<%# ResolveUrl("~/img/party_logo/Election-Commission_Preview.png") %>';" />
                                </div>

                                <div class="flex-grow-1 ms-3">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle mb-1">No: <%# Eval("vidhansabha_no") %>
                                        </span>
                                        <small class="text-muted fw-bold">v<%# Eval("app_ver") %></small>
                                    </div>
                                    <h6 class="mb-0 fw-bold text-dark text-uppercase" style="letter-spacing: 0.5px;">
                                        <%# Eval("vidhansabha_name") %>
                                    </h6>
                                </div>
                            </div>

                            <div class="bg-light rounded-3 p-3 mb-3">
                                <div class="row g-2">
                                    <div class="col-12 border-bottom pb-2 mb-2">
                                        <label class="text-muted d-block small mb-1 text-uppercase fw-semibold" style="font-size: 10px;">Candidate Details</label>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="fw-bold text-secondary"><%# Eval("candidate_name") %></span>
                                            <span class="badge rounded-pill bg-dark">#<%# Eval("candidate_no") %></span>
                                        </div>
                                    </div>
                                    <div class="col-12">
                                        <label class="text-muted d-block small mb-1 text-uppercase fw-semibold" style="font-size: 10px;">Total Voters</label>
                                        <div class="fs-5 fw-bold text-primary">
                                            <i class="bi bi-people-fill me-2"></i><%# string.Format("{0:N0}", Eval("total_voter")) %>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex align-items-center gap-2">
                                <div class="flex-grow-1">
                                    <div class='<%# GetStatusClass(Eval("offline_status")) %> text-center py-2 rounded-3 fw-bold small'>
                                        <%# GetStatusText(Eval("offline_status")) %>
                                    </div>
                                </div>



                                <asp:LinkButton ID="btn_edit" runat="server" CommandName="btn_edit" CommandArgument='<%# Eval("app_id") %>'
                                    CssClass="btn btn-outline-secondary border-2 rounded-3">
                                        <i class="bi bi-pencil-fill"></i>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <style>
        /* Professional Hover Effect */
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important;
        }

        .bg-primary-subtle {
            background-color: #e7f1ff;
        }
    </style>


    <div class="modal fade" id="modal_add" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">App Configuration</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-2">
                        <div class="col-md-3">
                            <label>Vidhansabha No</label>
                            <asp:TextBox ID="txt_v_no" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-6">
                            <label>Vidhansabha Name</label>
                            <asp:TextBox ID="txt_v_name" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-3">
                            <label>Total Voters</label>
                            <asp:TextBox ID="txt_total_voter" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>

                        <div class="col-md-3">
                            <label>Candidate No</label>
                            <asp:TextBox ID="txt_c_no" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-5">
                            <label>Candidate Name</label>
                            <asp:TextBox ID="txt_c_name" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-2">
                            <label>Party Short</label>
                            <asp:TextBox ID="txt_p_short" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-2">
                            <label>App Version</label>
                            <asp:TextBox ID="txt_app_ver" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-6">
                            <label>Party Full Name</label>
                            <asp:TextBox ID="txt_p_full" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>

                        <div class="col-md-3">
                            <label>Logo PNG URL</label>
                            <asp:TextBox ID="txt_logo_png" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-3">
                            <label>Logo JPG URL</label>
                            <asp:TextBox ID="txt_logo_jpg" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-6">
                            <label>Offline DB URL</label>
                            <asp:TextBox ID="txt_db_url" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-6">
                            <label>App Link URL</label>
                            <asp:TextBox ID="txt_app_link" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-6">
                            <label>Popup URL</label>
                            <asp:TextBox ID="txt_popup_url" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>

                        <div class="col-md-4">
                            <label class="text-danger fw-bold">Upload Splash Image</label>
                            <asp:FileUpload ID="fu_splace" runat="server" CssClass="form-control border-danger" />
                        </div>

                        <div class="col-md-4">
                            <label>Offline Status</label>
                            <asp:DropDownList ID="ddl_off_status" runat="server" CssClass="form-select">
                                <asp:ListItem Value="0">Online</asp:ListItem>
                                <asp:ListItem Value="1">Offline</asp:ListItem>
                                <asp:ListItem Value="2">Force Offline</asp:ListItem>
                                <asp:ListItem Value="3">Auto Offline</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <label>Offline Ver</label>
                            <asp:TextBox ID="txt_offline_ver" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label>Popup Status</label>
                            <asp:DropDownList ID="ddl_popup_status" runat="server" CssClass="form-select">
                                <asp:ListItem Value="0">No Popup</asp:ListItem>
                                <asp:ListItem Value="1">Once in Login</asp:ListItem>
                                <asp:ListItem Value="2">Once in Day</asp:ListItem>
                                <asp:ListItem Value="3">Everytime</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-4">
                            <label>Slip Message</label>
                            <asp:TextBox ID="txt_slip_msg" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label>SMS Slip Message</label>
                            <asp:TextBox ID="txt_sms_slip_msg" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label>Invitation Message</label>
                            <asp:TextBox ID="txt_inv_msg" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>

                        <div class="col-12 mt-3">
                            <h6>Module Rights (0/1)</h6>
                            <hr />
                        </div>
                        <div class="col-md-3">
                            <label>Call Center</label>
                            <asp:DropDownList ID="ddl_call_center" CssClass="form-control" runat="server">
                                <asp:ListItem Value="0">No</asp:ListItem>
                                <asp:ListItem Value="1">Yes</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-3">
                            <label>Prachar</label>
                            <asp:DropDownList ID="ddl_prachar" CssClass="form-control" runat="server">
                                <asp:ListItem Value="0">No</asp:ListItem>
                                <asp:ListItem Value="1">Yes</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-3">
                            <label>Aachar Sahita</label>
                            <asp:DropDownList ID="ddl_aachar_sahita" CssClass="form-control" runat="server">
                                <asp:ListItem Value="0">No</asp:ListItem>
                                <asp:ListItem Value="1">Yes</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-3">
                            <label>Live Voting</label>
                            <asp:DropDownList ID="ddl_live_voting" CssClass="form-control" runat="server">
                                <asp:ListItem Value="0">No</asp:ListItem>
                                <asp:ListItem Value="1">Yes</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-3">
                            <label>Sleep Send</label>
                            <asp:DropDownList ID="ddl_sleep_send" CssClass="form-control" runat="server">
                                <asp:ListItem Value="0">No</asp:ListItem>
                                <asp:ListItem Value="1">Yes</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-3">
                            <label>Meta Wtsp</label>
                            <asp:DropDownList ID="ddl_meta_wtsp" CssClass="form-control" runat="server">
                                <asp:ListItem Value="0">No</asp:ListItem>
                                <asp:ListItem Value="1">Yes</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-3">
                            <label>AI</label>
                            <asp:DropDownList ID="ddl_ai" CssClass="form-control" runat="server">
                                <asp:ListItem Value="0">No</asp:ListItem>
                                <asp:ListItem Value="1">Yes</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btn_save" runat="server" OnClick="btn_save_Click" CssClass="btn btn-primary" Text="Save Configuration" />
                </div>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hd_action" Value="save" runat="server" />

    <script>
        $(document).ready(function () {
            $(".btn_add").click(function () {
                // Clear all inputs
                $("#modal_add input[type='text'], #modal_add textarea").val("");
                $("#<%=hd_action.ClientID%>").val("save");
            });
        });

        function showModal() {
            var myModal = new bootstrap.Modal(document.getElementById('modal_add'));
            myModal.show();
        }
    </script>
</asp:Content>

