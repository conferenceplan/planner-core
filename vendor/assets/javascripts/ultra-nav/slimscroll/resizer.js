
// Delay time for window resizing
var resize_delay = 250;

/*------------------------------------------------------------------------
    RESIZER (DEBOUNCE AND THROTTLE)
    Usage : For debounced ->     $(window).debounce_resize(function(){
                                     .....my code.....
                                 });
            For non-debounced -> $(window).resize(function(){
                                     .....my code.....
                                 });
--------------------------------------------------------------------------*/

(function($,sr){
    var debounce = function (func, threshold, execAsap) {
        var timeout;
        return function debounced () {
            var obj = this, args = arguments;
            function delayed () {
                if (!execAsap)
                    func.apply(obj, args);
                timeout = null;
            };
            if (timeout)
                clearTimeout(timeout);
            else if (execAsap)
                func.apply(obj, args);

            timeout = setTimeout(delayed, threshold || resize_delay);
        };
    }
    jQuery.fn[sr] = function(fn){  return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr); };
})(jQuery,'debounce_resize');
(function($,window,undefined){

    // A jQuery object containing all non-window elements to which the resize
    // event is bound.
    var elems = $([]),

    // Extend $.resize if it already exists, otherwise create it.
    jq_resize = $.resize = $.extend($.resize, {}),
            
    timeout_id,
        
    // Reused strings
    str_setTimeout = 'setTimeout',
    str_resize = 'resize',
    str_data = str_resize + '-special-event',
    str_delay = 'delay',
    str_throttle = 'throttleWindow';
          
    // Property: jQuery.resize.delay
    // 
    // The numeric interval (in milliseconds) at which the resize event polling
    // loop executes. Defaults to 250.
    jq_resize[str_delay] = 275;
        
          
    jq_resize[str_throttle] = true;
              
    $.event.special[str_resize] = {
            
        setup: function() {
            if (!jq_resize[str_throttle] && this[str_setTimeout]) {return false;}
              
            var elem = $(this);
            elems = elems.add( elem );
            $.data(this, str_data, {w: elem.width(), h: elem.height()});
            if ( elems.length === 1 ) {
                loopy();
            }
        },
        teardown: function() {
            if (!jq_resize[str_throttle] && this[str_setTimeout ]) {return false;}
              
            var elem = $(this);
            elems = elems.not(elem);
            elem.removeData(str_data);
            if (!elems.length) {
                clearTimeout(timeout_id);
            }
        },
        
        add: function(handleObj) {
            if (!jq_resize[str_throttle] && this[str_setTimeout]) {return false;}
            var old_handler;
            function new_handler(e, w, h) {
                var elem = $(this),
                data = $.data(this, str_data);
                data.w = w !== undefined ? w : elem.width();
                data.h = h !== undefined ? h : elem.height();
                
                old_handler.apply(this, arguments);
            };
            if ($.isFunction(handleObj)) {
                old_handler = handleObj;
                return new_handler;
            } else {
                old_handler = handleObj.handler;
                handleObj.handler = new_handler;
            }
        }
            
    };
       
    function loopy() {
        timeout_id = window[str_setTimeout](function(){
            elems.each(function(){
                var elem = $(this),
                width = elem.width(),
                height = elem.height(),
                data = $.data(this, str_data);
                if (width !== data.w || height !== data.h) {
                    elem.trigger(str_resize, [data.w = width, data.h = height]);
                }
                
            });
            loopy();
              
        }, jq_resize[str_delay]);
            
    };
          
})(jQuery,this);