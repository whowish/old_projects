/* Demo Note:  This demo uses a FileProgress class that handles the UI for displaying the file name and percent complete.
The FileProgress class is not part of SWFUpload.
*/


/* **********************
   Event Handlers
   These are my custom event handlers to make my
   web application behave the way I went when SWFUpload
   completes different tasks.  These aren't part of the SWFUpload
   package.  They are part of my application.  Without these none
   of the actions SWFUpload makes will show up in my application.
   ********************** */
function deleteSwfFileUpload(file_id)
{
	try {
		if ($('#' + $.escape(file_id)).length == 0) 
			return;
		
		var container = $('#' + $.escape(file_id))[0];
		
		delete_image(container);
	} catch (e){
		$.error_log('swfupload.deleteSwfFileUpload',e);
	}
}
  
function fileQueued(file) {
	
	try {
		var available_span = $('.swfupload_dialogbox_empty_image');
		if (available_span.length == 0)
		{
			delete_image($('.swfupload_dialogbox_image_unit')[0]);
			available_span = $('#swfupload_image_container > span[class=swfupload_dialogbox_empty_image]');
		}
		
		available_span = available_span[0];
		$(available_span).removeClass('swfupload_dialogbox_empty_image')
						.addClass('swfupload_dialogbox_loading_image')
						.attr('id',file.id)
						.append('<span class="progress">0%</span>');
		
		var file_id = file.id;
		$(available_span).bind('mouseenter', function(){
		
			if ($('.swfupload_dialogbox_delete_image_overlay', this).length == 0) {
				$(this).append(' \
				<div class="swfupload_dialogbox_delete_image_overlay"> \
					<span class="swfupload_dialogbox_delete_image_overlay_caption"> \
						<table cellpadding="0" cellspacing="0" border="0"><tr><td> \
							<span class="swfupload_dialogbox_delete_image_overlay_icon"></span> \
						</td><td> \
							delete \
						</td></tr></table> \
					</span>\
				</div>\
			');
				
				$('.swfupload_dialogbox_delete_image_overlay_caption', this).bind('click', function(){
					
					try {
						swfUploadInstance.cancelUpload(file_id, false);
					} catch (e) {
						alert(e);
					}
					
					try {
						deleteSwfFileUpload(file_id);
					} catch (e) {
						alert(e);
					}
				});
			}
			
		});
		
		
		$(available_span).bind('mouseleave', function(){
			$('.swfupload_dialogbox_delete_image_overlay', this).remove();
		});
		
		return true;
	} catch (e) {
		alert(e);
		$.error_log('swfupload.fileQueued',e);
	}
	
	return false;
}

function fileQueueError(file, errorCode, message) {
	try {
		
		
		
		if (errorCode === SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED) {
			alert("You have attempted to queue too many files.\n" + (message === 0 ? "You have reached the upload limit." : "You may select " + (message > 1 ? "up to " + message + " files." : "one file.")));
			return;
		}
		
		if (file != null && file != undefined) {
			deleteSwfFileUpload(file.id);
		}

//		var progress = new FileProgress(file, this.customSettings.progressTarget);
//		progress.setError();
//		progress.toggleCancel(false);

		switch (errorCode) {
		case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
			alert(file.name + " is too big.");
			this.debug("Error Code: File too big, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
			alert(file.name + " is a zero byte file.");
			this.debug("Error Code: Zero byte file, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
			alert(file.name + " is not allowed because it is not an image file.");
			this.debug("Error Code: Invalid File Type, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		default:
			if (file !== null) {
				alert(file.name + " causes unknown error. Please try 'simple upload' mode");
			}
			this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		}
	} catch (ex) {
        this.debug(ex);
		$.error_log('swfupload.fileQueueError',ex);
    }
}

function fileDialogComplete(numFilesSelected, numFilesQueued) {
	try {
		// I want auto start the upload and I can do that here 
		this.startUpload();
	} catch (ex)  {
        this.debug(ex);
		$.error_log('swfupload.fileDialogComplete',ex);
	}
}

function uploadStart(file) {
	var first_one = $('.swfupload_dialogbox_loading_image');
	
	// there is no available slot
	if (first_one.length == 0) return false;
	// there is available slot;
	else return true;
}

function uploadProgress(file, bytesLoaded, bytesTotal) {

	var block = $('#'+file.id);
	
	if (block.length == 0) return;
	block = block[0];
	
	if (bytesLoaded == bytesTotal) {
		$('.progress', block).html('Showing ...');
	}
	else {
		$('.progress', block).html(Math.ceil(bytesLoaded * 100 / bytesTotal) + '%');
	}
}

function uploadSuccess(file, serverData){
	try {
		var response = jQuery.parseJSON(serverData);
		
		if (response.ok == undefined)
		{
			alert("The server is error. "+serverData);
			return;
		}
		
		if (response.ok == false)
		{
			alert("There is an error: "+response.error_message);
			return;
		}

		var block = $('#'+file.id);
		
		if (block.length == 0) return;
		block = block[0];
		$(block).removeClass('swfupload_dialogbox_loading_image')
				.addClass('swfupload_dialogbox_image_unit');
						 
		$('.progress',block).remove();
		
		$("input", block).val(response.filename);
		$(block).css({
			"background-image": "url(/thumbnail/480x275" + response.filename + ")"
		});
	} catch (e)
	{
		alert(e);
		$.error_log('swfupload.uploadSuccess',"serverData="+serverData+ "\n\n" + e);
	}
}	

function uploadError(file, errorCode, message) {
	try {
		
		if (file != null && file != undefined) {
			deleteSwfFileUpload(file.id);
		}
		
//		var progress = new FileProgress(file, this.customSettings.progressTarget);
//		progress.setError();
//		progress.toggleCancel(false);

		switch (errorCode) {
		case SWFUpload.UPLOAD_ERROR.HTTP_ERROR:
			alert('An error occurs while uploading '+file.name+'\n (' + message + ')');
			this.debug("Error Code: HTTP Error, File name: " + file.name + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED:
			alert('Uploading '+file.name+' has failed for the following reason\n (' + message + ')');
			this.debug("Error Code: Upload Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.IO_ERROR:
			alert('Writing '+file.name+' to the server has failed\n (' + message + ')');
			this.debug("Error Code: IO Error, File name: " + file.name + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR:
			alert('Uploading '+file.name+' causes a security issue\n (' + message + ')');
			this.debug("Error Code: Security Error, File name: " + file.name + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
			alert('Uploading '+file.name+' has reached the upload limit. Therefore, it cannot be uploaded.\n (' + message + ')');
			this.debug("Error Code: Upload Limit Exceeded, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.FILE_VALIDATION_FAILED:
			alert('The server cannot validate '+file.name+'. Therefore, the file cannot be uploaded.\n (' + message + ')');
			this.debug("Error Code: File Validation Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
			// If there aren't any files left (they were all cancelled) disable the cancel button
//			if (this.getStats().files_queued === 0) {
//				document.getElementById(this.customSettings.cancelButtonId).disabled = true;
//			}
			//progress.setStatus("Cancelled");
			//progress.setCancelled();
			break;
		case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
			//progress.setStatus("Stopped");
			break;
		default:
			alert("Unhandled Error "+file.name+": " + errorCode);
			this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		}
	} catch (ex) {
        this.debug(ex);
		$.error_log('swfupload.uploadError',ex);
    }
}

function uploadComplete(file) {
	/*if (this.getStats().files_queued === 0) {
		document.getElementById(this.customSettings.cancelButtonId).disabled = true;
	}*/
}

// This event comes from the Queue Plugin
function queueComplete(numFilesUploaded) {
	/*var status = document.getElementById("divStatus");
	status.innerHTML = numFilesUploaded + " file" + (numFilesUploaded === 1 ? "" : "s") + " uploaded.";
	*/
}
