function ShowMessage(message, messagetype) {
    
    var html = "";
    switch (messagetype) {
        case 'Success':
            
            html += "<div class='alert border-0 bg-light-success alert-dismissible fade show py-2'>";
            html += "<div class='d-flex align-items-center'>";
            html += " <div class='fs-3 text-success'><i class='bi bi-check-circle-fill'></i> </div>";
            html += "<div class='ms-3'><div class='text-success'>" + message + "</div> </div></div>";
            html += "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button></div>";

            break;
        case 'Error':
            html += "<div class='alert border-0 bg-light-danger alert-dismissible fade show py-2'>";
            html += "<div class='d-flex align-items-center'>";
            html += " <div class='fs-3 text-danger'><i class='bi bi-x-circle-fill'></i> </div>";
            html += "<div class='ms-3'><div class='text-danger'>" + message + "</div> </div></div>";
            html += "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button></div>";
            break;
        case 'Warning':

            html += "<div class='alert border-0 bg-light-warning alert-dismissible fade show py-2'>";
            html += "<div class='d-flex align-items-center'>";
            html += " <div class='fs-3 text-warning'><i class='bi bi-exclamation-triangle-fill'></i> </div>";
            html += "<div class='ms-3'><div class='text-warning'>" + message + "</div> </div></div>";
            html += "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button></div>";
            break;
        default:

            html += "<div class='alert border-0 bg-light-info alert-dismissible fade show py-2'>";
            html += "<div class='d-flex align-items-center'>";
            html += " <div class='fs-3 text-info'><i class='bi bi-info-circle-fill'></i> </div>";
            html += "<div class='ms-3'><div class='text-info'>" + message + "</div> </div></div>";
            html += "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button></div>";
    }

    $('#alert_container').append(html);


    $('#alert_container').delay(3000).fadeOut('slow');


}



$(document).ready(function () {
    $(".txt_veh").keyup(function () {

        var veh_no_1 = $("#<%= txt_veh_no_1.ClientID%>").val();
        var veh_no_2 = $("#<%= txt_veh_no_2.ClientID%>").val();
        var veh_no_3 = $("#<%= txt_veh_no_3.ClientID%>").val();
        var veh_no_4 = $("#<%= txt_veh_no_4.ClientID%>").val();
        var veh_no = veh_no_1 + " " + veh_no_2 + " " + veh_no_3 + " " + veh_no_4;

        $.ajax({
            type: "POST",
            url: "Customer_Master.aspx/check_vehicle",
            data: JSON.stringify({ "veh_no": veh_no }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                if (response.d == "1") {
                    var myModal = new bootstrap.Modal(document.getElementById('modal_vehicle_no_exists'));
                    myModal.show();
                }
            },
            error: function (error) {
                console.log(error);
            }
        });
    });

   
});


