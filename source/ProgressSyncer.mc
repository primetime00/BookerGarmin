using Toybox.Communications;
using Toybox.Application;
using Toybox.System;

// Delegate injects a context argument into web request response callback
class ProgressSyncer
{

    hidden var mSyncDoneCallback; // function always takes 3 arguments
    hidden var mContext;  // this is the 3rd argument
    hidden var mBooks;

    function initialize(syncDoneCB, context) {
        mSyncDoneCallback = syncDoneCB;
        mContext = context;
        var app = Application.getApp();
        mBooks = app.getProperty(Properties.BOOKS);        
    }
    
    function sync(url) {
    	if (mBooks == null || mBooks.size() == 0) {
    		return;
    	}
        var options = {:method => Communications.HTTP_REQUEST_METHOD_POST,
        			   :header => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON },
                       :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON};                       
        var data = {};
        for (var i=0; i<mBooks.keys().size(); ++i) {
        	var crc = mBooks.keys()[i];
        	var book = mBooks[mBooks.keys()[i]];
        	System.println("Sending progress: " + book);
        	data[crc] = book;
        }
        data["DEVICE"] = "WATCH";
        Communications.makeWebRequest(url, data, options, self.method(:syncComplete));
    }
    
    function syncComplete(code, data) {
    	var updated = false;
    	if (code == 200) {
    		System.println("SYNC COMPLETE");
    		for (var i=0; i<mBooks.keys().size(); ++i) {
    			var crc = mBooks.keys()[i];
    			var book = mBooks[mBooks.keys()[i]];
    			if (data.hasKey(crc)) {
    				if (!data[crc].hasKey("update") || !data[crc]["update"]) {
    					continue;
    				}
    				updated = true;
    				book["position"] = data[crc]["position"];
    				book["chapter"] = data[crc]["chapter"];
    				System.println("Updated ch and pos to " + book["chapter"] + " / " + book["position"]);  
    			}
    		}
    		if (updated) {
    			var app = Application.getApp();
    			app.setProperty(Properties.BOOKS, mBooks);
    		} 		
    	}
    	mSyncDoneCallback.invoke();
    }
    
    
	
}