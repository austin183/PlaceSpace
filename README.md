# PlaceSpace
A space to explore r/place, for macOs in Swift

This app is a picture viewer specifically designed to show large quantities of PNG files as a slideshow or by dragging along timeline to see each picture individually.  It works really well with the png files from

https://archive.org/details/PLACE-SNAPSHOTS

related to https://old.reddit.com/r/place

It also has a Save Portion as GIF feature that lets you take two points from the timeline, add some optional cropping points, and generate an animated gif of that cropped section of the source pictures.  It caps at 100 frames by skipping a predetermined number of frames to keep the system from freezing up for too long a period of time.  I haven't been able to get live progress of the save to work yet.  I tried the delegate method like the slideshow delegate patter to break up the process to increment the image index and add each one to the gif destination, but the gif destination object could not find the destination file the second time through the timer.

Cropper coordinates work from starting from the top left.  The width determines how far to the right the cropper will go, and the height determines how far down it will go.

One day all this info will live in a help file accessible from the app directly.  And there will be cake!