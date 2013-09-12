
// Use for the name space
window.Schedule = {};

// The area on the screen for the grid with margins
var margin = {top: 20, right: 15, bottom: 15, left: 40},
    width  = 600 - margin.left - margin.right,
    height = 680 - margin.top - margin.bottom;

// Create a liner scale for the rooms and a time scale for the day
// var xScale = d3.scale.ordinal().rangeBands([0, width*10], 0); // *10 so that we display 1/10 of the rooms in the screen and use pan to see the rest - TODO
var xScale = d3.scale.linear().rangeRound([0, width*10], 0); // *10 so that we display 1/10 of the rooms in the screen and use pan to see the rest
var yScale = d3.time.scale().rangeRound([0, height*2]);

// X and Y axis - using the previous scales
var x_Axis = d3.svg.axis()
    .scale(xScale)
    .orient("top")
    .tickFormat(d3.format("d"))
    .tickSize(-height, 0)
    .tickPadding(6);
    
var y_Axis = d3.svg.axis()
    .scale(yScale)
    .orient("left")
    .tickSize(-(width+margin.left), 0)
    .tickPadding(6);
    
// What we do for zooming and constraining the zoom level
var zoom = d3.behavior.zoom()
    .scaleExtent([1, 8])
    .on("zoom", draw);

// Globals for the data and the SVG element
var selector = null,
    data = null,
    svg = null,
    date = null,
    labels = null;
   

function dataid(d) { 
    if (typeof d != 'undefined') {
        return d.assignment_id;
    }
};

// Public method used by the view to paint the schedule data data
window.Schedule.paint = function (_selector, _data) {
    selector = _selector;
    data = _data;
    date = Date.parse(data.at(0).get('date')); //new Date(2013, 5, 15); // 0 = Jan etc
    
    // We need to create an SVG area for the display
    svg = d3.select(selector).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    // And clip that area
    svg.append("clipPath")
            .attr("id", "clip")
        .append("rect")
            .attr("x", xScale(0))
            .attr("y", yScale(1))
            .attr("width", xScale(1) - xScale(0))
            .attr("height", yScale(0) - yScale(1));

    // Then we add axis (x and y) so that the user knows what is being displayed
    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0,0)");
        
    svg.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(0,0)");
        
    // And a zoomable rectangle to handle the zoom and pan events
    svg.append("rect")
        .attr("class", "pane")
        .attr("width", width)
        .attr("height", height)
        .call(zoom);
  
    // Set the ranges for the scales
    // TODO - use Clamp to set the bounds for the scale
    yScale.domain([date, d3.time.hour.offset(new Date(date), +24)]); //.clamp(true); // The date range as input

    // alert(data.at(0).get('rooms').map(function(d) { return d.name; }));
    labels = data.at(0).get('rooms').map(function(d) { return d.name; });
    // alert(d3.extent(labels));
    xScale.domain([0, labels.length]); //.clamp(true);
    // x_Axis.tickValues(data.at(0).get('rooms').map(function(d) { return d.name; }));
    var count_array = [];
    for(var i=0; i<labels.length;i++) count_array[i] = i;
    x_Axis.tickValues(count_array);//.ticks(labels.length);
    
    // and the scaling for the zoom and pan
    zoom.y(yScale);
    zoom.x(xScale);

    var rooms = data.at(0).get('rooms');
    for (var i = 0; i < rooms.length; i++) {
        if (rooms[i].items.length > 0) {
            var group = svg.selectAll("rect")
                .data(rooms[i].items, dataid )
                .enter()
                .append("g")
                .attr("class", 'prog-item');

            group.append("rect")
                .attr("x", function(d) { return xScale(i); } ) // the room
                .attr("y", function(d) { return yScale(Date.parse(d.time)); }) // the time
                .attr("class", 'prog-item-rect')
                .attr("width", xScale(1)) // the width of scale (a room)
                .attr("height", function(d) { return yScale(d3.time.minute.offset(date, +d.duration)) - yScale(date); }) // height determined by the duration of the item
                .append('g');

            group.append('foreignObject')
                // .attr("x", function(d) { return xScale(i) + 5; } ) // the room
                // .attr("y", function(d) { return yScale(Date.parse(d.time)) + 10; }) // 
                .attr("x", function(d) { return xScale(i); } ) // the room
                .attr("y", function(d) { return yScale(Date.parse(d.time)); }) // the time
                .attr("width", xScale(1)) // the width of scale (a room)
                .attr("height", function(d) { return yScale(d3.time.minute.offset(date, +d.duration)) - yScale(date); }) // height determined by the duration of the item
                .attr("class", 'prog-item-text')
                .append('xhtml:div')
                    .attr("class", 'prog-item-text-class')
                    .text(function(d) { return d.title; })
                ;
            
            // TODO - add attributes to get the underlying prog item etc when there is a select
            // TODO - need special display for over-lapping items
        };
    };

    // Then draw the display
    draw();
};

// d3.behavior.zoom.rescale = function() {
    // // if (x1) x1.domain(x0.range().map(function(x) {
        // // return (x - view.x) / view.k;
    // // }).map(x0.invert));
    // if (y1) y1.domain(y0.range().map(function(y) {
        // return (y - view.y) / view.k;
    // }).map(y0.invert));
// };

var base = 0;

// TODO - put in boundaru conditions...
function draw() {
    svg.select("g.y.axis").call(y_Axis);
    svg.select("g.x.axis").call(x_Axis);
  
    if (base == 0) {
        base = xScale(1)/2;
    };
    var midPoint = base * zoom.scale();
    // console.log(midPoint);
    xTicks = svg.selectAll('.x .tick > text').html(""); // remove the labels generated by d3
    // TODO - how to remove the fractional ticks???
    xTicks = svg.selectAll('.x .tick')
        .append('g')
        .attr('transform', function(d) { return "translate(" + midPoint + ", -10)"; } ) //
        .attr('class', 'tick');
    xTicks.append('svg:text')
        .text( function(d) { return (d % 1 === 0) ?  labels[d] : ""; } ) // use the names of the rooms that we stored in the labels array
        .attr('text-anchor', 'middle')
        .attr('dy', 2)
        .attr('dx', 0);

    // // Make sure all the prog-items are moved etc when the grid pans
    if (d3.event) {
        svg.selectAll(".prog-item")
            .attr('transform', 'translate(' + d3.event.translate + ') scale(' + d3.event.scale + ')');
        // svg.selectAll(".prog-item-text")
            // .attr('transform', 'translate(' + d3.event.translate + ') scale(' + d3.event.scale + ')');
    }
 
  // svg.select("path.line").attr("d", line);
  // svg.select("path.area").attr("d", area);
  // svg.select("path.line").attr("d", line);
};
