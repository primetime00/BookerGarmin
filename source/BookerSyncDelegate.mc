using Toybox.Communications;
using Toybox.Media;
using Toybox.System;

class BookerSyncDelegate extends Media.SyncDelegate {

    private var mConfig;
    private var mSyncList;
    private var mDeleteList;
    private var mTotalBooksToSync;
    private var mBooksSynced;
    private var mPhoneCom;
    private var mTotalDuration;
    private var mCurrentDuration;


    function initialize() {   
        SyncDelegate.initialize();
       
        
        // Get the sync list
        var app = Application.getApp();
        mPhoneCom = new PhoneCom();
        
        mConfig = app.getProperty(Properties.CONFIG);
        if (mConfig == null) {
            //mConfig = {"ip" => "http://localhost", "port" => 8080};
            mPhoneCom.askForConfig();            
        }
        
        
        mSyncList = app.getProperty(Properties.SYNC_LIST);
        if (mSyncList == null) {
            mSyncList = {};
        }

        // Get the delete list
        mDeleteList = app.getProperty(Properties.DELETE_LIST);
        if (mDeleteList == null) {
            mDeleteList = [];
        }

        mBooksSynced = 0;
        
    }
    
    // Called when the system starts a sync of the app.
    // The app should begin to download songs chosen in the configure
    // sync view .
    function onStartSync() {
    	mTotalBooksToSync = mSyncList.size() + mDeleteList.size();
    	mTotalDuration = getTotalDuration(mSyncList);
    	mCurrentDuration = 0;
    	deleteBooks();
    	syncNextBook();
    }
    
    function syncProgress() {
    	var ps = new ProgressSyncer(method(:onProgressDone), {});
    	ps.sync(Config.getUrl(Constants.PROGRESS_URL));    	
    }
    
    function onProgressDone() {
    	Media.notifySyncComplete(null);    
    }
    
    function assignCurrentBook() {
    	var app = Application.getApp();
    	var books = app.getProperty(Properties.BOOKS);
    	var currentBookCrc = app.getProperty(Properties.CURRENT_BOOK);
    	if (books != null && books.size() > 0) {
    		if (currentBookCrc == null) {
    			app.setProperty(Properties.CURRENT_BOOK, books.keys()[0]);
    		}
    	}
    }
    
    function deleteBooks() {
        var app = Application.getApp();
        
        if (mDeleteList.size() == 0) {
        	return;
        }

        // Remove the song from the system
        var books = app.getProperty(Properties.BOOKS);
        var currentBookCrc = app.getProperty(Properties.CURRENT_BOOK);

        if (books == null) {
            return;
        }
        System.println("Removing books");
        for (var i=0; i<mDeleteList.size(); ++i) {
        	var delCrc = mDeleteList[i];
        	if (books.hasKey(delCrc)) {
        		var book = books[delCrc];
        		var chapters = book["chapters"];
        		for (var j=0; j<chapters.size(); ++j) {
        			var id = chapters[j];
        			Media.deleteCachedItem(new Media.ContentRef(id, Media.CONTENT_TYPE_AUDIO));
        		}
        		System.println("Removed " + book["title"]);
        		books.remove(delCrc);
        		if (currentBookCrc != null && currentBookCrc == delCrc) {
        			app.deleteProperty(Properties.CURRENT_BOOK);
        			currentBookCrc = null;
        			System.println("Removed current book!");
        		}
        		app.setProperty(Properties.BOOKS, books);
        	}
        	onBookSynced();
        }       
        app.deleteProperty(Properties.DELETE_LIST);       
    }
    
    function syncComplete() {
    	assignCurrentBook();
    	syncProgress();        	
    }
    
    function getTotalDuration(sync) {
    	var ids = mSyncList.keys();
    	var total = 0;
    	for (var i=0; i<mSyncList.keys().size(); ++i) {
    		var item = mSyncList[ids[i]];
    		total += item["duration"]; 		    	
    	}
    	return total;
    }
    
    function syncNextBook() {
        var ids = mSyncList.keys();

        // Check for completion
        if (ids.size() == 0) {
        	syncComplete();
            return;
        }        

        if (mSyncList[ids[0]]) {
            var bookInfo = mSyncList[ids[0]];           
            var crc = bookInfo["crc"];
            var url = Config.getUrl(Constants.BOOK_URL)+"/"+crc;
            var context = {"url" => url, "book" => bookInfo, "chapter" => 0, "duration" => mTotalDuration};
            var delegate = new RequestDelegate(method(:onBookDownloaded), method(:onChapterDownloaded), context);
            delegate.downloadBook(url); 
        }
    }
    
    function onChapterDownloaded(context, index) {
    	var book = context["book"];
    	var duration = book["chapterDurations"][index];
    	mCurrentDuration += duration;
    	var progress =  mCurrentDuration / mTotalDuration.toFloat();
        progress = (progress * 100).toNumber();
        Media.notifySyncProgress(progress);   	    	    	 
    }
    
    function onBookDownloaded(responseCode, context, chapterList) {
        if (responseCode == 200) {
            System.println("Book Downloaded");
            mSyncList.remove(context["book"]["crc"]);
            var app = Application.getApp();
            var books = app.getProperty(Properties.BOOKS);
            if (books == null) {
            	books = {};
            }
            var crc = context["book"]["crc"];
            books[crc] = {"title" => context["book"]["title"], "chapter" => 0, "position" => 0, "chapters" => chapterList, "chapterDurations" => context["book"]["chapterDurations"]}; 
            app.setProperty(Properties.BOOKS, books);
            var currentBook = app.getProperty(Properties.CURRENT_BOOK);
            if (currentBook == null) {
            	app.setProperty(Properties.CURRENT_BOOK, crc);
            }
            onBookSynced();
            syncNextBook();            
        }
   
    }
        

    // Called by the system to determine if the app needs to be synced.
    function isSyncNeeded() {
    	System.println("IS SYNC NEEDED?");
        return true;
    }

    // Called when the user chooses to cancel an active sync.
    function onStopSync() {
        Communications.cancelAllRequests();
        Media.notifySyncComplete(null);
    }
    
    // Update the system with the current sync progress
    function onBookSynced() {
        ++mBooksSynced;
    }    
}
