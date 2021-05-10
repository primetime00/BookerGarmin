using Toybox.Media;
using Toybox.System;
using Toybox.Application;
using Toybox.Application.Storage;

class BookerContentIterator extends Media.ContentIterator {

	var mCurrentBook;
	var mChapters;

    function initialize() {
        ContentIterator.initialize();
        initBook();
    }
    
    function initBook() {   
    	var app = Application.getApp();
    	var current = app.getProperty(Properties.CURRENT_BOOK);
    	var books = app.getProperty(Properties.BOOKS);
    	/*
    	System.println("All books:");
    	System.println(books);
    	
    	System.println("Partial books:");
    	var pbooks = app.getProperty(Properties.PARTIAL_BOOKS);
    	System.println(pbooks);*/
    	
    	if (current == null) {
    		mCurrentBook = null;
    		mChapters = null;
    		return;
    	}
    	mCurrentBook = books[current];
    	mChapters = mCurrentBook["chapters"];   	
    }

    // Determine if the the current track can be skipped.
    function canSkip() {
        return true;
    }

    // Get the current media content object.
    function get() {
    	
    	if (mChapters == null) {
    		return null;
    	}
    	var currentChapter = mChapters[mCurrentBook["chapter"]];
    	System.println("Chapter is: " + mCurrentBook["chapter"]);
    	var ref = new Media.ContentRef(currentChapter, Media.CONTENT_TYPE_AUDIO);
    	var audio = Media.getCachedContentObj(ref);
    	var pos = mCurrentBook["position"];   
    	//pos is off by about 10 seconds when req 1130
    	//req 1130, but got 1120 	    	
    	//req 300, but got 299
    	//req 900, got 892
    	// req 600, but got 595
    	if (pos >= 300) {
    		var v = (1.01*pos)-0.729;
    		if (v < 0) {
    			v = 0;
    		}
    		pos = v.toNumber();
    	}
    	return new Media.ActiveContent(ref, audio.getMetadata(), pos);
    }

    // Get the current media content playback profile
    function getPlaybackProfile() {
        var profile = new Media.PlaybackProfile();

        profile.playbackControls = [
        ];

        //profile.playSpeedMultipliers = [Media.PLAYBACK_SPEED_NORMAL];
        profile.attemptSkipAfterThumbsDown = false;
        profile.supportsPlaylistPreview = false;
        profile.requirePlaybackNotification = true;
        profile.skipPreviousThreshold = 0;
        profile.playbackNotificationThreshold = 1;
        return profile;
    }

    // Get the next media content object.
    function next() {
    	var currentChapterNumber = mCurrentBook["chapter"] + 1;
    	System.println("Loading next chapter:" + currentChapterNumber);
    	var totalChapters = mCurrentBook["chapters"].size();
    	if (currentChapterNumber < totalChapters) {
    		var currentChapter = mChapters[currentChapterNumber];
    		//mCurrentBook["chapter"] += 1;
    		//mCurrentBook["position"] = 0;
    		return Media.getCachedContentObj(new Media.ContentRef(currentChapter, Media.CONTENT_TYPE_AUDIO));
    	}    	
        return null;
    }

    // Get the next media content object without incrementing the iterator.
    function peekNext() {
    	if (mCurrentBook == null || !mCurrentBook.hasKey("chapter")) {
    		return null;
    	}    
    	var currentChapterNumber = mCurrentBook["chapter"] + 1;
    	var totalChapters = mCurrentBook["chapters"].size();
    	if (currentChapterNumber < totalChapters) {
    		var currentChapter = mChapters[currentChapterNumber];
    		return Media.getCachedContentObj(new Media.ContentRef(currentChapter, Media.CONTENT_TYPE_AUDIO));
    	}    	
        return null;

    }

    // Get the previous media content object without decrementing the iterator.
    function peekPrevious() {
    	if (mCurrentBook == null || !mCurrentBook.hasKey("chapter")) {
    		return null;
    	}
    	var currentChapterNumber = mCurrentBook["chapter"] - 1;
    	if (currentChapterNumber > 0) {
    		var currentChapter = mChapters[currentChapterNumber];
    		return Media.getCachedContentObj(new Media.ContentRef(currentChapter, Media.CONTENT_TYPE_AUDIO));
    	}    
    	return null; 	
    }

    // Get the previous media content object.
    function previous() {
    	var currentChapterNumber = mCurrentBook["chapter"] - 1;
    	if (currentChapterNumber > 0) {
    		var currentChapter = mChapters[currentChapterNumber];
    		//mCurrentBook["chapter"] -= 1;
    		//mCurrentBook["position"] = 0;    		
    		return Media.getCachedContentObj(new Media.ContentRef(currentChapter, Media.CONTENT_TYPE_AUDIO));
    	}
    	return null; 	
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() {
        return false;
    }

}
