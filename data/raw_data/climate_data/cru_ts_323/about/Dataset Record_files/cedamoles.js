// Define a global variable for where the page_exit_dialog_box div should redirect to on close
var download_page_exit_dialog_destination_url = "";
var apply_page_exit_dialog_destination_url = "";

$(function() {
    $( "#download_page_exit_dialog_box" ).dialog({
        autoOpen: false,
        modal: true,
        width: 600,
        buttons: {
            Ok: function() { $( this ).dialog( "close" ); }
        },
        close: function() {
            window.location.href = download_page_exit_dialog_destination_url;
        }
    });
    
     $( "#apply_page_exit_dialog_box" ).dialog({
        autoOpen: false,
        modal: true,
        width: 600,
        buttons: {
            Ok: function() { $( this ).dialog( "close" ); }
        },
        close: function() {
            window.location.href = apply_page_exit_dialog_destination_url;
        }
    });
});

