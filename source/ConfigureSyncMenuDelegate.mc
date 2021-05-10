using Toybox.WatchUi;
using Toybox.System;

// Menu delegate for Sync Menu
class ConfigureSyncMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var mSyncList;
    private var mDeleteList;

    // Constructor
    function initialize() {
        Menu2InputDelegate.initialize();
        mSyncList = [];
        mDeleteList = [];
    }

    // Either add it or remove the item from the
    // list of songs to sync or delete
    function onSelect(item) {
        if (item.isChecked()) {
            mSyncList.add(item.getId());
            mDeleteList.remove(item.getId());
        } else {
            mSyncList.remove(item.getId());
            mDeleteList.add(item.getId());
        }
    }

    // Pop the view when back is pushed
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    // Stores the songs to delete and download in the object store
    function onDone() {
        var app = Application.getApp();
        var mBooks = app.getProperty(Properties.BOOKS); //get our downloaded books
        if (mBooks == null) {
            mBooks = {};
        }
        
        if (mBooks.size() > 0 && mDeleteList.size() > 0) {
	        var deleteInfo = app.getProperty(Properties.DELETE_LIST);
	        if (deleteInfo == null) {
	            deleteInfo = [];
	        }
	        for (var i=0; i<mDeleteList.size(); ++i) {
	        	var delItem = mDeleteList[i];
	        	var delCrc = delItem["crc"];
	        	if (!mBooks.hasKey(delCrc)) {
	        		continue;
	        	}
	        	deleteInfo.add(delCrc);
	        }
	        app.setProperty(Properties.DELETE_LIST, deleteInfo);       
        }
        
        var syncInfo = app.getProperty(Properties.SYNC_LIST);
        if (syncInfo == null) {
            syncInfo = {};
        }
        
        for (var i = 0; i < mSyncList.size(); ++i) {
        	var id = mSyncList[i]["crc"];
        	if (!mBooks.hasKey(id)) { //we don't have this book
        		syncInfo[id] = mSyncList[i];
        	}
        }
        
        app.setProperty(Properties.SYNC_LIST, syncInfo);            
        
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    // Utility function to get the ContentRefId from the already downloaded songs.
    // Converts songId, the ID from the server, to the stored ref id
    function getRefIdFromSongs(songId, mSongs) {
        var keys = mSongs.keys();

        for (var idx = 0; idx < keys.size(); ++idx) {
            if (mSongs[keys[idx]].equals(songId)) {
                return keys[idx];
            }
        }

        return null;
    }
}