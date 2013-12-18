// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//= require jquery-1.9.1.min
//= require jquery_ujs
//= require jquery-migrate-1.1.1

//= require jquery-ui-1.9.2.custom
//= require jquery.timers-1.2
//= require jquery.timeentry.min

//= require i18n/grid.locale-en
//= require jquery.jqGrid.min

//= require jquery.easy-pie-chart
//= require jquery.mousewheel
//= require jqcloud-1.0.4
//= require colorpicker/jquery.colorpicker

//= require bootstrap

//= require backbone/underscore-min
//= require backbone/backbone
//= require backbone/deep-model
//= require backbone/backbone.marionette
//= require backbone/extensions/backbone-relational
//= require backbone/extensions/backbone.paginator
//= require backbone/extensions/backbone-pageable

//= require backbone-forms/distribution/backbone-forms
//= require backbone-forms/distribution/editors/list.min
//= require backbone-forms/distribution/adapters/backbone.bootstrap-modal
//= require backbone-forms/distribution/templates/bootstrap3

//= require moment/moment+langs

//= require backgrid/backgrid
//= require backgrid/extensions/select-all/backgrid-select-all
//= require backgrid/extensions/moment-cell/backgrid-moment-cell
//= require backgrid/extensions/text-cell/backgrid-text-cell

//= require d3/d3.v3
//= require ckeditor/ckeditor
//= require ckeditor/adapters/jquery

// ---------------
//= require plugins/cpApp
//= require plugins/cpBaseTable
//= require plugins/cpItemTable
//= require plugins/cpParticipantTable
//= require plugins/cpMailHistoryTable
//= require plugins/cpVenueTable
//= require plugins/cpRoomTable
//= require plugins/timeEditor
//= require plugins/htmlEditor
//= require plugins/colorEditor
//= require plugins/DependentEditors

//= require TabViews

// TODO - check these
//= require plugins/cpdialog
//= require plugins/cpDynamicArea
//= require plugins/cpremovebutton

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
