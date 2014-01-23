/*
 *
 */
DailyGrid = (function() {


function timeFormat(formats) {
  return function(date) {
    // var i = formats.length - 1, f = formats[i];
    // while (!f[1](date)) f = formats[--i];
    var i = 0, f = formats[i];
    while (!f[1](date)) f = formats[i++]; // TODO - if zone is changed we need to change this as well
    
    return d3.functor(f[0])(moment(date)); // TODO - put the correct zone offset in here [.zone("-05:00")]
    // NOTE - we need to also change the date returned as the position
  };
}

//var customTimeFormat = d3.time.format.multi([
var customTimeFormat = timeFormat([
  [function(d) { return moment(d).format('HH:mm');}, function(d) { return d.getHours(); }],
  [function(d) { return moment(d).format('ddd');}, function(d) { return d.getDay() && d.getDate() != 1; }],
  [function(d) { return moment(d).format('HH:mm');}, function() { return true; }] // TODO - we should take into account the timezone (also for the drag and drop calculation )
]);

    // The area on the screen for the grid with margins
    var margin = {
        top : 20,
        right : 15,
        bottom : 15,
        left : 40
    }, width = 800 - margin.left - margin.right, height = 680 - margin.top - margin.bottom;

    // Globals for the data and the SVG element
    var selector = null, data = null, svg = null, gridbody = null, date = null, labels = null, base = 0, textBoxWidth = 1, ctlWidth = 0.2;

    // Create a liner scale for the rooms and a time scale for the day
    var xScale = d3.scale.linear().rangeRound([0, width * 7], 0);
    //
    var yScale = d3.time.scale.utc().rangeRound([0, height * 2]);

    // X and Y axis - using the previous scales
    var x_Axis = d3.svg.axis().scale(xScale).orient("top").tickFormat(d3.format("d")).tickSize(-height, 0).tickPadding(6);

    var y_Axis = d3.svg.axis().scale(yScale).orient("left").tickFormat(customTimeFormat).tickSize(-(width + margin.left), 0).tickPadding(6);

    // What we do for zooming and constraining the zoom level
    var zoom = d3.behavior.zoom().scaleExtent([1, 8]).on("zoom", draw);

    //////
    var drag = d3.behavior.drag().origin(Object).on("drag", dragmove).on("dragstart", function() {
        d3.event.sourceEvent.stopPropagation();
        // silence other listeners
    });

    function moveCoordinates(x, y, dx, dy) {
        var xposn = parseInt(x);
        var yposn = parseFloat(y);

        return [xposn + dx / zoom.scale(), yposn + dy / zoom.scale()];
    }

    function moveObject(obj, dx, dy) {
        var newPosn = moveCoordinates(obj.attr("x"), obj.attr("y"), dx, dy);
        obj.attr("x", newPosn[0]);
        obj.attr("y", newPosn[1]);
    }

    /*
     * Need to move the rect and "foreign"/text objects
     */
    function dragmove(d) {
        moveObject(d3.select(this).select('.prog-item-text'), d3.event.dx, d3.event.dy);
        moveObject(d3.select(this).select('.prog-item-rect'), d3.event.dx, d3.event.dy);
    };

    function roundToQuaterHour(aTime) {
        var newTime = new Date(aTime);
        var mins = aTime.getMinutes();
        // will be from 0 to 59
        var quarterHours = Math.round(mins / 15);
        if (quarterHours == 4) {// round up
            newTime.setHours(aTime.getHours() + 1);
            newTime.setMinutes(0);
        } else {
            newTime.setMinutes(quarterHours * 15);
        }
        newTime.setSeconds(0);
        return newTime;
    }

    function snapObject(obj) {
        var xx = (parseInt(obj.attr("x")) ) * zoom.scale() + zoom.translate()[0];
        var newx = Math.round(xScale.invert(xx));
        // round down to the nearest "room"
        newx = newx > 0 ? newx : 0;
        // we do not want to go below 0

        // TODO - make sure we can not go beyond the end of the rooms
        // TODO - make sure we stay within the time for the day

        var yy = (parseInt(obj.attr("y"))  ) * zoom.scale() + zoom.translate()[1];
        var newy = roundToQuaterHour(yScale.invert(yy));
        obj.attr("x", (xScale(newx) - zoom.translate()[0]) / zoom.scale());
        obj.attr("y", (yScale(newy) - zoom.translate()[1]) / zoom.scale());

        return [newx, newy];
    }

    function dropEvent(d) {
        snapObject(d3.select(this).select('.prog-item-text'));
        var rcoords = snapObject(d3.select(this).select('.prog-item-rect'));

        var xRoom = data.get('rooms')[rcoords[0]];

        // Call back so that the save is done on the sever
        ScheduleApp.ItemManagement.moveAssignment(d.item_id, xRoom.id, d.day, rcoords[1]);
    };

    var currentPosn = null;

    function currentPosnAsRoomAndTime() {
        if (currentPosn) {
            var xx = currentPosn[0];
            // - + zoom.translate()[0]) / zoom.scale()  ;

            var newx = Math.round(xScale.invert(xx));
            // map x to the
            var xRoom = data.get('rooms')[newx];

            // Get the time (nearest 15 minutes)
            var yy = currentPosn[1];
            // * zoom.scale() + zoom.translate()[1];
            var yTime = roundToQuaterHour(yScale.invert(yy));

            return [xRoom, yTime];
        } else {
            return null;
        }
    };

    function overEvent(d) {
        var coord = d3.mouse(selector);
        // Get the coordinates relative to the canvas (SVG)
        currentPosn = [coord[0] - margin.left, coord[1] - margin.top];
        // and return them

        var cp = currentPosnAsRoomAndTime();
        if (cp) {
            ScheduleApp.ItemManagement.addAssignment();
        }
    };

    /*
     * 
     */
    function scrollTo(room, time) {
        var idx = 0;
        for (idx = 0; idx < labels.length; idx++) {
            if (labels[idx] == room) {
                break;
            }
        };
        
        _scrollTo(idx, time);
// 
        // newx = -(xScale(idx) - zoom.translate()[0]);
        // newy = -(yScale(Date.parse(time)) - zoom.translate()[1]);
// 
        // zoom.translate([newx, newy]);
        // draw();
        // svg.selectAll(".prog-item").attr('transform', 'translate(' + zoom.translate() + ') scale(' + zoom.scale() + ')');
    };
    
    function _scrollTo(roomIdx, time) {
        newx = -(xScale(roomIdx) - zoom.translate()[0]);
        newy = -(yScale(Date.parse(time)) - zoom.translate()[1]);

        zoom.translate([newx, newy]);
        draw();
        svg.selectAll(".prog-item").attr('transform', 'translate(' + zoom.translate() + ') scale(' + zoom.scale() + ')');
    }

    // Public method used by the view to paint the schedule data data
    // window.DailyGrid.
    function paint(_selector, _data, _width) {
        // use the width dimension from the containing element
        width = _width - margin.left - margin.right;
        //y_Axis = d3.svg.axis().scale(yScale).orient("left").tickSize(-(width + margin.left), 0).tickPadding(6);
        y_Axis = d3.svg.axis().scale(yScale).orient("left").tickFormat(customTimeFormat).tickSize(-(width + margin.left), 0).tickPadding(6);

        selector = _selector;
        data = _data;
        date = Date.parse(data.get('date'));
        console.debug('PAINT');
        console.debug(date);
        //new Date(2013, 5, 15); // 0 = Jan etc

        // We need to create an SVG area for the display
        svg = d3.select(selector).append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")").on("mouseover", overEvent);

        var clip = svg.append("defs").append("svg:clipPath").attr("id", "clip").append("svg:rect").attr("id", "clip-rect").attr("x", "0").attr("y", "0").attr("width", width).attr("height", height);

        // Then we add axis (x and y) so that the user knows what is being displayed
        svg.append("g").attr("class", "x axis").attr("transform", "translate(0,0)");

        svg.append("g").attr("class", "y axis").attr("transform", "translate(0,0)");

        // And a zoomable rectangle to handle the zoom and pan events
        gridBody = svg.append("g").attr("clip-path", "url(#clip)");

        var itemDisplay = gridBody.append("rect").attr("class", "pane").attr("id", "pane").attr("width", width).attr("height", height).call(zoom); //
        // make the item display "zoomable"
        
        var allItems = gridBody.append("g").attr("class", "all-items");

        // Set the ranges for the scales
        yScale.domain([date, d3.time.hour.offset(new Date(date), +24)]);
        //.clamp(true); // The date range as input

        labels = data.get('rooms').map(function(d) {
            return d.name;
        });
        xScale.domain([0, labels.length]);
        //.clamp(true);
        var count_array = [];
        for (var i = 0; i < labels.length; i++)
            count_array[i] = i;
        x_Axis.tickValues(count_array);
        //.ticks(labels.length);

        // and the scaling for the zoom and pan
        zoom.y(yScale);
        zoom.x(xScale);

        // For each of the items in each of the rooms display the information
        var rooms = data.get('rooms');
        for (var i = 0; i < rooms.length; i++) {
            if (rooms[i].items.length > 0) {
                createItemGroup(rooms[i].items, i);
            };
        };

        // Then draw the display
        draw();
        
        _scrollTo(0, d3.time.hour.offset(new Date(date), +8)); // Position at 8am of the day in question
    };

    /*
     *
     */
    function createItem(_data, idx) {
        createItemGroup([_data], idx);
    };

    /*
     *
     */
    function createItemGroup(items, idx) {
        //         var allItems = gridBody.append("g").attr("class", "all-items");
        // var group = gridBody.selectAll(".all-items")
        var group = gridBody.selectAll("rect")
            .data(items, function(d) {
                if ( typeof d != 'undefined') {
                    return d.assignment_id;
                }
             })
            .enter()
            .append("g")// Group each of the graphical elements together
                .attr("class", 'prog-item')
                .attr("transform", "translate(" + zoom.translate()[0] + "," + zoom.translate()[1] + ") scale(" + zoom.scale() + ")")
                .attr("id", function(d) {
                    return d.item_id;
                })
                .call(drag).on("mouseup", dropEvent); // When drag-n-drop stops catch the event so we can snap to grid

        createItemBox(group, idx);

        return group;
    }

    /*
     *
     */
    function createItemBox(group, idx) {// There is an implicit argument (d) for the elements which is passed in from the parent group !!!
        // parent group (g) with class 'prog-item' etc
        var lwidth = (xScale(textBoxWidth) - zoom.translate()[0]) / zoom.scale(), swidth = (xScale(ctlWidth) - zoom.translate()[0]) / zoom.scale(), x = (xScale(idx) - zoom.translate()[0]) / zoom.scale(), ix = (xScale(idx + textBoxWidth) - zoom.translate()[0]) / zoom.scale();

        // The outlining "rect" which is displayed on the grid
        group.append("rect").attr("x", x)// the room
        .attr("y", function(d) {
            return (yScale(Date.parse(d.time)) - zoom.translate()[1]) / zoom.scale();
        })// the time
        .attr("class", 'prog-item-rect').attr("width", lwidth)// the width of scale (a room)
        .attr("height", function(d) {
            return ((yScale(d3.time.minute.offset(date, +d.duration)) - yScale(date))) / zoom.scale();
        });
        // height determined by the duration of the item

        // A "foreign object" because we are displaying "html" withint the SVG element
        var div = group.append('foreignObject').attr("x", x)// the room
        .attr("y", function(d) {
            return (yScale(Date.parse(d.time)) - zoom.translate()[1]) / zoom.scale();
        })// the time
        .attr("width", lwidth)// the width of scale (a room)
        .attr("height", function(d) {
            return ((yScale(d3.time.minute.offset(date, +d.duration)) - yScale(date))) / zoom.scale();
        })// height determined by the duration of the item
        .attr("class", 'prog-item-text').append('xhtml:div')// DIV containing the title so we can wrap text etc.
        .attr("class", 'prog-item-text-class');

        div.append('xhtml:a').attr("class", 'btn btn-xs item-ctl-back').attr('href', '#').on("mousedown", function() {
            d3.event.stopPropagation();
        }).on("mouseup", function(d) {
            d3.event.stopPropagation();
            var parent_group = this.parentNode.parentNode.parentNode;
            var sib = $('#pane')[0].nextSibling;
            parent_group.parentNode.insertBefore(parent_group, sib);
        }).append('xhtml:i').attr("class", 'glyphicon glyphicon-arrow-down item-ctl-icon');
        
        div.append('xhtml:a').attr("class", 'btn btn-xs item-ctl-remove').attr('href', '#').on("mouseup", function(d) {
            var parent_group = d3.select(this.parentNode.parentNode.parentNode);
            if (ScheduleApp.ItemManagement.removeAssignment(d.item_id)) {
                parent_group.remove();
            };

            d3.event.stopPropagation();
        }).append('xhtml:i').attr("class", 'glyphicon glyphicon-remove item-ctl-icon');
        
        div.append('xhtml:hr').attr("class", 'toolbar-line');

        div.append('xhtml:div').attr("class", 'item-text').html(function(d) {
            return d.title + ' ' + d.time;
        });

    };

    /*
     *
     */
    function draw() {
        // Show the x and y axis of the grid
        svg.select("g.y.axis").call(y_Axis);
        svg.select("g.x.axis").call(x_Axis);

        // Find the mid-point so that we can center the text
        if (base == 0) {
            base = xScale(1) / 2;
        };
        var midPoint = base * zoom.scale();
        xTicks = svg.selectAll('.x .tick > text').html("");
        // remove the labels generated by d3
        xTicks = svg.selectAll('.x .tick')// Add in the ticks so we can have our own labels
        .append('g').attr('transform', function(d) {
            return "translate(" + midPoint + ", -10)";
        })//
        .attr('class', 'tick');
        // add new labels
        xTicks.append('svg:text').text(function(d) {
            return (d % 1 === 0) ? labels[d] : "";
        })// use the names of the rooms that we stored in the labels array
        .attr('text-anchor', 'middle').attr('dy', 2).attr('dx', 0);

        // If this is a d3 zoom event then we want to scale the program item elements
        if (d3.event) {
            svg.selectAll(".prog-item").attr('transform', 'translate(' + d3.event.translate + ') scale(' + d3.event.scale + ')');
        }
    };

    /*
     *
     */
    return {
        
        scrollTo : function(room, time) {
            scrollTo(room, time);
        },
        
        paint : function(_selector, _data, _width) {
            return paint(_selector, _data, _width);
        },

        createItem : function(_data, idx) {// for a specific item
            createItem(_data, idx);
        },

        getCurrentPosn : function() {
            return currentPosn;
        },

        getCurrentRoomAndTime : function() {
            return currentPosnAsRoomAndTime();
        },
        
        clean : function() {
            // clean up memory????
            if (svg) {
                d3.select(selector).remove();
                svg = null;
            }
        }
    };

})();

