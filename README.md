# TweetTag

## How to use TweetTag

When you open the app, you are told that you are not following anything. Tap the "bookmarks" button in the top left corner. You are brought to the "Tags" page, where you can add, remove, and check/uncheck tags. Tap "+" in the top right corner to add a hashtag. Type in your tag and tap save. You can add as many tags as you'd like. Tags can be checked or unchecked by tapping, and they can be deleted by sliding left.

When you are finished, tap "Done" in the top left. All tweets with any of your checked off tags will be shown. You can use the button in the top right to sort. You can view recent tweets, popular tweets, or a mix of the two. Scroll up to refresh, and scroll all the way to the bottom to load more. Tap on a user's profile picture to open their Twitter profile page. Tap on any link to open it.


## How it works

The file BTKMasterViewController.m is where most of the work is done. When the view appears, it gets the hashtags that were selected on the Tags page, and then gets tweets for those hashtags with a GET request. Pull to refresh, loading of more tweets, and sorting are also implemented here.

The file BTKTagsViewController.m is where the work is done for the Tags page. When the + button is tapped, a new cell is created. When "Save" is tapped, it checks to see if the hashtag is valid, and if it is, it is saved using NSUserDefaults. This way the data is not lost when the app is closed. 

The file BTKWebViewController.m is handles the UIWebView that opens whenever a link of profile picture is tapped. Thanks to [Mark Sands's MSTextView](https://github.com/marksands/MSTextView) for the basis of this code. The webview allows going back, forward, refreshing, and opening links in Safari. Links are forced to open using BTKWebViewControllers in the BTKApplication.m file, which extends UIApplication. When a link is clicked, it calls openURL in BTKApplication which calls openURL in BTKAppDelegate. When a link is forced to open in Safari, openURLinSafari from BTKApplication is called instead.

## Availability

Search for TweetTag in the App Store!

## License

Copyright (c) <2012> <Brandon Krieger>