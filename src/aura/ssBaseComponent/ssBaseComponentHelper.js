({
	helperMethod : function() {
		
	},
    
    showSpinner : function(){
        var event = $A.get("e.c:ssShowSpinnerEvent");
        if (event) {
            event.setParams({
                show: true
            });
        	event.fire();    
        }
    },
    
    hideSpinner : function(){
        var event = $A.get("e.c:ssHideSpinnerEvent");
        if (event) {
            event.setParams({
                show: false
            });
        	event.fire();    
        }
    },
    
    /**
     * Navigates to another community page
     * @param url the url to navigate to
     **/
    navigateToCommunityPage: function(url, redirect) {
        if (url.substring(0,4) == 'https') {
            var element = document.createElement('a');
            element.href = url;
            element.click();
        } else {
        	var urlEvent = $A.get('e.force:navigateToURL');
            var params = {
                'url': url
            };
            
            if (redirect) {
                params.redirect = redirect;
            }
            
            if (urlEvent) {
                urlEvent.setParams(params);
                urlEvent.fire();
            }    
        }
    },
    
    getNavigateParameter : function(sParam){
        console.debug("In Base component ");
        var getUrlParameter = function getUrlParameter(sParam) {
            var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                
                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? true : sParameterName[1];
                }
            }
        };
        return getUrlParameter(sParam);
    },
    
    showToast : function(title , type , mode , message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
                title: title,
            	type: type,
                mode: mode,
                message: message
            });
        toastEvent.fire();
        console.log("after toast");
    }
    
})