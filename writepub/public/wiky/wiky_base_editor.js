(function($){

 	$.fn.extend({ 
 		
		//pass the options variable to the function
 		wiky_base_editor: function(handles) {
			return this.each(function() {
				
				this.wiky_editor = {};
				this.wiky_editor.editor = this;
				this.wiky_editor.action_count = 0;
				this.wiky_editor.action_save_count = 40;
				this.wiky_editor.data = [this.value];
				this.wiky_editor.data_max = 100;
				this.wiky_editor.current_pointer = 0;
				this.wiky_editor.just_undo_redo = false;
				this.wiky_editor.just_did_special_action = false;
				this.wiky_editor.handles = {};
				
				if (handles != undefined) {
					this.wiky_editor.handles = handles;
				}
				
				this.wiky_editor.undo = function(event) {
					if (this.current_pointer < (this.data.length - 1)) {
						
						// Pressing undo for the first time, we have to save the current content.
						if (this.current_pointer == 0) {
							this.save_history(event,true);
//							console.log(this.data);
						}
						
						this.current_pointer++;
						this.editor.value = this.data[this.current_pointer];
					}
					
//					console.log(this.data);
//					console.log('undo ' + this.current_pointer);
				}
				
				this.wiky_editor.redo = function() {
					if (this.current_pointer > 0) {
						this.current_pointer--;
						this.editor.value = this.data[this.current_pointer];
					}
					
//					console.log(this.data);
//					console.log('redo ' + this.current_pointer);
				}
				
				this.wiky_editor.save_history = function(event,force) {
				
					if (this.just_undo_redo == true) {
						this.just_undo_redo = false;
						return;
					}

					this.action_count++;
						
					// This occurs when users press some undoes and type something new, so we delete the lines of redoes.
					if (this.data.length > 0 && this.editor.value != this.data[0]) {
						if (this.current_pointer > 0) {
							this.data.splice(0,this.current_pointer);
							this.current_pointer = 0;
						}
					}
					
					
					// It makes sense to save:
					// (1) when typing some x characters
					// (2) press enter (it is a thought unit)
					// (3) Ctrl + V (patse a content)
					// (4) Delete a chunk of content.
					if (force == true
						|| this.action_count >= this.action_save_count
						|| event.which == 13 // enter
						|| (event.which == 8 && Math.abs(this.editor.value.length - this.data[0].length) > 1) //
						|| this.just_did_special_action == true
						) {
						
						if (this.data.length == 0 || this.editor.value != this.data[0]) {
							
							this.data.unshift(this.editor.value);
							if (this.data.length > this.data_max) {
								this.data.pop();
							}
							
							//console.log(this.data);
						}
						
						this.action_count = 0;
						
					}
					
					this.just_did_special_action = false;
					this.just_undo_redo = false;
				}
			
			    $(this).keydown(function(e)
			    {
					var zKey = 90, yKey = 89, vKey = 86;
					
					this.wiky_editor.just_undo_redo = false;
					this.wiky_editor.just_did_special_action = false;
					
					// We shall save content to data[] before perform an action (e.g. make bold or pasting)
					if (e.ctrlKey == true) {
						
						doSomething = true;
						if (e.which == zKey) {
							
							
							this.wiky_editor.undo(e);
							this.wiky_editor.just_undo_redo = true;
							
						} else if (e.which == yKey) {
							
							
							this.wiky_editor.redo(e);
							this.wiky_editor.just_undo_redo = true;
							
						} else {
							doSomething = false;
							
							if (this.wiky_editor.handles[String.fromCharCode(e.which).toLowerCase()] != undefined) {
								
								this.wiky_editor.save_history(e,true);
								this.wiky_editor.handles[String.fromCharCode(e.which).toLowerCase()](this);
								doSomething = true;
								this.wiky_editor.just_did_special_action = true;
								
							}
							
							if (e.which == vKey) {
								this.wiky_editor.save_history(e);
								this.wiky_editor.just_did_special_action = true;
							}
						}
						
						if (doSomething == true) {
							e.preventDefault();
						}
					}
			    }).keypress(function(e){
					this.wiky_editor.save_history(e);
				});
			});
		}
		
	});
	
})(jQuery);