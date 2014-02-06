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

//= require select2
//  require select2_locale_fr

//= require ckeditor-jquery

//= require bootstrap

//= require backbone/underscore-min
//= require backbone/backbone
//= require backbone/deep-model
//= require backbone/backbone.marionette
//= require backbone/extensions/backbone-relational
//= require backbone/extensions/backbone.paginator
//= require backbone/extensions/backbone-pageable

//= require backbone-forms/distribution/backbone-forms
//= require backbone-forms/distribution/editors/list
//= require backbone-forms/distribution/adapters/backbone.bootstrap-modal
//= require backbone-forms/distribution/templates/bootstrap3

//= require moment
//= require bootstrap-datetimepicker
//= require d3

// ---------------
//= require plugins/cpApp
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

//= require TabViews

//= require_self

jQuery(document).ready(function() {
    _.templateSettings = {
        interpolate : /\{\{\=(.+?)\}\}/g,
        evaluate : /\{\{(.+?)\}\}/g
    };
});

function alertMessage(message) {
    $('#alert-area').html("<div class=\"alert alert-warning fade in\"><button class=\"close\" data-dismiss=\"alert\">×</button>"+ message +"</div>");
};

function infoMessage(message) {
    $('#alert-area').html("<div class=\"alert alert-success alert-block fade in\"><button class=\"close\" data-dismiss=\"alert\">×</button>"+ message +"</div>");
};
