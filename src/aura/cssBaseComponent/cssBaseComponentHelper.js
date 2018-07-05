({
    showSpinner : function(){
        var event = $A.get("e.c:cssSpinnerEvent");
        if (event) {
            event.setParams({
                show: true
            });
        	event.fire();    
        }
    },
    
    hideSpinner : function(){
        var event = $A.get("e.c:cssSpinnerEvent");
        if (event) {
            event.setParams({
                show: false
            });
        	event.fire();    
        }
    },
    
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
    
    getUrlParameterByName: function(component, event, name) {
   		name = name.replace(/[\[\]]/g, "\\$&");
      	var url = window.location.href;
      	var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
      	var results = regex.exec(url);
      	if (!results) return null;
      	if (!results[2]) return '';
      	return decodeURIComponent(results[2].replace(/\+/g, " "));
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