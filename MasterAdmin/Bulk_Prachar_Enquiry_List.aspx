<%@ Page Title="" Language="C#" MasterPageFile="~/MasterAdmin/MasterPage.master" AutoEventWireup="true" CodeFile="Bulk_Prachar_Enquiry_List.aspx.cs" Inherits="MasterAdmin_Bulk_Prachar_Enquiry_List" %>

<asp:Content ID="Content1" ContentPlaceHolderID="title" runat="Server">
    Bulk Prachar Enquiry List
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="head" runat="Server">
    <style>
        .enquiry-toolbar {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1rem;
        }

        .enquiry-search {
            min-width: 260px;
            max-width: 420px;
            flex: 1;
        }

            .enquiry-search .form-control {
                border-radius: 10px;
                padding-left: 2.4rem;
                border-color: #dbe3ee;
                box-shadow: none;
            }

        .enquiry-search-wrap {
            position: relative;
        }

            .enquiry-search-wrap i {
                position: absolute;
                left: 12px;
                top: 50%;
                transform: translateY(-50%);
                color: #6c757d;
            }

        .enquiry-card {
            border: 0;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
            overflow: hidden;
        }

            .enquiry-card .card-header {
                background: #fff;
                border-bottom: 1px solid #edf2f7;
                padding: 1rem 1.25rem;
            }

        .table-wrap {
            overflow: auto;
            max-width: 100%;
        }

        .enquiry-table {
            width: 100%;
            min-width: 1450px;
            margin-bottom: 0;
            border-collapse: separate;
            border-spacing: 0;
        }

            .enquiry-table thead th {
                position: sticky;
                top: 0;
                z-index: 2;
                background: #f8fafc;
                color: #475569;
                font-size: 11px;
                font-weight: 700;
                letter-spacing: .06em;
                text-transform: uppercase;
                padding: 14px 12px;
                border-bottom: 1px solid #e2e8f0;
                white-space: nowrap;
            }

            .enquiry-table tbody td {
                padding: 14px 12px;
                vertical-align: middle;
                border-bottom: 1px solid #f1f5f9;
                font-size: 13px;
                color: #1e293b;
                background: #fff;
            }

            .enquiry-table tbody tr:hover td {
                background: #f8fbff;
            }

            .enquiry-table tbody tr:last-child td {
                border-bottom: 0;
            }

        .type-pill {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 999px;
            background: #eef2ff;
            color: #4338ca;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .04em;
        }

        .sr-col {
            width: 52px;
            min-width: 52px;
            max-width: 52px;
            text-align: center;
            padding-left: 8px;
            padding-right: 8px;
            color: #64748b;
            font-weight: 600;
            font-variant-numeric: tabular-nums;
        }

            .enquiry-table thead th.sr-col {
                text-align: center;
            }

        .prachar-name {
            font-weight: 600;
            color: #0f172a;
            min-width: 160px;
        }

        .vidhan-cell .no {
            font-weight: 700;
            color: #0d6efd;
        }

        .vidhan-cell .name {
            display: block;
            color: #64748b;
            font-size: 12px;
            margin-top: 2px;
        }

        .num-cell {
            font-variant-numeric: tabular-nums;
            font-weight: 600;
            white-space: nowrap;
        }

        .money-cell {
            font-variant-numeric: tabular-nums;
            font-weight: 700;
            color: #0f766e;
            white-space: nowrap;
        }

        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .03em;
            text-transform: uppercase;
            white-space: nowrap;
        }

        .status-warning {
            background: #fff7ed;
            color: #c2410c;
        }

        .status-success {
            background: #ecfdf5;
            color: #047857;
        }

        .status-danger {
            background: #fef2f2;
            color: #b91c1c;
        }

        .status-muted {
            background: #f1f5f9;
            color: #475569;
        }

        .status-clickable {
            cursor: pointer;
            border: 1px solid transparent;
            transition: transform .12s ease, box-shadow .12s ease;
        }

            .status-clickable:hover {
                transform: translateY(-1px);
                box-shadow: 0 4px 10px rgba(15, 23, 42, 0.12);
            }

        .status-alert {
            border-radius: 10px;
            margin-bottom: 1rem;
            font-size: 13px;
            font-weight: 600;
        }

        .status-modal .modal-dialog {
            max-width: 440px;
        }

        .status-modal .modal-content {
            border: 1px solid #e8edf3;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 24px 60px rgba(15, 23, 42, 0.16);
            background: #fff;
        }

        .status-modal .modal-top {
            position: relative;
            padding: 1.5rem 1.5rem .25rem;
            text-align: center;
            background: #fff;
        }

            .status-modal .modal-top .btn-close {
                position: absolute;
                top: 14px;
                right: 14px;
                opacity: .45;
            }

        .status-modal-icon {
            width: 56px;
            height: 56px;
            margin: 0 auto .85rem;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.45rem;
        }

        .status-modal.prachar-modal .status-modal-icon {
            background: #eff6ff;
            color: #2563eb;
        }

        .status-modal.payment-modal .status-modal-icon {
            background: #ecfdf5;
            color: #059669;
        }

        .status-modal-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: #0f172a;
            margin: 0;
        }

        .status-modal-desc {
            font-size: 13px;
            color: #64748b;
            margin: .35rem 0 0;
        }

        .status-modal .modal-body {
            padding: 1rem 1.5rem 1.25rem;
        }

        .enquiry-info-box {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 14px;
            margin-bottom: 1rem;
            border-radius: 14px;
            background: #f8fafc;
            border: 1px solid #e8edf3;
        }

        .enquiry-info-box .info-icon {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            background: #fff;
            border: 1px solid #e2e8f0;
            color: #475569;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .enquiry-info-box .info-text {
            min-width: 0;
            flex: 1;
        }

        .enquiry-info-box .info-name {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: #0f172a;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .enquiry-info-box .info-id {
            display: block;
            font-size: 11px;
            color: #64748b;
            margin-top: 2px;
            font-weight: 600;
            letter-spacing: .03em;
        }

        .status-options {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .status-option-card {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 13px 14px;
            border: 2px solid #e8edf3;
            border-radius: 14px;
            background: #fff;
            cursor: pointer;
            transition: all .18s ease;
            user-select: none;
        }

            .status-option-card:hover {
                border-color: #cbd5e1;
                background: #fafbfc;
            }

            .status-option-card.selected {
                border-color: #2563eb;
                background: #f8fbff;
                box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
            }

        .payment-modal .status-option-card.selected {
            border-color: #059669;
            background: #f0fdf9;
            box-shadow: 0 0 0 3px rgba(5, 150, 105, 0.1);
        }

        .status-option-card .opt-icon {
            width: 38px;
            height: 38px;
            border-radius: 11px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            flex-shrink: 0;
        }

        .status-option-card.opt-pending .opt-icon {
            background: #fff7ed;
            color: #ea580c;
        }

        .status-option-card.opt-finished .opt-icon,
        .status-option-card.opt-received .opt-icon {
            background: #ecfdf5;
            color: #059669;
        }

        .status-option-card.opt-cancelled .opt-icon,
        .status-option-card.opt-not-received .opt-icon {
            background: #fef2f2;
            color: #dc2626;
        }

        .status-option-card .opt-content {
            flex: 1;
            min-width: 0;
        }

        .status-option-card .opt-title {
            display: block;
            font-size: 14px;
            font-weight: 700;
            color: #0f172a;
            line-height: 1.2;
        }

        .status-option-card .opt-sub {
            display: block;
            font-size: 11px;
            color: #64748b;
            margin-top: 2px;
        }

        .status-option-card .opt-radio {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            border: 2px solid #cbd5e1;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            transition: all .18s ease;
        }

            .status-option-card .opt-radio i {
                font-size: 12px;
                color: #fff;
                opacity: 0;
                transform: scale(.5);
                transition: all .18s ease;
            }

        .status-option-card.selected .opt-radio {
            border-color: #2563eb;
            background: #2563eb;
        }

        .payment-modal .status-option-card.selected .opt-radio {
            border-color: #059669;
            background: #059669;
        }

        .status-option-card.selected .opt-radio i {
            opacity: 1;
            transform: scale(1);
        }

        .status-modal .modal-footer {
            border-top: 1px solid #f1f5f9;
            padding: 1rem 1.5rem 1.25rem;
            background: #fafbfc;
            gap: 10px;
        }

            .status-modal .modal-footer .btn {
                border-radius: 11px;
                padding: .55rem 1.1rem;
                font-size: 13px;
                font-weight: 600;
            }

            .status-modal .modal-footer .btn-save-prachar {
                background: #2563eb;
                border-color: #2563eb;
            }

            .status-modal .modal-footer .btn-save-payment {
                background: #059669;
                border-color: #059669;
            }

        .user-cell {
            font-weight: 600;
            white-space: nowrap;
        }

        .date-cell {
            white-space: nowrap;
            color: #475569;
            font-size: 12px;
        }

        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: #64748b;
        }

            .empty-state i {
                font-size: 2.5rem;
                color: #cbd5e1;
                margin-bottom: .75rem;
            }

        .count-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 14px;
            border-radius: 999px;
            background: #fff;
            border: 1px solid #bfdbfe;
            color: #1d4ed8;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

            .count-chip strong {
                font-size: 14px;
            }

        .filter-panel {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border-bottom: 1px solid #e2e8f0;
            padding: 1.1rem 1.25rem 1.25rem;
        }

        .filter-panel-head {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            margin-bottom: 1rem;
        }

        .filter-panel-title {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            font-weight: 700;
            color: #0f172a;
        }

            .filter-panel-title i {
                width: 32px;
                height: 32px;
                border-radius: 10px;
                background: #0d6efd;
                color: #fff;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: 14px;
            }

        .filter-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 14px;
            margin-bottom: 14px;
        }

        .filter-field label {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .05em;
            text-transform: uppercase;
            color: #475569;
            margin-bottom: 7px;
        }

            .filter-field label i {
                color: #0d6efd;
                font-size: 12px;
            }

        .filter-field .form-select {
            border-radius: 10px;
            border: 1px solid #cbd5e1;
            background-color: #fff;
            font-size: 13px;
            font-weight: 500;
            color: #1e293b;
            padding: 9px 36px 9px 12px;
            box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
            transition: border-color .15s ease, box-shadow .15s ease;
        }

            .filter-field .form-select:focus {
                border-color: #0d6efd;
                box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.15);
            }

        .filter-actions {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 12px;
            padding-top: 4px;
            border-top: 1px dashed #cbd5e1;
        }

            .filter-actions .enquiry-search {
                flex: 1;
                min-width: 220px;
                max-width: none;
                margin-bottom: 0;
            }

        .btn-reset-filter {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            padding: 9px 18px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            white-space: nowrap;
            border: 1px solid #cbd5e1;
            background: #fff;
            color: #475569;
            text-decoration: none;
            transition: all .15s ease;
        }

            .btn-reset-filter:hover,
            .btn-reset-filter:focus {
                background: #f8fafc;
                border-color: #94a3b8;
                color: #0f172a;
                text-decoration: none;
            }

        .table-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: .85rem 1.25rem;
            background: #fff;
            border-bottom: 1px solid #edf2f7;
        }

        .table-card-title {
            font-size: 13px;
            font-weight: 700;
            color: #334155;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

            .table-card-title i {
                color: #0d6efd;
            }

        .enquiry-pagination {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: .9rem 1.25rem;
            border-top: 1px solid #edf2f7;
            background: #fafbfc;
        }

        .pagination-left {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 10px;
            font-size: 13px;
            color: #475569;
            font-weight: 600;
        }

        .pagination-left label {
            margin: 0;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .04em;
            color: #64748b;
        }

        .pagination-left .form-select {
            width: auto;
            min-width: 72px;
            border-radius: 9px;
            border-color: #cbd5e1;
            font-size: 13px;
            font-weight: 600;
            padding: 5px 28px 5px 10px;
            box-shadow: none;
        }

        .pagination-summary {
            color: #334155;
            font-weight: 700;
        }

        .enquiry-pagination .pagination {
            margin: 0;
            gap: 4px;
        }

        .enquiry-pagination .page-link {
            border-radius: 9px;
            border-color: #dbe3ee;
            color: #334155;
            font-size: 13px;
            font-weight: 600;
            padding: .35rem .7rem;
            min-width: 36px;
            text-align: center;
        }

        .enquiry-pagination .page-item.active .page-link {
            background: #2563eb;
            border-color: #2563eb;
        }

        .enquiry-pagination .page-item.disabled .page-link {
            color: #94a3b8;
            background: #f8fafc;
        }

        @media (max-width: 992px) {
            .filter-grid {
                grid-template-columns: 1fr 1fr;
            }
        }

        @media (max-width: 576px) {
            .filter-grid {
                grid-template-columns: 1fr;
            }

            .filter-actions {
                flex-direction: column;
                align-items: stretch;
            }

            .btn-reset-filter {
                width: 100%;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="body" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <asp:HiddenField ID="hf_prachar_id" runat="server" />
    <asp:HiddenField ID="hf_selected_status" runat="server" />
    <asp:Label ID="lbl_update_msg" runat="server" Visible="false" CssClass="alert status-alert" />

    <div class="page-breadcrumb d-sm-flex align-items-center mb-3">
        <div class="breadcrumb-title pe-3">
            <i class="bi bi-table"></i>&nbsp;&nbsp;Bulk Prachar Enquiry List
        </div>
        <div class="ms-auto">
            <a href="Prachar_Dashboard.aspx" class="btn btn-sm btn-outline-primary">
                <i class="bi bi-speedometer2"></i>Dashboard
            </a>
        </div>
    </div>


    <div class="card enquiry-card">
        <div class="filter-panel">
            <div class="filter-panel-head">
                <div class="filter-panel-title">
                    <i class="bi bi-funnel-fill"></i>&nbsp;
                    Filter Enquiries
                </div>
                <span class="count-chip">
                    <i class="bi bi-inboxes"></i>
                    Showing <strong>
                        <asp:Label ID="lbl_total_records" runat="server" Text="0" /></strong> records
                </span>
            </div>

            <div class="filter-grid">
                <div class="filter-field">
                    <label for="<%= ddl_prachar_type.ClientID %>">
                        <i class="bi bi-megaphone"></i>Prachar Type
                    </label>
                    <asp:DropDownList ID="ddl_prachar_type" runat="server" CssClass="form-select"
                        AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" />
                </div>
                <div class="filter-field">
                    <label for="<%= ddl_prachar_status.ClientID %>">
                        <i class="bi bi-hourglass-split"></i>Prachar Status
                    </label>
                    <asp:DropDownList ID="ddl_prachar_status" runat="server" CssClass="form-select"
                        AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" />
                </div>
                <div class="filter-field">
                    <label for="<%= ddl_payment_status.ClientID %>">
                        <i class="bi bi-credit-card"></i>Payment Status
                    </label>
                    <asp:DropDownList ID="ddl_payment_status" runat="server" CssClass="form-select"
                        AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" />
                </div>
            </div>

            <div class="filter-actions">
                <div class="enquiry-search enquiry-search-wrap">
                    <i class="bi bi-search"></i>
                    <input type="text" id="txtSearch" class="form-control"
                        placeholder="Search by prachar, vidhansabha, status, user..." />
                </div>
                <asp:LinkButton ID="btn_reset_filter" runat="server" CssClass="btn-reset-filter"
                    OnClick="btn_reset_filter_Click">
            <i class="bi bi-arrow-counterclockwise"></i> Reset Filters
                </asp:LinkButton>
            </div>
        </div>
    </div>


    <div class="card enquiry-card">


        <div class="table-card-header">
            <span class="table-card-title">
                <i class="bi bi-table"></i>Enquiry List
            </span>
        </div>

        <asp:Panel ID="pnl_empty" runat="server" Visible="false" CssClass="empty-state">
            <div><i class="bi bi-inbox"></i></div>
            <h6 class="mb-1">No enquiries found</h6>
            <p class="mb-0">When users send enquiry from Bulk Prachar page, records will appear here.</p>
            <asp:Label ID="lbl_error" runat="server" CssClass="text-danger d-block mt-2" Text="" />
        </asp:Panel>

        <asp:Panel ID="pnl_table" runat="server" Visible="false" CssClass="table-wrap">
            <table class="enquiry-table" id="tblEnquiries">
                <thead>
                    <tr>
                        <th class="sr-col">Sr</th>

                        <th>Prachar</th>
                        <th>Vidhansabha</th>
                        <th>Total Voter</th>
                        <th>Total Mobile</th>
                        <th>Cost / Unit</th>
                        <th>Total Cost</th>
                        <th>Prachar Status</th>
                        <th>Payment</th>
                        <th>Enquiry By</th>
                        <th>Enquiry Date</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptEnquiries" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td class="sr-col"><%# Container.ItemIndex + 1 %></td>
                                <td class="prachar-name"><%# SafeText(Eval("prachar")) %></td>
                                <td class="vidhan-cell">
                                    <span class="no"><%# SafeText(Eval("vidhansabha_no")) %> - <%# SafeText(Eval("vidhansabha_name")) %></span>
                                </td>
                                <td class="num-cell"><%# FormatNumber(Eval("total_voter")) %></td>
                                <td class="num-cell"><%# FormatNumber(Eval("total_mobile_no")) %></td>
                                <td class="money-cell"><%# FormatCostPerVoter(Eval("cost_per_voter")) %></td>
                                <td class="money-cell"><%# FormatTotalCost(Eval("total_cost")) %></td>
                                <td>
                                    <span class='<%# GetStatusBadgeClass(Eval("prachar_status")) %> status-clickable'
                                        role="button" tabindex="0"
                                        data-prachar-id="<%# AttrEncode(Eval("prachar_id")) %>"
                                        data-prachar-name="<%# AttrEncode(Eval("prachar")) %>"
                                        data-current="<%# AttrEncode(Eval("prachar_status")) %>"
                                        onclick="openPracharStatusModal(this)"
                                        onkeypress="if(event.key==='Enter'){openPracharStatusModal(this);}">
                                        <%# SafeText(Eval("prachar_status")) %>
                                    </span>
                                </td>
                                <td>
                                    <span class='<%# GetStatusBadgeClass(Eval("payment_status")) %> status-clickable'
                                        role="button" tabindex="0"
                                        data-prachar-id="<%# AttrEncode(Eval("prachar_id")) %>"
                                        data-prachar-name="<%# AttrEncode(Eval("prachar")) %>"
                                        data-current="<%# AttrEncode(Eval("payment_status")) %>"
                                        onclick="openPaymentStatusModal(this)"
                                        onkeypress="if(event.key==='Enter'){openPaymentStatusModal(this);}">
                                        <%# SafeText(Eval("payment_status")) %>
                                    </span>
                                </td>
                                <td class="user-cell"><%# SafeText(Eval("enquiry_by")) %></td>
                                <td class="date-cell"><%# FormatDate(Eval("enquiry_date")) %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>

            <div class="enquiry-pagination" id="enquiryPagination">
                <div class="pagination-left">
                    <label for="ddlPageSize">Rows</label>
                    <select id="ddlPageSize" class="form-select form-select-sm">
                        <option value="10" selected>10</option>
                        <option value="25">25</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                    </select>
                    <span class="pagination-summary" id="paginationSummary">Showing 0 of 0</span>
                </div>
                <nav aria-label="Enquiry table pagination">
                    <ul class="pagination pagination-sm mb-0" id="paginationControls"></ul>
                </nav>
            </div>
        </asp:Panel>
    </div>

    <!-- Prachar Status Modal -->
    <div class="modal fade status-modal prachar-modal" id="modalPracharStatus" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-top">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    <div class="status-modal-icon">
                        <i class="bi bi-megaphone-fill"></i>
                    </div>
                    <h5 class="status-modal-title">Update Prachar Status</h5>
                    <p class="status-modal-desc">Choose the current status of this enquiry</p>
                </div>
                <div class="modal-body">
                    <div class="enquiry-info-box">
                        <div class="info-icon"><i class="bi bi-file-earmark-text"></i></div>
                        <div class="info-text">
                            <span class="info-name" id="lblPracharModalName"></span>
                            <span class="info-id" id="lblPracharModalId"></span>
                        </div>
                    </div>
                    <div class="status-options" id="pracharStatusOptions">
                        <div class="status-option-card opt-pending" data-value="Pending" onclick="selectStatusOption(this, 'prachar')">
                            <div class="opt-icon"><i class="bi bi-clock-history"></i></div>
                            <div class="opt-content">
                                <span class="opt-title">Pending</span>
                                <span class="opt-sub">Enquiry is waiting to start</span>
                            </div>
                            <div class="opt-radio"><i class="bi bi-check-lg"></i></div>
                        </div>
                        <div class="status-option-card opt-finished" data-value="Finished" onclick="selectStatusOption(this, 'prachar')">
                            <div class="opt-icon"><i class="bi bi-check-circle"></i></div>
                            <div class="opt-content">
                                <span class="opt-title">Finished</span>
                                <span class="opt-sub">Prachar work is completed</span>
                            </div>
                            <div class="opt-radio"><i class="bi bi-check-lg"></i></div>
                        </div>
                        <div class="status-option-card opt-cancelled" data-value="Cancelled" onclick="selectStatusOption(this, 'prachar')">
                            <div class="opt-icon"><i class="bi bi-x-circle"></i></div>
                            <div class="opt-content">
                                <span class="opt-title">Cancelled</span>
                                <span class="opt-sub">Enquiry has been cancelled</span>
                            </div>
                            <div class="opt-radio"><i class="bi bi-check-lg"></i></div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer d-flex justify-content-end">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btn_update_prachar_status" runat="server" Text="Save Changes"
                        CssClass="btn btn-primary btn-save-prachar" OnClick="btn_update_prachar_status_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Payment Status Modal -->
    <div class="modal fade status-modal payment-modal" id="modalPaymentStatus" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-top">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    <div class="status-modal-icon">
                        <i class="bi bi-wallet2"></i>
                    </div>
                    <h5 class="status-modal-title">Update Payment Status</h5>
                    <p class="status-modal-desc">Mark whether payment has been received</p>
                </div>
                <div class="modal-body">
                    <div class="enquiry-info-box">
                        <div class="info-icon"><i class="bi bi-file-earmark-text"></i></div>
                        <div class="info-text">
                            <span class="info-name" id="lblPaymentModalName"></span>
                            <span class="info-id" id="lblPaymentModalId"></span>
                        </div>
                    </div>
                    <div class="status-options" id="paymentStatusOptions">
                        <div class="status-option-card opt-received" data-value="Received" onclick="selectStatusOption(this, 'payment')">
                            <div class="opt-icon"><i class="bi bi-check2-circle"></i></div>
                            <div class="opt-content">
                                <span class="opt-title">Received</span>
                                <span class="opt-sub">Payment has been collected</span>
                            </div>
                            <div class="opt-radio"><i class="bi bi-check-lg"></i></div>
                        </div>
                        <div class="status-option-card opt-not-received" data-value="Not Received" onclick="selectStatusOption(this, 'payment')">
                            <div class="opt-icon"><i class="bi bi-exclamation-circle"></i></div>
                            <div class="opt-content">
                                <span class="opt-title">Not Received</span>
                                <span class="opt-sub">Payment is still pending</span>
                            </div>
                            <div class="opt-radio"><i class="bi bi-check-lg"></i></div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer d-flex justify-content-end">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btn_update_payment_status" runat="server" Text="Save Changes"
                        CssClass="btn btn-success btn-save-payment" OnClick="btn_update_payment_status_Click" />
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        var pracharStatusModal;
        var paymentStatusModal;

        document.addEventListener('DOMContentLoaded', function () {
            var pracharEl = document.getElementById('modalPracharStatus');
            var paymentEl = document.getElementById('modalPaymentStatus');
            if (pracharEl) pracharStatusModal = new bootstrap.Modal(pracharEl);
            if (paymentEl) paymentStatusModal = new bootstrap.Modal(paymentEl);
        });

        function selectStatusOption(card, type) {
            var containerId = type === 'payment' ? 'paymentStatusOptions' : 'pracharStatusOptions';
            var container = document.getElementById(containerId);
            if (!container) return;

            var cards = container.getElementsByClassName('status-option-card');
            for (var i = 0; i < cards.length; i++) {
                cards[i].classList.remove('selected');
            }

            card.classList.add('selected');
            document.getElementById('<%= hf_selected_status.ClientID %>').value = card.getAttribute('data-value') || '';
        }

        function setSelectedOption(containerId, value) {
            var container = document.getElementById(containerId);
            if (!container) return;

            var cards = container.getElementsByClassName('status-option-card');
            var selected = (value || '').toLowerCase();
            var matched = false;

            for (var i = 0; i < cards.length; i++) {
                var isMatch = (cards[i].getAttribute('data-value') || '').toLowerCase() === selected;
                cards[i].classList.toggle('selected', isMatch);
                if (isMatch) matched = true;
            }

            document.getElementById('<%= hf_selected_status.ClientID %>').value = matched ? value : '';
        }

        function openPracharStatusModal(el) {
            var pracharId = el.getAttribute('data-prachar-id') || '';
            var pracharName = el.getAttribute('data-prachar-name') || '';
            var current = el.getAttribute('data-current') || '';

            document.getElementById('<%= hf_prachar_id.ClientID %>').value = pracharId;
            document.getElementById('lblPracharModalName').innerText = pracharName;
            document.getElementById('lblPracharModalId').innerText = 'Enquiry ID: #' + pracharId;
            setSelectedOption('pracharStatusOptions', current);

            if (pracharStatusModal) pracharStatusModal.show();
        }

        function openPaymentStatusModal(el) {
            var pracharId = el.getAttribute('data-prachar-id') || '';
            var pracharName = el.getAttribute('data-prachar-name') || '';
            var current = el.getAttribute('data-current') || '';

            document.getElementById('<%= hf_prachar_id.ClientID %>').value = pracharId;
            document.getElementById('lblPaymentModalName').innerText = pracharName;
            document.getElementById('lblPaymentModalId').innerText = 'Enquiry ID: #' + pracharId;
            setSelectedOption('paymentStatusOptions', current);

            if (paymentStatusModal) paymentStatusModal.show();
        }

        var enquiryPager = {
            currentPage: 1,
            getPageSize: function () {
                var size = parseInt($('#ddlPageSize').val(), 10);
                return isNaN(size) || size < 1 ? 10 : size;
            },
            init: function () {
                var self = this;
                if (!$('#tblEnquiries tbody tr').length) {
                    $('#enquiryPagination').hide();
                    return;
                }

                $('#txtSearch').on('keyup', function () {
                    self.currentPage = 1;
                    self.apply();
                });

                $('#ddlPageSize').on('change', function () {
                    self.currentPage = 1;
                    self.apply();
                });

                $(document).on('click', '#paginationControls .page-link', function (e) {
                    e.preventDefault();
                    if ($(this).parent().hasClass('disabled') || $(this).parent().hasClass('active')) return;

                    var page = parseInt($(this).data('page'), 10);
                    if (!isNaN(page)) {
                        self.currentPage = page;
                        self.apply();
                    }
                });

                this.apply();
            },
            getMatchedRows: function () {
                var search = ($('#txtSearch').val() || '').toLowerCase();
                var matched = [];

                $('#tblEnquiries tbody tr').each(function () {
                    var $row = $(this);
                    var isMatch = $row.text().toLowerCase().indexOf(search) > -1;
                    $row.toggleClass('search-match', isMatch);
                    if (isMatch) matched.push($row);
                });

                return matched;
            },
            apply: function () {
                var pageSize = this.getPageSize();
                var matched = this.getMatchedRows();
                var total = matched.length;
                var totalPages = Math.max(1, Math.ceil(total / pageSize));

                if (this.currentPage > totalPages) this.currentPage = totalPages;
                if (this.currentPage < 1) this.currentPage = 1;

                $('#tblEnquiries tbody tr').hide();

                var start = (this.currentPage - 1) * pageSize;
                var end = Math.min(start + pageSize, total);

                for (var i = start; i < end; i++) {
                    var $row = matched[i];
                    $row.show();
                    $row.find('.sr-col').text(i + 1);
                }

                this.renderSummary(total, start, end);
                this.renderControls(totalPages);
                $('#enquiryPagination').toggle(total > 0);
            },
            renderSummary: function (total, start, end) {
                if (total === 0) {
                    $('#paginationSummary').text('Showing 0 of 0');
                    return;
                }

                $('#paginationSummary').text('Showing ' + (start + 1) + '-' + end + ' of ' + total);
            },
            renderControls: function (totalPages) {
                var self = this;
                var $controls = $('#paginationControls').empty();

                if (totalPages <= 1) return;

                $controls.append(self.buildPageItem('‹', self.currentPage - 1, self.currentPage === 1));

                var pages = self.getPageNumbers(self.currentPage, totalPages);
                for (var i = 0; i < pages.length; i++) {
                    var item = pages[i];
                    if (item === '...') {
                        $controls.append('<li class="page-item disabled"><span class="page-link">...</span></li>');
                    } else {
                        $controls.append(self.buildPageItem(item, item, false, item === self.currentPage));
                    }
                }

                $controls.append(self.buildPageItem('›', self.currentPage + 1, self.currentPage === totalPages));
            },
            buildPageItem: function (label, page, disabled, active) {
                var classes = ['page-item'];
                if (disabled) classes.push('disabled');
                if (active) classes.push('active');

                return '<li class="' + classes.join(' ') + '">' +
                    '<a class="page-link" href="#" data-page="' + page + '">' + label + '</a></li>';
            },
            getPageNumbers: function (current, total) {
                if (total <= 7) {
                    var all = [];
                    for (var i = 1; i <= total; i++) all.push(i);
                    return all;
                }

                var pages = [1];
                if (current > 3) pages.push('...');

                var from = Math.max(2, current - 1);
                var to = Math.min(total - 1, current + 1);
                for (var p = from; p <= to; p++) pages.push(p);

                if (current < total - 2) pages.push('...');
                pages.push(total);
                return pages;
            }
        };

        $(document).ready(function () {
            enquiryPager.init();
        });
    </script>
</asp:Content>
