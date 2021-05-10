using Toybox.Application;
// General constants used in the app
module Config {
	function getUrl(op) {
		var app = Application.getApp();
		var url = app.getProperty(Properties.CONFIG);
		return url + op;
	}
}