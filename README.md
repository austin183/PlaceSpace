# PlaceSpace
A space to explore and share r/place, for macOs in Swift
 and supporting tools
 
More information can be found on https://github.com/austin183/PlaceSpace/wiki/PlaceSpace-Home

This app is a picture viewer specifically designed to show large quantities of PNG files as a slideshow or by dragging along timeline to see each picture individually.  It works really well with the png files from

https://archive.org/details/PLACE-SNAPSHOTS

related to https://old.reddit.com/r/place

It also has a Save Portion as MP4 feature that lets you take two points from the timeline, add some optional cropping points, and generate an animated gif of that cropped section of the source pictures.  It recommends a cap at 200 frames by skipping a predetermined number of frames to keep the system from freezing up for too long a period of time.  The fewer skipped frames, the more memory and processing time will be required, but their will be a progress indicator to let you know stuff is happening.

Cropper coordinates work from starting from the top left.  The width determines how far to the right the cropper will go, and the height determines how far down it will go.  Scale determines how to resize the image for the final gif.  So if you had a 100 x 100 image and a scale of 2, the final mp4 would be 200 x 200.  Alternatively, a 100 x 100 image scaled to .5 would be 50 x 50.

The Viewer will show you the dimensions for the image current displayed in the window and will transfer the current dimensions to the save window so you don't have to type them all in again.

One day all this info will live in a help file accessible from the app directly.  And there will be cake!
