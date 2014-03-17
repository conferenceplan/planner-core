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

//= require cloudinary
// require jquery-fileupload

//= require select2
//  require select2_locale_fr

//= require ckeditor-jquery

//= require bootstrap

//= require backbone/underscore-min
//= require backbone/backbone
//= require backbone/deep-model
//= require backbone/backbone.marionette
//= require backbone/extensions/backbone.poller
//= require backbone/extensions/backbone-relational

//= require backbone-forms/distribution/backbone-forms
//= require backbone-forms/distribution/editors/list
//= require backbone-forms/planner.bootstrap-modal
//= require backbone-forms/templates/bootstrap3
//= require spin

//= require moment
//= require moment/fr.js
//= require bootstrap-datetimepicker
//= require d3

// ---------------
//= require plugins/cpApp
//= require plugins/cpAjax
//= require plugins/cpBaseTable
//= require plugins/cpItemTable
//= require plugins/cpParticipantTable
//= require plugins/cpMailHistoryTable
//= require plugins/cpVenueTable
//= require plugins/cpRoomTable
//= require plugins/cpUserTable
//= require plugins/timeEditor
//= require plugins/htmlEditor
//= require plugins/colorEditor
//= require plugins/selectEditor
//= require plugins/DependentEditors
//= require plugins/cpReportBase
//= require plugins/dateTimeEditor
//= require plugins/clImageEditor
//= require plugins/fileUploadEditor

//= require TabViews

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
                    alertMessage(response.responseText);
                } else {
                    alertMessage("Error communicating with backend ..."); // TODO - change to translatable string
                };
            };
        };
        
        return Backbone._sync(method, model, options);
    };
    
    $('.survey-help').tooltip();
                
});

function showSpinner(place) {
    var spinner = new Spinner({ className: 'spinner center-block' }).spin();
    $(place).html(spinner.el);
};

function alertMessage(message) {
    $('#alert-area').html("<div class=\"alert alert-warning fade in\"><button class=\"close\" data-dismiss=\"alert\">×</button>"+ message +"</div>");
};

function infoMessage(message) {
    $('#alert-area').html("<div class=\"alert alert-success alert-block fade in\"><button class=\"close\" data-dismiss=\"alert\">×</button>"+ message +"</div>");
};
