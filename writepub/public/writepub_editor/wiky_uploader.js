/**
 * Wiky_uploader scripts, which turns a button input an upload button by placing a transparent <input type="file"> on the target button
 * 
 * I don't claim any ownership in this file, nor make money out of it.
 * Most (99%) of the code are copied (and slightly modified) from fileuploader.js - http://github.com/valums/file-uploader
 * 
 * I have modified the code because I have difficulty using the library with my website.
 * For license information, please consult: http://github.com/valums/file-uploader
 * 
 * - Tanin Na Nakorn
 * 5 July 2011
 */

(function($){

 	$.fn.extend({ 
	
		wiky_uploader_tools: function() {
			var self = this[0];
			
			return {
				cancel: function(fileId) {
					self._wiky_uploader._handler.cancel(fileId);
				}
			};
		},

 		wiky_uploader: function(options) {
			
			default_options = {
				
				// params to be sent with the upload
				params: {},
				
				// name of input
				name: "Filedata",
				prefixId: "AjaxUploadButton",
				
				// target upload path
				action: "/",
				
				// multiple
				multiple: true,
				
				// debug message
				debug: false,
				
		        // validation        
		        allowedExtensions: [],               
		        sizeLimit: 0,   
		        minSizeLimit: 0,    
				
				// button classes on different state
				mousedown_class: "",
				mouseover_class: "",
				disabled_class: "",
				
				// events
		        // return false to cancel submit
		        onSubmit: function(id, fileName){},
		        onProgress: function(id, fileName, loaded, total){},
		        onComplete: function(id, fileName, responseJSON){},
		        onCancel: function(id, fileName){},
				
				// messages                
		        messages: {
		            typeError: "{file} has invalid extension. Only {extensions} are allowed.",
		            sizeError: "{file} is too large, maximum file size is {sizeLimit}.",
		            minSizeError: "{file} is too small, minimum file size is {minSizeLimit}.",
		            emptyError: "{file} is empty, please select files again without it.",
		            onLeave: "The files are being uploaded, if you leave now the upload will be cancelled."            
		        },
		        showMessage: function(message){
		            alert(message);
		        },
				
				// 3 is a good number. Do not change it!
				maxConnections: 3
			};
			
			$.extend(default_options,options);
			
			this[0]._wiky_uploader = new wiky_uploader(this[0],default_options);
		}
		
	});
	
})(jQuery);


wiky_uploader_helper = {}

wiky_uploader_helper.getUniqueId = (function(){
    var id = 0;
    return function(){ return id++; };
})();

    /**
    * Creates and returns element from html chunk
    * Uses innerHTML to create an element
    */
wiky_uploader_helper.toElement = (function(){
    var div = document.createElement('div');
    return function(html){
        div.innerHTML = html;
        var el = div.firstChild;
        return div.removeChild(el);
    };
})();

wiky_uploader_helper.copyLayout = function (from, to){
    var box = wiky_uploader_helper.getBox(from);
    
    $(to).css({
        position: 'absolute',                    
        left : box.left + 'px',
        top : box.top + 'px',
        width : from.offsetWidth + 'px',
        height : from.offsetHeight + 'px'
    });          
}

wiky_uploader_helper.getBox = function(el) {
    var left, right, top, bottom;
    var offset = $(el).offset();
    left = offset.left;
    top = offset.top;
    
    right = left + el.offsetWidth;
    bottom = top + el.offsetHeight;
    
    return {
        left: left,
        right: right,
        top: top,
        bottom: bottom
    };
}

wiky_uploader_helper.indexOf = function(arr, elt, from){
    if (arr.indexOf) return arr.indexOf(elt, from);
    
    from = from || 0;
    var len = arr.length;    
    
    if (from < 0) from += len;  

    for (; from < len; from++){  
        if (from in arr && arr[from] === elt){  
            return from;
        }
    }  
    return -1;  
}; 

wiky_uploader_helper.obj2url = function(obj, temp, prefixDone){
    var uristrings = [],
        prefix = '&',
        add = function(nextObj, i){
            var nextTemp = temp 
                ? (/\[\]$/.test(temp)) // prevent double-encoding
                   ? temp
                   : temp+'['+i+']'
                : i;
            if ((nextTemp != 'undefined') && (i != 'undefined')) {  
                uristrings.push(
                    (typeof nextObj === 'object') 
                        ? wiky_uploader_helper.obj2url(nextObj, nextTemp, true)
                        : (Object.prototype.toString.call(nextObj) === '[object Function]')
                            ? encodeURIComponent(nextTemp) + '=' + encodeURIComponent(nextObj())
                            : encodeURIComponent(nextTemp) + '=' + encodeURIComponent(nextObj)                                                          
                );
            }
        }; 

    if (!prefixDone && temp) {
      prefix = (/\?/.test(temp)) ? (/\?$/.test(temp)) ? '' : '&' : '?';
      uristrings.push(temp);
      uristrings.push(wiky_uploader_helper.obj2url(obj));
    } else if ((Object.prototype.toString.call(obj) === '[object Array]') && (typeof obj != 'undefined') ) {
        // we wont use a for-in-loop on an array (performance)
        for (var i = 0, len = obj.length; i < len; ++i){
            add(obj[i], i);
        }
    } else if ((typeof obj != 'undefined') && (obj !== null) && (typeof obj === "object")){
        // for anything else but a scalar, we will use for-in-loop
        for (var i in obj){
            add(obj[i], i);
        }
    } else {
        uristrings.push(encodeURIComponent(temp) + '=' + encodeURIComponent(obj));
    }

    return uristrings.join(prefix)
                     .replace(/^&/, '')
                     .replace(/%20/g, '+'); 
};

wiky_uploader = function(button,options) {
	this._options = options;
	
	// number of files being uploaded
    this._filesInProgress = 0;
	this._handler = this._createUploadHandler();
	
	this._preventLeaveInProgress();    
	
	this._button = button;
	this._rerouteClicks();
	this._input = this._createInput();
	
}


wiky_uploader.prototype = {

	_createUploadHandler: function(){
        var self = this,
            handlerClass;        
        
        if(qq.UploadHandlerXhr.isSupported()){           
            handlerClass = 'UploadHandlerXhr';                        
        } else {
            handlerClass = 'UploadHandlerForm';
        }

        var handler = new qq[handlerClass]({
            debug: this._options.debug,
            action: this._options.action,  
			name: this._options.name,       
            maxConnections: this._options.maxConnections,   
            onProgress: function(id, fileName, loaded, total){                
                self._onProgress(id, fileName, loaded, total);
                self._options.onProgress(id, fileName, loaded, total);                    
            },            
            onComplete: function(id, fileName, result){
                self._onComplete(id, fileName, result);
                self._options.onComplete(id, fileName, result);
            },
            onCancel: function(id, fileName){
                self._onCancel(id, fileName);
                self._options.onCancel(id, fileName);
            }
        });

        return handler;
    },
	
	_preventLeaveInProgress: function(){
        var self = this;
        
        $(window).bind('beforeunload', function(e){
            if (self._filesInProgress == 0){return;}

            var e = e || window.event;
            // for ie, ff
            e.returnValue = self._options.messages.onLeave;
            // for webkit
            return self._options.messages.onLeave;             
        });        
    },    

	/**
     * Function makes sure that when user clicks upload button,
     * the this._input is clicked instead
     */
    _rerouteClicks: function(){
        var self = this;
        
        // IE will later display 'access denied' error
        // if you use using self._input.click()
        // other browsers just ignore click()
        $(self._button).mouseover(function(){          
            if ( ! self._input){
                self._createInput();
            }
            
            var div = self._input.parentNode;                            
            wiky_uploader_helper.copyLayout(self._button, div);
            div.style.visibility = 'visible';
        });
        
        
        // commented because we now hide input on mouseleave
        /**
         * When the window is resized the elements 
         * can be misaligned if button position depends
         * on window size
         */
        //addResizeEvent(function(){
        //    if (self._input){
        //        copyLayout(self._button, self._input.parentNode);
        //    }
        //});            
                                     
    },
    reset: function(){
        if (this._input.parentNode){
            $(this._input.parentNode).remove();    
        }                
        
        $(this._button).removeClass(this._options.mouseover_class);
		$(this._button).removeClass(this._options.mousedown_class);
        this._input = this._createInput();
    },    
	/**
	 * Creates invisible file input 
	 * that will hover above the button
	 * <div><input type='file' /></div>
	 * Copied from fileuploader.js - http://github.com/valums/file-uploader
	 */
	_createInput: function(){ 
	    var self = this;
	                
	    var input = document.createElement("input");
	    input.setAttribute('type', 'file');
	    input.setAttribute('name', self._options.name);
		input.setAttribute('id', self._options.prefixId + "_" + self._button.id);
		
		if (self._options.multiple == true) {
			input.setAttribute('multiple', 'multiple');
		}
		
	    $(input).css({
	        'position' : 'absolute',
	        // in Opera only 'browse' button
	        // is clickable and it is located at
	        // the right side of the input
	        'right' : 0,
	        'margin' : 0,
	        'padding' : 0,
	        'fontSize' : '480px',                
	        'cursor' : 'pointer'
	    });            
	
	    var div = document.createElement("div");                        
	    $(div).css({
	        'display' : 'block',
	        'position' : 'absolute',
	        'overflow' : 'hidden',
	        'margin' : 0,
	        'padding' : 0,                
	        'opacity' : 0,
	        // Make sure browse button is in the right side
	        // in Internet Explorer
	        'direction' : 'ltr',
	        //Max zIndex supported by Opera 9.0-9.2
	        'zIndex': 2000000000
	    });
		
		$(input).addClass('wiky_uploader_button');
	      
	    
	    $(input).bind('change', function(){
	        if (self._handler instanceof qq.UploadHandlerXhr){                
	            self._uploadFileList(input.files);                   
	        } else {             
	            if (self._validateFile(input)){                
	                self._uploadFile(input);                                    
	            }                      
	        }               
	        self.reset();   
	    });            
	
	    $(input).mouseover( function(){
	        $(self._button).addClass(self._options.mouseover_class);
	    });
		
		$(input).mousedown( function(){
	        $(self._button).addClass(self._options.mousedown_class);
	    });
		
		$(input).mouseup( function(){
	        $(self._button).removeClass(self._options.mousedown_class);
	    });

	    $(input).mouseout(function(){
	        $(self._button).removeClass(self._options.mouseover_class);
			$(self._button).removeClass(self._options.mousedown_class);
	        
	        // We use visibility instead of display to fix problem with Safari 4
	        // The problem is that the value of input doesn't change if it 
	        // has display none when user selects a file           
	        input.parentNode.style.visibility = 'hidden';
	
	    });   
	                
	    div.appendChild(input);
	    document.body.appendChild(div);
	      
	    return input;
	},
    setParams: function(params){
        $.extend(this._options.params,params);
    },
    getInProgress: function(){
        return this._filesInProgress;         
    },
    _onSubmit: function(id, fileName){
        this._filesInProgress++;  
    },
    _onProgress: function(id, fileName, loaded, total){        
    },
    _onComplete: function(id, fileName, result){
        this._filesInProgress--;                 
        if (result.error){
            this._options.showMessage(result.error);
        }             
    },
    _onCancel: function(id, fileName){
        this._filesInProgress--;        
    },
    _onInputChange: function(input){
        if (this._handler instanceof qq.UploadHandlerXhr){                
            this._uploadFileList(input.files);                   
        } else {             
            if (this._validateFile(input)){                
                this._uploadFile(input);                                    
            }                      
        }               
        this._button.reset();   
    },  
    _uploadFileList: function(files){
        for (var i=0; i<files.length; i++){
            if ( !this._validateFile(files[i])){
                return;
            }            
        }
        
        for (var i=0; i<files.length; i++){
            this._uploadFile(files[i]);        
        }        
    },       
    _uploadFile: function(fileContainer){      
        var id = this._handler.add(fileContainer);
        var fileName = this._handler.getName(id);
        
        if (this._options.onSubmit(id, fileName) !== false){
            this._onSubmit(id, fileName);
            this._handler.upload(id, this._options.params);
        }
    },      
    _validateFile: function(file){
        var name, size;
        
        if (file.value){
            // it is a file input            
            // get input value and remove path to normalize
            name = file.value.replace(/.*(\/|\\)/, "");
        } else {
            // fix missing properties in Safari
            name = file.fileName != null ? file.fileName : file.name;
            size = file.fileSize != null ? file.fileSize : file.size;
        }
                    
        if (! this._isAllowedExtension(name)){            
            this._error('typeError', name);
            return false;
            
        } else if (size === 0){            
            this._error('emptyError', name);
            return false;
                                                     
        } else if (size && this._options.sizeLimit && size > this._options.sizeLimit){            
            this._error('sizeError', name);
            return false;
                        
        } else if (size && size < this._options.minSizeLimit){
            this._error('minSizeError', name);
            return false;            
        }
        
        return true;                
    },
    _error: function(code, fileName){
        var message = this._options.messages[code];        
        function r(name, replacement){ message = message.replace(name, replacement); }
        
        r('{file}', this._formatFileName(fileName));        
        r('{extensions}', this._options.allowedExtensions.join(', '));
        r('{sizeLimit}', this._formatSize(this._options.sizeLimit));
        r('{minSizeLimit}', this._formatSize(this._options.minSizeLimit));
        
        this._options.showMessage(message);                
    },
    _formatFileName: function(name){
        if (name.length > 33){
            name = name.slice(0, 19) + '...' + name.slice(-13);    
        }
        return name;
    },
    _isAllowedExtension: function(fileName){
        var ext = (-1 !== fileName.indexOf('.')) ? fileName.replace(/.*[.]/, '').toLowerCase() : '';
        var allowed = this._options.allowedExtensions;
        
        if (!allowed.length){return true;}        
        
        for (var i=0; i<allowed.length; i++){
            if (allowed[i].toLowerCase() == ext){ return true;}    
        }
        
        return false;
    },    
    _formatSize: function(bytes){
        var i = -1;                                    
        do {
            bytes = bytes / 1024;
            i++;  
        } while (bytes > 99);
        
        return Math.max(bytes, 0.1).toFixed(1) + ['kB', 'MB', 'GB', 'TB', 'PB', 'EB'][i];          
    }
}


/**
 * Class for uploading files, uploading itself is handled by child classes
 */
qq = {}
qq.UploadHandlerAbstract = function(o){
    this._options = {
        debug: false,
        action: '/upload.php',
		name:'qqfile',
        // maximum number of concurrent uploads        
        maxConnections: 999,
        onProgress: function(id, fileName, loaded, total){},
        onComplete: function(id, fileName, response){},
        onCancel: function(id, fileName){}
    };
    $.extend(this._options, o);    
    
    this._queue = [];
    // params for files in queue
    this._params = [];
};
qq.UploadHandlerAbstract.prototype = {
    log: function(str){
        if (this._options.debug && window.console) console.log('[uploader] ' + str);        
    },
    /**
     * Adds file or file input to the queue
     * @returns id
     **/    
    add: function(file){},
    /**
     * Sends the file identified by id and additional query params to the server
     */
    upload: function(id, params){
        var len = this._queue.push(id);

        var copy = {};        
        $.extend(copy, params);
        this._params[id] = copy;        
                
        // if too many active uploads, wait...
        if (len <= this._options.maxConnections){               
            this._upload(id, this._params[id]);
        }
    },
    /**
     * Cancels file upload by id
     */
    cancel: function(id){
        this._cancel(id);
        this._dequeue(id);
    },
    /**
     * Cancells all uploads
     */
    cancelAll: function(){
        for (var i=0; i<this._queue.length; i++){
            this._cancel(this._queue[i]);
        }
        this._queue = [];
    },
    /**
     * Returns name of the file identified by id
     */
    getName: function(id){},
    /**
     * Returns size of the file identified by id
     */          
    getSize: function(id){},
    /**
     * Returns id of files being uploaded or
     * waiting for their turn
     */
    getQueue: function(){
        return this._queue;
    },
    /**
     * Actual upload method
     */
    _upload: function(id){},
    /**
     * Actual cancel method
     */
    _cancel: function(id){},     
    /**
     * Removes element from queue, starts upload of next
     */
    _dequeue: function(id){
        var i = wiky_uploader_helper.indexOf(this._queue, id);
        this._queue.splice(i, 1);
                
        var max = this._options.maxConnections;
        
        if (this._queue.length >= max && i < max){
            var nextId = this._queue[max-1];
            this._upload(nextId, this._params[nextId]);
        }
    }        
};

/**
 * Class for uploading files using form and iframe
 * @inherits qq.UploadHandlerAbstract
 */
qq.UploadHandlerForm = function(o){
    qq.UploadHandlerAbstract.apply(this, arguments);
       
    this._inputs = {};
};
// @inherits qq.UploadHandlerAbstract
$.extend(qq.UploadHandlerForm.prototype, qq.UploadHandlerAbstract.prototype);

$.extend(qq.UploadHandlerForm.prototype, {
    add: function(fileInput){
        fileInput.setAttribute('name', 'qqfile');
        var id = 'qq-upload-handler-iframe' + wiky_uploader_helper.getUniqueId();       
        
        this._inputs[id] = fileInput;
        
        // remove file input from DOM
        if (fileInput.parentNode){
            $(fileInput).remove();
        }
                
        return id;
    },
    getName: function(id){
        // get input value and remove path to normalize
        return this._inputs[id].value.replace(/.*(\/|\\)/, "");
    },    
    _cancel: function(id){

        this._options.onCancel(id, this.getName(id));
        
        delete this._inputs[id];        

        var iframe = document.getElementById(id);
        if (iframe){
            // to cancel request set src to something else
            // we use src="javascript:false;" because it doesn't
            // trigger ie6 prompt on https
            iframe.setAttribute('src', 'javascript:false;');

            $(iframe).remove();
        }
    },     
    _upload: function(id, params){                        
        var input = this._inputs[id];
        
        if (!input){
            throw new Error('file with passed id was not added, or already uploaded or cancelled');
        }                
		
		// test locally
		var self = this;
		if (location.href.match(/^file:\/\//) != null) {
			
			response = { filename: "test_upload_picture.jpg" }
			self._options.onComplete(id, fileName, response);
			self._dequeue(id);
            
            delete self._inputs[id];
			return;
		}

        var fileName = this.getName(id);
                
        var iframe = this._createIframe(id);
        var form = this._createForm(iframe, params);
        form.appendChild(input);

        
        this._attachLoadEvent(iframe, function(){                                 
            self.log('iframe loaded');
            
            var response = self._getIframeContentJSON(iframe);

            self._options.onComplete(id, fileName, response);
            self._dequeue(id);
            
            delete self._inputs[id];
            // timeout added to fix busy state in FF3.6
            setTimeout(function(){
                $(iframe).remove();
            }, 1);
        });

        form.submit();        
        $(form).remove();        
        
        return id;
    }, 
    _attachLoadEvent: function(iframe, callback){
        $(iframe).bind('load', function(){
            // when we remove iframe from dom
            // the request stops, but in IE load
            // event fires
            if (!iframe.parentNode){
                return;
            }
			
			var doc = false;
			if (iframe.contentDocument) { // DOM
			  doc = iframe.contentDocument;
			} 
			else if (iframe.contentWindow) { // IE win
			  doc = iframe.contentWindow.document;
			}

            // fixing Opera 10.53
            if (doc &&
                doc.body &&
                doc.body.innerHTML == "false"){
                // In Opera event is fired second time
                // when body.innerHTML changed from false
                // to server response approx. after 1 sec
                // when we upload file with iframe
                return;
            }

            callback();
        });
    },
    /**
     * Returns json object received by iframe from server.
     */
    _getIframeContentJSON: function(iframe){
        // iframe.contentWindow.document - for IE<7
        var doc = iframe.contentDocument ? iframe.contentDocument: iframe.contentWindow.document,
            response;
        
        this.log("converting iframe's innerHTML to JSON");
        this.log("innerHTML = " + doc.body.innerHTML);
                        
        try {
            response = eval("(" + doc.body.innerHTML + ")");
        } catch(err){
            response = {};
        }        

        return response;
    },

    /**
     * Creates iframe with unique name
     */
    _createIframe: function(id){
		// We can't use following code as the name attribute
	    // won't be properly registered in IE6, and new window
	    // on form submit will open
	    // var iframe = document.createElement('iframe');
	    // iframe.setAttribute('name', id);
	
	    var iframe = wiky_uploader_helper.toElement('<iframe src="javascript:false;" name="' + id + '" />');
	    // src="javascript:false;" removes ie6 prompt on https
	
	    iframe.setAttribute('id', id);
	
	    iframe.style.display = 'none';
	    document.body.appendChild(iframe);
	
	    return iframe;
    },
    /**
     * Creates form, that will be submitted to iframe
     */
    _createForm: function(iframe, params){
		// We can't use the following code in IE6
	    // var form = document.createElement('form');
	    // form.setAttribute('method', 'post');
	    // form.setAttribute('enctype', 'multipart/form-data');
	    // Because in this case file won't be attached to request
	    var form = wiky_uploader_helper.toElement('<form method="post" enctype="multipart/form-data"></form>');
	

        var queryString = wiky_uploader_helper.obj2url(params, this._options.action);

        form.setAttribute('action', queryString);
        form.setAttribute('target', iframe.name);
        form.style.display = 'none';
        document.body.appendChild(form);

        return form;
    }
});

/**
 * Class for uploading files using xhr
 * @inherits qq.UploadHandlerAbstract
 */
qq.UploadHandlerXhr = function(o){
    qq.UploadHandlerAbstract.apply(this, arguments);

    this._files = [];
    this._xhrs = [];
    
    // current loaded size in bytes for each file 
    this._loaded = [];
};

// static method
qq.UploadHandlerXhr.isSupported = function(){
    var input = document.createElement('input');
    input.type = 'file';        
    
    return (
        'multiple' in input &&
        typeof File != "undefined" &&
        typeof (new XMLHttpRequest()).upload != "undefined" );       
};

// @inherits qq.UploadHandlerAbstract
$.extend(qq.UploadHandlerXhr.prototype, qq.UploadHandlerAbstract.prototype)

$.extend(qq.UploadHandlerXhr.prototype, {
    /**
     * Adds file to the queue
     * Returns id to use with upload, cancel
     **/    
    add: function(file){
        if (!(file instanceof File)){
            throw new Error('Passed obj in not a File (in qq.UploadHandlerXhr)');
        }
                
        return this._files.push(file) - 1;        
    },
    getName: function(id){        
        var file = this._files[id];
        // fix missing name in Safari 4
        return file.fileName != null ? file.fileName : file.name;       
    },
    getSize: function(id){
        var file = this._files[id];
        return file.fileSize != null ? file.fileSize : file.size;
    },    
    /**
     * Returns uploaded bytes for file identified by id 
     */    
    getLoaded: function(id){
        return this._loaded[id] || 0; 
    },
    /**
     * Sends the file identified by id and additional query params to the server
     * @param {Object} params name-value string pairs
     */    
    _upload: function(id, params){
        var file = this._files[id],
            name = this.getName(id),
            size = this.getSize(id);
                
        this._loaded[id] = 0;
                                
        var xhr = this._xhrs[id] = new XMLHttpRequest();
        var self = this;
                                        
        xhr.upload.onprogress = function(e){
            if (e.lengthComputable){
                self._loaded[id] = e.loaded;
                self._options.onProgress(id, name, e.loaded, e.total);
            }
        };

        xhr.onreadystatechange = function(){            
            if (xhr.readyState == 4){
                self._onComplete(id, xhr);                    
            }
        };
		
		// test locally
		if (location.href.match(/^file:\/\//) != null) {
			
			xhr = {
					status: 200,
					responseText: '{filename:"test_upload_picture.jpg"}'
					}
			self._onComplete(id, xhr); 
			return;
		}
		
        // build query string
        params = params || {};
        params[this._options.name] = name;
		
		if (AUTH_TOKEN != undefined) params["authenticity_token"] = encodeURIComponent(AUTH_TOKEN);
		
        var queryString = wiky_uploader_helper.obj2url(params, this._options.action);

        xhr.open("POST", queryString, true);
		xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
        xhr.setRequestHeader("X-File-Name", encodeURIComponent(name));
        xhr.setRequestHeader("Content-Type", "application/octet-stream");
		
        xhr.send(file);
		
    },
    _onComplete: function(id, xhr){
        // the request was aborted/cancelled
        if (!this._files[id]) return;
        
        var name = this.getName(id);
        var size = this.getSize(id);
        
        this._options.onProgress(id, name, size, size);
                
        if (xhr.status == 200){
            this.log("xhr - server response received");
            this.log("responseText = " + xhr.responseText);
                        
            var response;
                    
            try {
                response = eval("(" + xhr.responseText + ")");
            } catch(err){
                response = {};
            }
            
            this._options.onComplete(id, name, response);
                        
        } else {                   
            this._options.onComplete(id, name, {});
        }
                
        this._files[id] = null;
        this._xhrs[id] = null;    
        this._dequeue(id);                    
    },
    _cancel: function(id){
        this._options.onCancel(id, this.getName(id));
        
        this._files[id] = null;
        
        if (this._xhrs[id]){
            this._xhrs[id].abort();
            this._xhrs[id] = null;                                   
        }
    }
});