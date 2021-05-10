using Toybox.Media;
using Toybox.WatchUi;

// Delegate for playback menu
class ConfigurePlaybackMenuDelegate extends WatchUi.Menu2InputDelegate {

    // Constructor
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    // When an item is selected, add or remove it from the system playlist
    function onSelect(item) {    
    	var crc = item.getId();
        var app = Application.getApp();
        app.setProperty(Properties.CURRENT_BOOK, crc);
        Media.startPlayback(null);
                
    }

    // Pop the view when done
    function onDone() {
        Media.startPlayback(null);
    }

    // Pop the view when back is pushed
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
