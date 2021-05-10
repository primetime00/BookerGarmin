using Toybox.Communications;
using Toybox.System;
using Toybox.Application;

// Delegate injects a context argument into web request response callback
class RequestDelegate
{
    hidden var mBookDoneCallback; // function always takes 3 arguments
    hidden var mChapterDoneCallback; // function always takes 3 arguments
    hidden var mContext;  // this is the 3rd argument
    hidden var mChapterIds;
    hidden var mApp;
    hidden var mPartialBooks;
    hidden var mFilesToDownload;
    hidden var mIndex;

    function initialize(bookDoneCB, chapterDoneCB, context) {
        mBookDoneCallback = bookDoneCB;
        mChapterDoneCallback = chapterDoneCB;
        mContext = context;
        mApp = Application.getApp();
        mPartialBooks = mApp.getProperty(Properties.PARTIAL_BOOKS);
    } 
    
    function getFilesToDownload(crc) {
    	mPartialBooks = mApp.getProperty(Properties.PARTIAL_BOOKS);
    	if (mPartialBooks == null) {
    		mPartialBooks = {};
		}
    	if (!mPartialBooks.hasKey(crc)) {
    		mPartialBooks[crc] = [];
    		for (var i=0; i<mContext["book"]["chapters"].size(); ++i) {
    			mPartialBooks[crc].add([i, null]);    			
    		}
    		mApp.setProperty(Properties.PARTIAL_BOOKS, mPartialBooks);    	
    	}
    	return mPartialBooks[crc];    	
    }
   
    function downloadBook(url) {
    	var crc = mContext["book"]["crc"];
    	mFilesToDownload = getFilesToDownload(crc);    	
    	mIndex = 0;
    	mChapterIds = [];
    	for (var i=0; i<mFilesToDownload.size(); ++i) {
    		if (mFilesToDownload[i][1] == null) {
    			mIndex = i;    			
    			break;
    		}
    		else {
    			mChapterIds.add(mFilesToDownload[i][1]);
	    		if (mChapterDoneCallback != null) {
	    			mChapterDoneCallback.invoke(mContext, i);
	    		}
    		}    		
    	}
    	downloadChapter(url);
    }
    
    function downloadChapter(url) {
    	var chapter = mContext["chapter"];
    	var book = mContext["book"];
    	if (mIndex >= mFilesToDownload.size()) {
    		return false;
    	}
    	var url2 = mContext["url"] + '/' + mFilesToDownload[mIndex][0];
    	
    	
        var options = {:method => Communications.HTTP_REQUEST_METHOD_GET,
                       :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
                       :mediaEncoding => typeStringToEncoding(book["type"])};
        Communications.makeWebRequest(url2, null, options, self.method(:chapterDownloaded));
        return true;
    }
    
    function chapterDownloaded(code, data) {
    	if (code == 200) {
    		mFilesToDownload[mIndex][1] = data.getId();
    		mApp.setProperty(Properties.PARTIAL_BOOKS, mPartialBooks);
    		mChapterIds.add(data.getId());
    		if (mChapterDoneCallback != null) {
    			mChapterDoneCallback.invoke(mContext, mIndex);
    		}
    		mIndex++;
    		if (mIndex >= mFilesToDownload.size()) {
	    		//book is complete, let's remove the partials
	    		var crc = mContext["book"]["crc"];
	    		mPartialBooks = mApp.getProperty(Properties.PARTIAL_BOOKS);
	    		if (mPartialBooks.hasKey(crc)) {
	    			mPartialBooks.remove(crc);
	    			mApp.setProperty(Properties.PARTIAL_BOOKS, mPartialBooks);
    			}
				mBookDoneCallback.invoke(code, mContext, mChapterIds);
				return;    			    		
    		}
    		var url = mContext["url"] + '/' + mFilesToDownload[mIndex][0];
	    	var status = downloadChapter(url);
    	}
    }
    

    
    function typeStringToEncoding(type) {
        var encoding = Media.ENCODING_INVALID;

        if (type.equals("mp3")) {
                encoding = Media.ENCODING_MP3;
        } else if (type.equals("m4a")) {
                encoding = Media.ENCODING_M4A;
        } else if (type.equals("wav")) {
                encoding = Media.ENCODING_WAV;
        } else if (type.equals("adts")) {
                encoding = Media.ENCODING_ADTS;
        }

        return encoding;
    }    
    
}
