/**
 * @author User
 */
//
//	The following definitions are a modified interface to the JQuery Grid
//  The basic plan is to have functions that generate javascript objects that are the arguments to the grid functions
//  Those objects are then passed to the Grid functions
//
//  This is designed so that project defaults are built into the functions and the arguments are 
//  the pieces that normally change.
//  It also allows for the possibility of changing the defaults by assigning different values
//  to the relevant properties after the functions have executed

		
//  The function that builds the grid parameters 
		(function( $ ){
			$.planIt = {};
			
			$.planIt.gridParams = function
			(
				baseName,			// Name of the model we are dealing with 
				idName, 			// Name of the DOM object 
				colNames, 			// Array of column names
				columns, 			// Matching array of column data (uses column definition functions)
				caption				// Caption
			) {
				var result = {};
				
				result.url = '/' + baseName + '/list';
		        result.datatype= 'xml';
		        result.colNames = colNames;
		        result.colModel = columns;
		        result.pager = jQuery('#pager');
		        result.rowNum = 10;
		        result.autowidth = false;
		        result.rowList = [10, 20, 30];
		        result.sortname = columns[0].index;
		        result.sortorder = "asc";
		        result.viewrecords = true;
		        result.imgpath = 'stylesheets/start/images';
		        result.caption = caption;
		        result.editurl = '/' + baseName;
		        result.multipleSearch = true;
		        result.onSelectRow = function(ids){
		            $('#' + idName).text(ids);
		            return false;
		        }
				
				return result;
		    };
		    
		    
// Column definition functions

		    var nestedNames = function
		    (
		    	nameArray
		    ){
		    	var result;
		    	
		    	if (nameArray.length == 1)
		    	{
		    		result = nameArray[0];
		    	}
		    	else
		    	{
		    		var outer = nameArray.shift();
		    		result = outer + '[' + nestedNames(nameArray) + ']';
		    	}
		    	
		    	return result;
		    }
		    
		    var formOptions = function
		    (
		    	rowpos,							// Row position in edit dialogue
		    	label,							// Row label in edit dialogue
		    	required						// is value required flag
		    ){
		    	result = {};
		    	
	            result.rowpos = rowpos;
		        result.label = label;
			    
		        if (required) {
			    	result.elmprefix = "(*)";
			    }
			    	
		    	return result;
		    }
		    
		    var fieldBase = function
		    (
	    		nameArray, 		//  Hierarchy of names in the model
	    		width 			//  Width of edit field
		    ){
		    	var result ={};
		    	
	            result.name = nestedNames(nameArray); //  The shifts kill most of the array, leaving the last element
		    	result.index = nameArray[0];
		    	result.width = width;
	            result.editable = true,
	            result.editoptions = {
	                size: 20
	            };
		    	
		    	return result;
		    }
		    
// String editing
		    
		    $.planIt.text = function
		    (
	    		nameArray, 		//  Hierarchy of names in the model
	    		width, 			//  Width of edit field
	    		rowpos,			//  Row position of field in edit dialogue
	    		label, 			//  Label of field in edit 
	    		required		//  Boolean indicating an entry is required
		    ){
		    	var result = fieldBase(nameArray, width);
		    	
	            result.formoptions = formOptions(rowpos, label, required);
	            
	            result.editrules = {
	                required : required
	            }
	            
	            return result;
		    };
		    
// String editing with search capability
		    
		    $.planIt.textSearch = function
		    (
	    		nameArray, 		//  Hierarchy of names in the model
	    		width, 			//  Width of edit field
	    		rowpos,			//  Row position of field in edit dialogue
	    		label, 			//  Label of field in edit 
	    		required		//  Boolean indicating an entry is required
		    ){
		    	var result = fieldBase(nameArray, width);
		    	
		    	result.searchoptions = {
	                sopt: ['eq','ne','bw','bn','cn','nc']
	            };
	            
	            result.formoptions = formOptions(rowpos, label, required);
	            
	            result.editrules = {
	                required : required
	            }
	            
	            return result;
		    };
		    
//  String editing with sort capability
		    
		    $.planIt.textSort = function
		    (
	    		nameArray, 		//  Hierarchy of names in the model
	    		width, 			//  Width of edit field
	    		rowpos,			//  Row position of field in edit dialogue
	    		label, 			//  Label of field in edit 
	    		required		//  Boolean indicating an entry is required
		    ){
		    	var result = fieldBase(nameArray, width);
		    	
	            result.sortable = true;

	            result.formoptions = formOptions(rowpos, label, required);
	            
	            result.editrules = {
	                required: required
	            }

		    	return result;
		    };
		    
//text, textarea, select, checkbox, password, button, image and file
//  Textarea field
		    
		    $.planIt.textarea = function
		    (
	    		nameArray, 		//  Hierarchy of names in the model
	    		width, 			//  Width of edit field
	    		rowpos,			//  Row position of field in edit dialogue
	    		label, 			//  Label of field in edit 
	    		required		//  Boolean indicating an entry is required
		    ){
		    	var result = fieldBase(nameArray, width);

		    	result.edittype = 'textarea';

		    	result.search = true;
	            result.searchoptions = {
	                sopt: ['eq','ne','bw','bn','cn','nc']
	            };
		    	
	            result.formoptions = formOptions(rowpos, label, required);
	            
	            result.editrules = {
	                required: required,
	                edithidden: true
	            }

		    	return result;
		    };

// String number editing with search capability
		    
		    $.planIt.numberSearch = function
		    (
	    		nameArray, 		//  Hierarchy of names in the model
	    		width, 			//  Width of edit field
	    		rowpos,			//  Row position of field in edit dialogue
	    		label, 			//  Label of field in edit 
	    		required		//  Boolean indicating an entry is required
		    ){
		    	var result = fieldBase(nameArray, width);
		    	
		    	result.searchoptions = {
	                sopt: ['eq','ne','lt','le','gt','ge']
	            };
	            
	            result.formoptions = formOptions(rowpos, label, required);
	            
	            result.editrules = {
	                required : required
	            }
	            
	            return result;
		    };
		    
		    
//  Select field
		    
		    $.planIt.select = function
		    (
	    		nameArray, 		//  Hierarchy of names in the model
	    		width, 			//  Width of edit field
	    		rowpos,			//  Row position of field in edit dialogue
	    		label, 			//  Label of field in edit 
	    		required,		//  Boolean indicating an entry is required
	    		data			//  URL of data source
		    ){
		    	var result = fieldBase(nameArray, width);
		    	
		    	result.edittype = 'select';
		    	result.stype = 'select';
	            result.sortable = true;

	            result.searchoptions = {
	                dataUrl: data,
	                sopt: ['eq','ne']
	            };

	            result.formoptions = formOptions(rowpos, label, required);
	            
	            result.editrules = {
	                required: required
	            }

	            result.editoptions.dataUrl = data;
	            result.editoptions.size = 3;
	            
		    	return result;
		    };
		    
//  Hidden data
		    
		    $.planIt.hidden = function
		    (
		    		nameArray 		//  Hierarchy of names in the model
		    ){
		    	var result = {};

	            result.name = nestedNames(nameArray);		//  The shifts kill most of the array
		    	result.index = nameArray[0];
	            result.hidden = true;
	            result.search = false;

		    	return result;
		    };

//  End of field definition functions
		    
//  Response function
		    
		    $.planIt.showError = function(name)
		    {
		    	return function (response, postdata) {
			        // examine return for problem - look for errorExplanation in the returned HTML
		    		var text = $(response.responseText).find(".errorExplanation");
			        if (text.size() > 0) {
			            text.css('font-size', '6pt');
			            text = $("<div></div>").append(text);
			            return [false, text.html()];
			        }
			        
//			        jQuery(name).trigger("reloadGrid");
			        return [true, "Success"];
		    	}
		    }

//  Navigator, and actions options functions

// specs for second argument to control available navigation, all are available by default, set to false if not
// {add: del: edit: search: view:}
	
//  Common options for actions
		    
		    $.planIt.optionsBase = function()
		    {
		    	var result = {};
		    	
		        result.jqModal = true;
		        result.closeOnEscape = true;

		        return result;
		    }

//  Common options for actions that change data
		    
		    $.planIt.optionsChange = function
		    (
		    		name	//  DOM name for processResponse
		    ){
		    	var result = $.planIt.optionsBase();
		    	
		        result.height = 250;
		        result.reloadAfterSubmit = false;
		        result.jqModal = true;
		        result.closeOnEscape = true;
		        result.bottominfo = "Fields marked with (*) are required";
		        result.afterSubmit = $.planIt.showError(name);
		        
		        return result;
		    };

//  Edit action options
		    
		    $.planIt.editOptions = function
		    (
		    		name,		// DOM name for processResponse and route name for fetching data 
		    		fetchData	// function to fetch data for editing
		    ){
		    	var result = $.planIt.optionsChange(name);
		    	
		        result.closeAfterEdit = true;
		        result.beforeSubmit = function(postdata, formid){
		            this.ajaxEditOptions = {
		                url: '/' + name + '/' + fetchData(postdata),
		                type: 'put'
		            };
		            return [true, "ok"];
		        }
		    	return result;
		    };
		    
//  Add action options
		    
		    $.planIt.addOptions = function
		    (
		    	name  // DOM name for processResponse 
		    ){
		    	var result = $.planIt.optionsBase();

		    	result.closeAfterAdd = true;		    	

		        return result;
		    };

//  Delete action options
		      
		    $.planIt.deleteOptions = function
		    (
		    	name				// route name for deleting data  	
		    )
		    {
		    	var result = $.planIt.optionsBase();
		    	
		    	result.loadAfterSubmit = true;
		        result.beforeSubmit = function(postdata){
		            this.ajaxDelOptions = {
		                url: '/' + name + '/' + postdata,
		                type: 'delete'
		            };
		            return [true, "ok"];
		        };
		        
		    	return result;
		    };
		    
//  Search action options
		    
		    $.planIt.searchOptions = function()
		    {
		    	var result = $.planIt.optionsBase();

		    	result.multipleSearch = true;
		    	result.groupOps = [ { op: "AND", text: "all" }, { op: "OR", text: "any" } ];

		    	return result;
		    };
		    
//  View action options
		    
		    $.planIt.viewOptions = function
		    (
		    	caption				// Caption
		    ){
		    	var result = {};
		        
		    	result.caption = caption;
		    	result.bClose = "Close";
		        result.beforeShowForm = function(formid){
		               $('.ui-jqdialog-content .form-view-data').css('white-space', 'normal');
		               $('.ui-jqdialog-content .form-view-data').css('height', 'auto');
		               $('.ui-jqdialog-content .form-view-data').css('vertical-align', 'text-top');
		               $('.ui-jqdialog-content .form-view-data').css('padding-top', '2px');
		        };

		        return result;
		    };
		    
		    
		})( jQuery );
