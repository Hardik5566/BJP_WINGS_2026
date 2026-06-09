<%@ Page Title="" Language="C#" MasterPageFile="~/MasterAdmin/MasterPage.master" AutoEventWireup="true" CodeFile="Prachar_Dashboard.aspx.cs" Inherits="MasterAdmin_Prachar_Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="title" runat="Server">
    Bulk Prachar Dashboard
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="head" runat="Server">
    <style>
        .prachar-stat-card {
            border: 0;
            border-radius: 14px;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.08);
            overflow: hidden;
            height: 100%;
        }

            .prachar-stat-card .card-body {
                padding: 1.25rem 1.35rem;
            }

        .prachar-stat-icon {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        .prachar-stat-label {
            font-size: 12px;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: #6c757d;
            font-weight: 700;
        }

        .prachar-stat-value {
            font-size: 2rem;
            line-height: 1.1;
            font-weight: 700;
            margin-top: .35rem;
        }

        .prachar-stat-sub {
            font-size: 12px;
            color: #6c757d;
            margin-top: .35rem;
        }

        .bg-total {
            background: #e8f1ff;
            color: #0d6efd;
        }

        .bg-pending {
            background: #fff4e5;
            color: #fd7e14;
        }

        .bg-finished {
            background: #e8f8ef;
            color: #198754;
        }

        .bg-cancelled {
            background: #fdecec;
            color: #dc3545;
        }

        .text-total {
            color: #0d6efd;
        }

        .text-pending {
            color: #fd7e14;
        }

        .text-finished {
            color: #198754;
        }

        .text-cancelled {
            color: #dc3545;
        }

        .summary-panel {
            border: 0;
            border-radius: 14px;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.06);
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: .85rem;
            font-size: 14px;
            font-weight: 600;
        }

            .summary-row:last-child {
                margin-bottom: 0;
            }

        .progress {
            height: 8px;
            border-radius: 999px;
            background: #eef2f7;
        }

        .progress-bar {
            border-radius: 999px;
        }

        .stat-card-link {
            display: block;
            text-decoration: none;
            color: inherit;
            height: 100%;
            transition: transform .15s ease, box-shadow .15s ease;
        }

            .stat-card-link:hover {
                color: inherit;
                transform: translateY(-2px);
            }

            .stat-card-link:hover .prachar-stat-card {
                box-shadow: 0 12px 28px rgba(15, 23, 42, 0.12);
            }

        .summary-link {
            text-decoration: none;
            color: inherit;
            display: block;
            border-radius: 10px;
            padding: 4px 0;
            transition: background .15s ease;
        }

            .summary-link:hover {
                color: inherit;
                background: #f8fafc;
            }
    </style>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="body" runat="Server">
    <div class="page-breadcrumb d-sm-flex align-items-center mb-3">
        <div class="breadcrumb-title pe-3">
            <i class="bi bi-megaphone-fill"></i>&nbsp;&nbsp;Bulk Prachar Dashboard
        </div>
        <div class="ms-auto">
            <span class="badge bg-light text-dark border">Live Enquiry Summary</span>
        </div>
    </div>

    <div class="row row-cols-1 row-cols-md-2 row-cols-xl-4 g-3 mb-4">
        <div class="col">
            <a href="Bulk_Prachar_Enquiry_List.aspx" class="stat-card-link">
                <div class="card prachar-stat-card">
                    <div class="card-body">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <div class="prachar-stat-label">Total Enquiry</div>
                                <div class="prachar-stat-value text-total">
                                    <asp:Label ID="lbl_total_enquiry" runat="server" Text="0" />
                                </div>
                                <div class="prachar-stat-sub">All bulk prachar requests</div>
                            </div>
                            <div class="prachar-stat-icon bg-total">
                                <i class="bi bi-inboxes-fill"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </a>
        </div>

        <div class="col">
            <a href="Bulk_Prachar_Enquiry_List.aspx?prachar_status=Pending" class="stat-card-link">
                <div class="card prachar-stat-card">
                    <div class="card-body">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <div class="prachar-stat-label">Pending</div>
                                <div class="prachar-stat-value text-pending">
                                    <asp:Label ID="lbl_pending_count" runat="server" Text="0" />
                                </div>
                                <div class="prachar-stat-sub">
                                    <asp:Label ID="lbl_pending_pct" runat="server" Text="0%" />
                                    of total
                                </div>
                            </div>
                            <div class="prachar-stat-icon bg-pending">
                                <i class="bi bi-hourglass-split"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </a>
        </div>

        <div class="col">
            <a href="Bulk_Prachar_Enquiry_List.aspx?prachar_status=Finished" class="stat-card-link">
                <div class="card prachar-stat-card">
                    <div class="card-body">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <div class="prachar-stat-label">Finished</div>
                                <div class="prachar-stat-value text-finished">
                                    <asp:Label ID="lbl_finished_count" runat="server" Text="0" />
                                </div>
                                <div class="prachar-stat-sub">
                                    <asp:Label ID="lbl_finished_pct" runat="server" Text="0%" />
                                    of total
                                </div>
                            </div>
                            <div class="prachar-stat-icon bg-finished">
                                <i class="bi bi-check-circle-fill"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </a>
        </div>

        <div class="col">
            <a href="Bulk_Prachar_Enquiry_List.aspx?prachar_status=Cancelled" class="stat-card-link">
                <div class="card prachar-stat-card">
                    <div class="card-body">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <div class="prachar-stat-label">Cancelled</div>
                                <div class="prachar-stat-value text-cancelled">
                                    <asp:Label ID="lbl_cancelled_count" runat="server" Text="0" />
                                </div>
                                <div class="prachar-stat-sub">
                                    <asp:Label ID="lbl_cancelled_pct" runat="server" Text="0%" />
                                    of total
                                </div>
                            </div>
                            <div class="prachar-stat-icon bg-cancelled">
                                <i class="bi bi-x-circle-fill"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </a>
        </div>
    </div>

    <div class="row g-3">
        <div class="col-lg-8">
            <div class="card summary-panel">
                <div class="card-body">
                    <h5 class="mb-3">Status Overview</h5>

                    <a href="Bulk_Prachar_Enquiry_List.aspx?prachar_status=Pending" class="summary-link">
                        <div class="summary-row">
                            <span class="text-pending">Pending</span>
                            <span>
                                <asp:Label ID="lbl_pending_summary" runat="server" Text="0" /></span>
                        </div>
                        <div class="progress mb-3">
                            <div id="pending_bar" runat="server" class="progress-bar bg-warning" style="width: 0%"></div>
                        </div>
                    </a>

                    <a href="Bulk_Prachar_Enquiry_List.aspx?prachar_status=Finished" class="summary-link">
                        <div class="summary-row">
                            <span class="text-finished">Finished</span>
                            <span>
                                <asp:Label ID="lbl_finished_summary" runat="server" Text="0" /></span>
                        </div>
                        <div class="progress mb-3">
                            <div id="finished_bar" runat="server" class="progress-bar bg-success" style="width: 0%"></div>
                        </div>
                    </a>

                    <a href="Bulk_Prachar_Enquiry_List.aspx?prachar_status=Cancelled" class="summary-link">
                        <div class="summary-row">
                            <span class="text-cancelled">Cancelled</span>
                            <span>
                                <asp:Label ID="lbl_cancelled_summary" runat="server" Text="0" /></span>
                        </div>
                        <div class="progress">
                            <div id="cancelled_bar" runat="server" class="progress-bar bg-danger" style="width: 0%"></div>
                        </div>
                    </a>
                </div>
            </div>
        </div>
</asp:Content>
