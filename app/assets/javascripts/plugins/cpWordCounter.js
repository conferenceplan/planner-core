/*
 * 
 */
(function($) {
    
    $.widget( "cp.wordCounter" , {
        
        options : {
            feedback_target: null,
        },
        
        _create : function() {
            
            // this.element
            this.max_length = this.element.attr('maxlength');
            
        },
        
        max_length : function() {
            var len = this.element.attr('maxlength');
            
            if (len === undefined) {
                len = -1;
            };
            
            return len;
        },

        bind: function ($obj) {
          $obj.bind(
             "keypress.counter keydown.counter keyup.counter blur.counter focus.counter change.counter paste.counter",
            this.updateCounter);
          // $obj.bind("keydown.counter", this.doStopTyping);
          $obj.trigger('keydown');
        },
        
        updateCounter : function(e) {
            
        },

        doStopTyping : function(e) {
          // backspace, delete, tab, left, up, right, down, end, home, spacebar
          // var keys = [46, 8, 9, 35, 36, 37, 38, 39, 40, 32];
          // if (methods.isGoalReached(e)) {
            // // NOTE: // Using ( !$.inArray(e.keyCode, keys) ) as a condition causes delays
            // if (e.keyCode !== keys[0] && e.keyCode !== keys[1] && e.keyCode !== keys[2] &&
              // e.keyCode !== keys[3] && e.keyCode !== keys[4] && e.keyCode !== keys[5] &&
              // e.keyCode !== keys[6] && e.keyCode !== keys[7] && e.keyCode !== keys[8]) {
              // // Stop typing when counting characters
              // if (options.type === defaults.type) {
                // return false;
                // // Counting words, only allow backspace & delete
              // } else if (e.keyCode !== keys[9] && e.keyCode !== keys[1] && options.type != defaults.type) {
                // return true;
              // } else {
                // return false;
              // }
            // }
          // }            
        }
        
    });

})(jQuery);
