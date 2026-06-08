<%@ Page Title="" Language="C#" MasterPageFile="~/MasterAdmin/MasterPage.master" AutoEventWireup="true" CodeFile="Import_Voter_Data.aspx.cs" Inherits="MasterAdmin_Import_Voter_Data" %>

<asp:Content ID="Content1" ContentPlaceHolderID="title" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="body" Runat="Server">
   <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div class="container mt-5">
        <div class="card shadow">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Step 1: Upload Election Excel</h5>
            </div>
            <div class="card-body">
                <div class="input-group">
                    <asp:FileUpload ID="fileExcel" runat="server" CssClass="form-control" />
                    <asp:Button ID="btnPreview" runat="server" Text="Read Headers & Map" CssClass="btn btn-primary" OnClick="btnPreview_Click" />
                </div>
            </div>
        </div>

        <asp:UpdatePanel ID="upProgress" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:Timer ID="Timer1" runat="server" Interval="2000" Enabled="false" OnTick="Timer1_Tick"></asp:Timer>
                <div id="divProgress" runat="server" visible="false" class="mt-4">
                    <h6>Importing Data... <asp:Label ID="lblCount" runat="server" Text="0"></asp:Label> / <asp:Label ID="lblTotal" runat="server" Text="0"></asp:Label></h6>
                    <div class="progress" style="height: 30px;">
                        <div id="pbImport" runat="server" class="progress-bar progress-bar-striped progress-bar-animated bg-success" role="progressbar" style="width: 0%;">0%</div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

    <div class="modal fade" id="mappingModal" data-bs-backdrop="static" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-dark text-white">
                    <h5 class="modal-title">Step 2: Connect Excel to Database</h5>
                </div>
                <div class="modal-body" style="max-height:450px; overflow-y:auto;">
                    <table class="table table-sm table-bordered">
                        <thead>
                            <tr class="table-light">
                                <th>Database Field</th>
                                <th>Excel Column</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptMapping" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><strong><%# Container.DataItem %></strong>
                                            <asp:HiddenField ID="hfSqlCol" runat="server" Value='<%# Container.DataItem %>' />
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="ddlExcelCol" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btnStartImport" runat="server" Text="Start Bulk Copy" CssClass="btn btn-success" OnClick="btnStartImport_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        function showMappingModal() {
            var myModal = new bootstrap.Modal(document.getElementById('mappingModal'));
            myModal.show();
        }
</script>
</asp:Content>

