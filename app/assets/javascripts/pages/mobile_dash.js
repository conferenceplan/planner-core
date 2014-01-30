/*
 * 
 */
Phone = (function() {

    /*
     * 
     */
    function importNode(node, allChildren) {
        switch (node.nodeType) {
        case document.ELEMENT_NODE:
            var newNode = document.createElementNS(node.namespaceURI, node.nodeName);
            if(node.attributes && node.attributes.length > 0){
                for(var i = 0, il = node.attributes.length; i < il; i++){
                    newNode.setAttribute(node.attributes[i].nodeName, node.getAttribute(node.attributes[i].nodeName));
                }
            }
            if(allChildren && node.childNodes && node.childNodes.length > 0){
                for(var i = 0, il = node.childNodes.length; i < il; i++){
                    newNode.appendChild(importNode(node.childNodes[i], allChildren));
                }
            }
            
            return newNode;
            break;
            
        case document.TEXT_NODE:
        case document.CDATA_SECTION_NODE:
        case document.COMMENT_NODE:
          return document.createTextNode(node.nodeValue);
          break;
        }
    };
  
    // The area on the screen for the grid with margins
    var margin = {
        top : 0,
        right : 0,
        bottom : 0,
        left : 0
    }, width = 800 - margin.left - margin.right, height = 680 - margin.top - margin.bottom;
    
    // Globals for the data and the SVG element
    var selector = null, data = null, svg = null;
    
    /*
     * 
     */
    function setColor(place, color) {
        var element = svg.select("svg").selectAll("[id*='" + place + "']");
        element.style('fill', color);
        
        // Now we need to go through all the sub-elements of the selected "group"
        element.selectAll("*").style('fill', color).style('stroke', color);
        element.selectAll("*").selectAll("*").style('fill', color).style('stroke', color);
    }
    
    /*
     * 
     */
    function setColors(colors) {
        if (colors) {
            _.each(colors, function(value, key, list) {
                Phone.setColor(key, value);
            });
        }
    };

    /*
     * 
     */
    function paint(_selector, colors) {
        selector = _selector;
        svg = d3.select(selector);

        d3.xml("/assets/android-template.svg", "image/svg+xml", function(xml) {
            
            var importedNode = null;
            try {
              importedNode = document.importNode(xml.documentElement, true);
            } catch(e) {
              importedNode = importNode(xml.documentElement, true); // for IE9
            }

            var phone = svg.node().appendChild(importedNode);
            pic = svg.select("svg");
            pic.attr('height', height);
            
            setColors(colors);
         });
    };

    /*
     * 
     */
    return {
        setColor : function(place, color) {
            return setColor(place, color);
        },
        
        setColors : function(colors) {
            return setColors(colors);
        },

        paint : function(_selector, colors) {
            return paint(_selector, colors);
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
