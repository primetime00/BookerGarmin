using Toybox.System;
using Toybox.Communications;
using Toybox.Lang;
using Toybox.Application;

class CommListener extends Communications.ConnectionListener {
    function initialize() {
        Communications.ConnectionListener.initialize();
    }

    function onComplete() {
        //System.println("Transmit Complete");
    }

    function onError() {
        System.println("Transmit Failed");
    }
}

class PhoneCom {
	var listener;
	
	function initialize() {
		listener = new CommListener();
		register();
	}
	
	function register() {
		Communications.registerForPhoneAppMessages(method(:phoneMessageCallback));	
	}
	
	function phoneMessageCallback(msg) {
		if (msg.data instanceof Lang.Dictionary) {
			if (msg.data.hasKey("url")) {
				var url = msg.data.get("url");
				writeUrl(url);
			}
		}
	}
	
	function writeUrl(url) {
		var app = Application.getApp();
		app.setProperty(Properties.CONFIG, url);
		System.println("Configuration has been set to:");
		System.println(url);
	}

	function askForConfig() {
		//System.println("Asking for configuration");
		Communications.transmit({"operation" => "config"}, {}, listener);
	}
	
}

