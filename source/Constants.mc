// Keys for the object store
module Properties {
    enum {
        SYNC_LIST,
        DELETE_LIST,
        PLAYLIST,
        BOOKS,
        APP_VERSION,
        CURRENT_BOOK,
        CONFIG,
        PARTIAL_BOOKS        
    }
}

// Versions of the app. If a value is added to the enum then
// current should also be updated to the latest version. This
// will trigger an object store wipe.
module Versions {
    enum {
        V1 = 0,
    }

    const current = V1;
}

// Keys for the object store entry of Properties.SONGS
module SongInfo {
    enum {
        URL,
        CAN_SKIP,
        ID,
        TYPE
    }
}

// General constants used in the app
module Constants {
	const DEFAULT_URL = "http://192.168.1.228:8080";
    const LIST_URL = "/list";
    const BOOK_URL = "/book";
    const PROGRESS_URL = "/progress";
}