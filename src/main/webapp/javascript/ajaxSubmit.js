/** 
    <!--AJAX 
    This is the generic function we're going to use to replace the old form submissions.
    It's a pseudo lazy way to perform these updates, only in the way that it handles errors.
    for now we're just going to search for the text <strong>Error:</strong>, and if we see 
    it display it in the ajax_response_dialog to indicate to the user that something crapped out
    on us. Otherwise, everything can work as normal. I tried to mark any edits with an 
    AJAX html comment, but I may have missed a few.
    
    TODO 
    -- resource bundle the ajax_response_dailog title 
     
*/
/**
 * This function is the generic update function. It will be placed on all of the 
 * old submit buttons, making the old form submits use jquery posts.
 * 
 * params:
	   old_dailog_box_id  - this is the string id pointing the dialog box that needs to be closed
	   new_value_function - this is a function that will get and return the new value to be set by the old_value_function
	   old_value_function - this is a function that will take the result of the new_value_function and set the old_value ( the value on the web page)
	   form_jquery_object - this is a jquery object of the old submit form. note: needs a valid action, and needs to have all parameters present as it is serialized
 *
 * Note: the new/old id's should not have leading #, and can both be swapped out for functions
 */
function ajaxSubmit(new_value_function, old_value_function, form_jquery_object, old_dialog_box_id){
    /**
     * First we'll define the function that handles the server response.
     * This function checks for an error and displays the html in the ajax_response_dialog 
     * box. If no error is present the function updates the old value to the new value.
     */
    function handleServerResponse(html_response){
    	 // debug 
    	 console.log(html_response);
    	 
    	// close the old dialog box if it's requested
    	if (typeof old_dialog_box_id !== "undefined"){
    		$("#"+old_dialog_box_id).dialog("close");
    	}
        // check for an error 
        if (html_response.match(/[^>]*?(Error|Failure)[^>]*?/gi)){
        	// we have a problem! display the response html and finish
        	var ajax_d= $("#ajax_response_dialog");
        	ajax_d.dialog({
        		autoOpen: false,
                draggable: true,
                resizable: false,
                width:'auto',
                height:'auto',
                close:function(){
                    // remove all added dialog stuff 
                	$(this).dialog("destroy") 
                }
        	}).html(html_response);
        	ajax_d.dialog("open");
        }
        else {
        	// get the new value and set it on the old value
        	old_value_function(new_value_function());
        }
    }
    // ajax call parameters
    var actionURL = form_jquery_object.attr("action") ;
    var postParameters = form_jquery_object.serialize();
    var responseType = 'html';
    /**
     * Below is the ajax call to the server. It uses the above handleServerResponse function
     * to take action when the server responds. It also uses the form object to know where to
     * send the request, and what data to send
     */
    $.post(actionURL, postParameters, handleServerResponse, responseType)
    .fail(function(error){
        // sometimes the server hiccups for some reason. make sure we alert the user 
        // to the hiccup and log the response object to the console.
        console.log(error);
        alert("Something is broken on the server :-(. Sorry home-skillet");
    });
}	   