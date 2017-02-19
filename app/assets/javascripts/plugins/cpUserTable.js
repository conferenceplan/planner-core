/*
 * 
 */
(function($) {
$.widget( "cp.userTable", $.cp.baseTable , {
    createColModel : function(){
        return [{
            label : this.options.login[1],
            hidden : !this.options.login[0],
            name: 'login',
            index: 'login',
            search : true
        },{
            label : this.options.email[1],
            hidden : !this.options.email[0],
            name: 'email',
            search : false
        }, {
            label : this.options.roles[1],
            hidden : !this.options.roles[0],
            name: 'roles',
            // index: 'roles',
            search : false,
            sort : false,
                formatter : function(cellvalue, options, rowObject) {
                    var res = "";
                    
                    if (typeof rowObject['roles'] != 'undefined') {
                        for (i = 0 ; i < rowObject['roles'].length; i++) {
                            if (i > 0) {
                                res += ", ";
                            }
                            res += rowObject['roles'][i].title;
                        }
                    }
                    
                    return res;
                }
        }, {
            label : this.options.login_count[1],
            hidden : !this.options.login_count[0],
            name: 'login_count',
            index: 'login_count',
            search : false,
            sort : false
        }, {
            label : this.options.failed_login_count[1],
            hidden : !this.options.failed_login_count[0],
            name: 'failed_login_count',
            index: 'failed_login_count',
            search : false,
            sort : false
        }];
    },
    
    pageTo : function(mdl) {
        return mdl.get('name');
    },
    
});
})(jQuery);
