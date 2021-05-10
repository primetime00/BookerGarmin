using Toybox.Media;
using Toybox.Application;
using Toybox.System;
using Toybox.Timer;

// This class handles events from the system's media
// player. getContentIterator() returns an iterator
// that iterates over the songs configured to play.
class BookerContentDelegate extends Media.ContentDelegate {

	var trackTimer;
	var currentTime;
	var currentRef;
	hidden var timeInterval = 20;

    function initialize() {
        ContentDelegate.initialize();
        trackTimer = new Timer.Timer();
        currentRef = 0;
    }

    // Returns an iterator that is used by the system to play songs.
    // A custom iterator can be created that extends Media.ContentIterator
    // to return only songs chosen in the sync configuration mode.
    function getContentIterator() {
    	System.println("Getting new content iterator?");
        return new BookerContentIterator();
    }

    // Respond to a user ad click
    function onAdAction(adContext) {
    }

    // Respond to a thumbs-up action
    function onThumbsUp(contentRefId) {
    }

    // Respond to a thumbs-down action
    function onThumbsDown(contentRefId) {
    }

    // Respond to a command to turn shuffle on or off
    function onShuffle() {
    }
    
    function onCustomButton(button) {
    }
    
    function timerCallback() {
    	currentTime+=timeInterval;
    	recordTime(false);
	}
	
	function getBook() {
		var app = Application.getApp();
		var currentID = app.getProperty(Properties.CURRENT_BOOK);
		var books = app.getProperty(Properties.BOOKS);
		var book = books[currentID];
		return book;	
	}
	
	function recBook(book) {
		var app = Application.getApp();
		var currentID = app.getProperty(Properties.CURRENT_BOOK);
		var books = app.getProperty(Properties.BOOKS);
		books[currentID] = book;
		app.setProperty(Properties.BOOKS, books);
	}
	
	function recordTime(complete) {
		var book = getBook();
		var currentChapter = 0;
		var totalChapters = book["chapters"].size();
		for (var i = 0; i<totalChapters; ++i) {
			var chapter = book["chapters"][i];
			if (chapter == currentRef) {
				System.println("TO: Current Chapter is: " + i);
				currentChapter = i;
				break;
			}
		}
		if (!complete) {
			book["chapter"] = currentChapter;
			book["position"] = currentTime;
			System.println("TO: setting book co/po to " + book["chapter"] + " / " + book["position"]);
		}
		else {
			var nextChapter = currentChapter+1;
			if (nextChapter >= totalChapters) {
				book["chapter"] = currentChapter;
				book["position"] = currentTime-10;
				System.println("TO: setting book co/po to " + book["chapter"] + " / " + book["position"]);
			}
			else {
				book["chapter"] = currentChapter;
				book["position"] = currentTime;
				System.println("TO: setting book co/po to " + book["chapter"] + " / " + book["position"]);			
			}
		}
		recBook(book);	
		
	}

    // Handles a notification from the system that an event has
    // been triggered for the given song
    function onSong(contentRefId, songEvent, playbackPosition) {
    	var book = getBook();
    	currentRef = contentRefId;
    	if (currentTime == null) {
    		currentTime = book["position"];
    	}
    	System.println("Event! " + songEvent + " " + playbackPosition + " -- " + currentTime);
    	switch (songEvent) {
    		case Media.SONG_EVENT_START:
    			if (playbackPosition >= 300) {
    				currentTime = book["position"];
    				System.println("time set to: " + currentTime);    				
    			}
    			else {
    				currentTime = playbackPosition;
    			}
    			System.println("Timer starting");
    			trackTimer.start(method(:timerCallback), timeInterval*1000, true);    			
    			break;
    		case Media.SONG_EVENT_RESUME:
    			System.println("Timer starting");
    			trackTimer.start(method(:timerCallback), timeInterval*1000, true);  			
    			break;
    		case Media.SONG_EVENT_COMPLETE:
    			System.println("Audio Complete");
    			trackTimer.stop();
    			currentTime = playbackPosition;
    			recordTime(true);
    			break;		
    		case Media.SONG_EVENT_STOP:
    		case Media.SONG_EVENT_PAUSE:
    			System.println("Timer stopping");
    			trackTimer.stop();
    			recordTime(false);
    			break;
    	}
    }
}
