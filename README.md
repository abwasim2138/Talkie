# Talkie



#About: 
 
 Talkie allows users to search for their favorite gifs and add their own voices to them! 
 
 
#USE: 
 
 SearchVC/1st Tab --
  After launching the app search for a gif (ex: minions) in the search bar provided via the first tab. 
 Given there are no network related issues, gifs should fill up the collection view. 
 You can tap the refresh button in the top right corner to get a batch of new gifs related to your search. 
 Choose the gif you want to record over, this will take you to an AVPlayer where you can preview the gif by pressing play. 
      •The last search is saved 
      
 TalkiePlayerVC/Modal --
 To record, SWIPE UP anywhere on the AVPlayer view (The background should turn gray in order to indicate a recording session).
 To cancel a recording just SWIPE DOWN or if you haven't recorded anything yet then Done works to. 
 If satisfied with the recording you can hit Done in the top left corner and the Talkie will be saved. 
 
 Talkie/2nd Tab
  The second tab will take you to your own collection of Talkies that you made. In order to play a Talkie just 
 tap on a cell in the table (the talkie is at a 0.7 alpha level if not tapped and 1.0 when it is).
 If you want to share a Talkie first tap on it and then hit the action button in the top right corner. 
 To delete a Talkie just swipe left on it and press delete. 
 •Talkies will only show if you recorded a Gif in the TalkiePlayerVC and hit Done to save it. 
 
 
 
 Settings/3rd Tab
      •Additional Auto-Save to photos library can be toggled in the settings tab. 
 
 
#Built:                            
•GiphyAPI(https://github.com/Giphy/GiphyAPI) used for GIF database.
•FLAnimatedImage(https://github.com/Flipboard/FLAnimatedImage) GIF engine used.
•Contains Pods (Run Pod Install)
•Use Talkie.xcworkspace and not .xcodeproj
