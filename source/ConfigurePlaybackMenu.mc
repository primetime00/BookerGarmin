using Toybox.WatchUi;

// Menu to choose what songs to playback
class ConfigurePlaybackMenu extends WatchUi.Menu2 {

    // Constructor
    function initialize() {
        Menu2.initialize({:title => Rez.Strings.playbackMenuTitle});
        var app = Application.getApp();     
        
        var books = app.getProperty(Properties.BOOKS);
        for (var i=0; i<books.keys().size(); ++i) {
        	var crc = books.keys()[i];
        	var book = books[crc];
        	var item = new WatchUi.MenuItem(book["title"], null, crc, {});
        	addItem(item);
        }
    }
}
