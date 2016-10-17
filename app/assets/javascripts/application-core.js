// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//= require jquery
//= require jquery_ujs
//= require jquery-migrate-1.1.1

//= require jquery.ui.all

//  require i18n/grid.locale-en
//= require jqgrid-jquery-rails

//= require jquery.easy-pie-chart
//= require jquery.mousewheel
//= require jqcloud-1.0.4
//= require colorpicker/jquery.colorpicker
//= require jQuery.download
//= require bigSlide

//= require cloudinary

//= require i18n
//= require i18n/core-translations

//= require select2
//  require select2_locale_fr

//= require ckeditor-jquery

//= require bootstrap

//= require bootstrap-tabdrop
//= require bootstrap-table/bootstrap-table
//= require bootstrap-table/extensions/filter-control/bootstrap-table-filter-control

//= require backbone/underscore-min
//= require backbone/backbone
//= require backbone/deep-model
//= require backbone-model-file-upload.js
//= require backbone/backbone.marionette
//= require backbone/extensions/backbone.poller
//= require backbone/extensions/backbone-relational

//= require backbone-forms/distribution/backbone-forms
//= require backbone-forms/distribution/editors/list
//= require backbone-forms/planner.bootstrap-modal
//= require backbone-forms/templates/bootstrap3
//= require spin

//= require moment-with-locales
// require moment/fr.js
//= require bootstrap-datetimepicker
//= require bootstrap-daterangepicker/daterangepicker
//= require d3

// ---------------
//= require plugins/cpApp
//= require plugins/cpAjax
//= require plugins/cpBaseTable
//= require plugins/cpBaseBootstrapTable
//= require plugins/cpMailHistoryBootstrapTable
//= require plugins/cpItemTable
//= require plugins/cpParticipantTable
//= require plugins/cpMailHistoryTable
//= require plugins/cpVenueTable
//= require plugins/cpRoomTable
//= require plugins/cpUserTable
//= require plugins/timeEditor
//= require plugins/htmlEditor
//= require plugins/htmlExtEditor
//= require plugins/colorEditor
//= require plugins/selectEditor
//= require plugins/dateTimeEditor
//= require plugins/DependentEditors
//= require plugins/cpReportBase
//= require plugins/clImageEditor
//= require plugins/cloudImageEditor
//= require plugins/fileUploadEditor
//= require plugins/cpPendingImportPeopleTable
//= require plugins/typeAheadTextEditor
//= require plugins/styledCheckboxEditor
//= require plugins/NumberWithChange

//= require TabViews

//= require twitter/typeahead.min

//= require iframeResizer.contentWindow

//= require_self

jQuery(document).ready(function() {
    _.templateSettings = {
        interpolate : /\{\{\=(.+?)\}\}/g,
        evaluate : /\{\{(.+?)\}\}/g
    };

    // Over-ride the backbone sync so that the rails CSRF token is passed to the backend
    Backbone._sync = Backbone.sync;
    Backbone.sync = function(method, model, options) {
        if (method == 'create' || method == 'update' || method == 'delete') {
            var auth_options = {};
            auth_options[$("meta[name='csrf-param']").attr('content')] = $("meta[name='csrf-token']").attr('content');
            model.set(auth_options, {silent: true});
        };
        options.error = function(response) {
            if (response.status > 0) {
                if (response.responseText) {
                    if (options.handle_error) {
                        options.handle_error(response);
                    } else {
                        alertMessage(response.responseText);
                    }
                } else {
                    alertMessage("Error communicating with backend ..."); // TODO - change to translatable string
                };
            };
        };
        
        return Backbone._sync(method, model, options);
    };
    
    $('.survey-help').tooltip();
    
    // enable the popover bootstrap javascript thing
    $('.bpopover').popover({
        trigger: 'hover',
        html: true,
        animation: false,
        container: 'body',
        viewport: { selector: 'body', padding: 0 },
    });
                
});

function showSpinner(place) {
    var spinner = new Spinner({ className: 'spinner center-block' }).spin();
    $(place).html(spinner.el);
};

function alertMessage(message) {
    $('#alert-area').html("<div class=\"alert alert-warning fade in\"><button class=\"close\" data-dismiss=\"alert\">×</button>"+ message +"</div>");
};

function dialogAlertMessage(message) {
    $('#dialog-alert-area').html("<div class=\"alert alert-warning fade in\"><button class=\"close\" data-dismiss=\"alert\">×</button>"+ message +"</div>");
};

function infoMessage(message) {
    $('#alert-area').html("<div class=\"alert alert-success alert-block fade in\"><button class=\"close\" data-dismiss=\"alert\">×</button>"+ message +"</div>");
};

function stripHtml(html) {
    var tmp = document.createElement("DIV");
    tmp.innerHTML = html;
    return tmp.textContent || tmp.innerText || "";
};

function randomString(length, chars) {
    var result = '';
    for (var i = length; i > 0; --i) result += chars[Math.round(Math.random() * (chars.length - 1))];
    return result;
}




