using Toybox.Application;
using Toybox.Media;
using Toybox.System;

class BookerApp extends Application.AudioContentProviderApp {

	var mPhoneCom;

    function initialize() {
        AudioContentProviderApp.initialize();
        mPhoneCom = new PhoneCom(); 
    }

    // onStart() is called on application start up
    function onStart(state) {
    	mPhoneCom.askForConfig();
		var currentUrl = getProperty(Properties.CONFIG);
		if (currentUrl == null) {
			setProperty(Properties.CONFIG, Constants.DEFAULT_URL);
		}        
    	var books = getProperty(Properties.BOOKS);
    	if (books != null && books.size() > 0) {
    		var current = getProperty(Properties.CURRENT_BOOK);
    		if (current == null) {
    			var crc = books.keys()[0];
    			setProperty(Properties.CURRENT_BOOK, crc);
    		}    		
    	}
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    /*
    	var wifiState = System.getDeviceSettings().connectionInfo[:wifi];
    	if (wifiState != null) {
    		var state2 = System.getDeviceSettings().connectionInfo[:wifi].state;
    		if (state2 == System.CONNECTION_STATE_CONNECTED) {
    			var syncer = new ProgressSyncer(null, null);
    			syncer.sync(Config.getUrl(Constants.PROGRESS_URL));	
    		}
    	}*/
    }

    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(arg) {
        return new BookerContentDelegate();
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() {
        return new BookerSyncDelegate();
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() {
        return [ new BookerConfigurePlaybackView(), new BookerConfigurePlaybackDelegate() ];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
        return [ new BookerConfigureSyncView(), new BookerConfigureSyncDelegate() ];
    }

}
