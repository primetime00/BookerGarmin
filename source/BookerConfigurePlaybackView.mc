using Toybox.WatchUi;

class BookerConfigurePlaybackView extends WatchUi.View {

	private var mMenuShown = false;
    private var mMessage = "";

    function initialize() {
        View.initialize();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        if (!mMenuShown) {
            // See how many songs are the the system
            var app = Application.getApp();
            var books = app.getProperty(Properties.BOOKS);

            // If there are any songs, push the configure playback menu. Otherwise show an error message.
            if ((books != null) && (books.size() > 0)) {
                WatchUi.pushView(new ConfigurePlaybackMenu(), new ConfigurePlaybackMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            } else {
                mMessage = "No books on\nthe system";
            }
            mMenuShown = true;
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    // Update the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, mMessage, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
    

}
