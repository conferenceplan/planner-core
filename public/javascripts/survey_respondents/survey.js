/*
 * JS for the autocomplete in the survey
 * 
 * 1. For each of the text fields that can have autocomplete, we need to find them and also the context for these
 * 
 * tags: context
 * 
 * Put in some HTML like the following:
 * div.tag
 * <div class='tag'> 
 * <div id='context' style='display:none'>contextname</div>
 * <div id='respondent' style='display:none'>id</div>
 * <textarea rows="5" name="responses[g3q7t1]" id="responses_g3q7t1" cols="30" class='tag'></textarea>
 * </div>
 * We also need the id of the survey respondent, and this needs to be passed in with the survey (as a hidden field)
 * 
 */