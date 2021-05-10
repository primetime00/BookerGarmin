using Toybox.Application;
using Toybox.Communications;
using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;


// This is the View that is used to configure the songs
// to sync. New pages may be pushed as needed to complete
// the configuration.
class BookerConfigureSyncView extends WatchUi.View {

    // Current state the view is in
    enum {
        STATE_FETCHING,
        STATE_FETCHED
    }

    // The books fetched from the server
    private var mBooks;
    // Wheter the view has been shown or not
    private var mMenuShown;


    function initialize() {
        View.initialize();
        mMenuShown = false;
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.ConfigureSyncLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
		if (mMenuShown) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else {
            Communications.makeWebRequest(Config.getUrl(Constants.LIST_URL), null, {}, method(:onBookListing));
            mBooks = {};
        }    	
    }

    // Update the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        // Indicate that the songs are being fetched
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, WatchUi.loadResource(Rez.Strings.fetchingBooks), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    function onBookListing(responseCode, data) {
        if (responseCode == 200) {
            mBooks = data;
            pushSyncMenu();
        } else {
            if (data != null) {
                WatchUi.pushView(new ErrorView(data["errorMessage"]), null, WatchUi.SLIDE_IMMEDIATE);
            } else {
                WatchUi.pushView(new ErrorView("Unknown Error"), null, WatchUi.SLIDE_IMMEDIATE);
            }
        }
        WatchUi.requestUpdate();
    }
    
    function getBookTitles(downloadedBooks, allBooks) {
    	var bookNames = [];
    	var keySet = {};
    	for (var j=0; j<allBooks.keys().size(); ++j) {
    		var key = allBooks.keys()[j];   		
    		var item = allBooks[key];
    		bookNames.add(item);
    		keySet[allBooks.keys()[j]] = 0;
    	}
    	for (var j=0; j<downloadedBooks.keys().size(); ++j) {
    		if (!keySet.hasKey(downloadedBooks.keys()[j])) {
    			var key = downloadedBooks.keys()[j];
    			var item = downloadedBooks[key];
    			bookNames.add(item);
    		}
    	}
    	return bookNames;  	
    }

     function getBookIds() {
    	var ids = new [mBooks.size()];
    	for (var idx=0; idx<mBooks.size(); ++idx) {
    		ids.add(mBooks[idx]["crc"]);
    	}
    	return ids;
    }
    
    function discoverBooks(downloadedBooks, allBooks) {
    	var items = {};
    	for (var j=0; j<allBooks.keys().size(); ++j) {
    		items[allBooks.keys()[j]] = false;
    	}
    	for (var j=0; j<downloadedBooks.keys().size(); ++j) {
    		items[downloadedBooks.keys()[j]] = true;
    	}   	
		return items;		
    }
    
    function pushSyncMenu() {
        var menu = new WatchUi.CheckboxMenu({:title => Rez.Strings.syncMenuTitle});
        var bookIds = mBooks.keys();        
        var precheckedItems = {};
        var app = Application.getApp();

        // Add in songs on the system to the prechecked list
        var downloadedBooks = app.getProperty(Properties.BOOKS);
        if (downloadedBooks == null) {
            downloadedBooks = {};
        }
        
        var precheckedBooks = discoverBooks(downloadedBooks, mBooks);
        
        var bookNames = getBookTitles(downloadedBooks, mBooks);
        
        for (var idx = 0; idx < bookNames.size(); ++idx) {
        	var bookCrc = bookNames[idx]["crc"];
        	var bookTitle = bookNames[idx]["title"];     	
            var item = new WatchUi.CheckboxMenuItem(bookTitle, null, bookNames[idx], precheckedBooks.hasKey(bookCrc) && precheckedBooks[bookCrc], {});
            menu.addItem(item);
        }
        WatchUi.pushView(menu, new ConfigureSyncMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        

        // Add in songs that need to be synced to the prechecked list
/*        var songsToSync = app.getProperty(Properties.SYNC_LIST);
        if (songsToSync == null) {
            songsToSync = {};
        }*/
/*
        refIds = songsToSync.keys();
        for (var idx = 0; idx < refIds.size(); ++idx) {
            var id = refIds[idx];
            precheckedItems[id] = true;
        }

        // Create the menu, prechecking anything that is to be or has been synced
        for (var idx = 0; idx < songNames.size(); ++idx) {
            var item = new WatchUi.CheckboxMenuItem(mSongs[songNames[idx]]["name"],
                                                    null,
                                                    mSongs[songNames[idx]],
                                                    precheckedItems.hasKey(mSongs[songNames[idx]]["id"]),
                                                    {});
            menu.addItem(item);
        }
        WatchUi.pushView(menu, new ConfigureSyncMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);*/
        mMenuShown = true;
    }
    

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
