# ActionScript3 PreLoader Class with queue

We have been using the PreLoader class as a Loader replacement for years now to load asset content (swfs and images). The PreLoader has an integrated loader queue which allows one loading process at a time. It also has some convenient features like smoothing images when scaling them down.

*The PreLoader class is not a visual preloader!* You as a developer still have to do the dirty work like listening for progress and complete events and react to them. However, you can concentrate on that work without all the (from our point) useless overhead like contentLoaderInfo and URLRequest.

## Example implementation:

``` actionscript
var img:PreLoader = new PreLoader();
img.addEventListener(ProgressEvent.PROGRESS, _onImgProgress);
img.addEventListener(Event.COMPLETE, _onImgLoaded);
img.load("image1.jpg");
addChild(img);

function _onImgProgress(event : ProgressEvent)
{
  var perc:Number = event.bytesLoaded / event.bytesTotal;
  trace(perc);
}

function _onImgLoaded(event : Event)
{
  trace("image loaded");
}
```

## Difference to Loader

Implementation differences between PreLoader and Loader

```actionscript
// Loader
var ldr:Loader = new Loader();
ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
ldr.load(new URLRequest("img.jpg"));
addChild(ldr);

// PreLoader
var pldr:PreLoader = new PreLoader();
pldr.addEventListener(Event.COMPLETE, onLoaded);
pldr.load("img.jpg");
addChild(pldr);

function onLoaded(event : Event)
{
  trace("onLoaded");
}
```

## Example scenario

So you may ask: Why don't I have direct access to the queue (i.e. with indicies)? Because for a typical scenario it's not needed.

Example  
Lets assume you have a webpage where a lot of stuff needs to be preloaded. You want to make sure, that the bandwidth is always filled to have the stuff (swf and images) ready as soon as the user access a sub page.

So at the beginning you put everything to the queue:

```actionscript
// Pseudo code. This likely wont happen in on class / method.

var intro:PreLoader = new PreLoader();
intro.load("intro.swf");

var homeImage:PreLoader = new PreLoader();
homeImage.load("home_image.jpg");

var homeMovie:PreLoader = new PreLoader();
homeMovie.load("home_movie.swf");

var productImg1:PreLoader = new PreLoader();
productImg1.load("product_img1.jpg");

var productImg2:PreLoader = new PreLoader();
productImg2.load("product_img2.jpg");

var productImg3:PreLoader = new PreLoader();
productImg3.load("product_img3.jpg");

var productImg4:PreLoader = new PreLoader();
productImg4.load("product_img4.jpg");

var teamImg1:PreLoader = new PreLoader();
teamImg1.load("team_img1.jpg");

var teamImg2:PreLoader = new PreLoader();
teamImg2.load("team_img2.jpg");

var teamImg3:PreLoader = new PreLoader();
teamImg3.load("team_img3.jpg");

// now the queue looks like this:

// intro.swf, home_img.jpg, home_movie.swf, product_img1.jpg, product_img2.jpg, product_img3.jpg, product_img4.jpg, team_img1.jpg, team_img2.jpg, team_img3.jpg

// where intro.swf is currently loading
```

Now lets say the user clicks on "Team". You want to jump directly to the team sub page and load its content.

```actionscript
// shift team content to the beginning of the queue

teamImg1.loadImmediately(teamImg1.url);
teamImg2.loadAfter(teamImg2.url, teamImg1.url);
teamImg3.loadAfter(teamImg3.url, teamImg2.url);

// now the queue looks like this

// team_img1.jpg, team_img2.jpg, team_img3.jpg, intro.swf, home_img.jpg, home_movie.swf, product_img1.jpg, product_img2.jpg, product_img3.jpg, product_img4.jpg

// where team_img1.jpg is currently loading
```

Additionally you might want to remove the intro movie from the queue, since it wont be displayed anymore now (since the user skipped).

```actionscript
// remove intro movie from queue

intro.closeLoad();

// now the queue looks like this
// team_img1.jpg, team_img2.jpg, team_img3.jpg, home_img.jpg, home_movie.swf, product_img1.jpg, product_img2.jpg, product_img3.jpg, product_img4.jpg
```

## Code documentation

[API documentation](http://apdevblog.com/examples/apdev_preloader/docs/)

## What the PreLoader can do for you:  
 * Having a super easy loading queue that enables you to always fill the bandwidth of the user 
 * Change the queue during runtime by calling loadNext(), loadAfter() and loadImmediately()
 * Work with the PreLoader just like with the well known Loader - only with some small but time saving improvements

## What the PreLoader will not do for you:  
 * Group load requests (the PreLoader only has one pipe)
 * Displaying visual loading informations (the PreLoader fires the effect, you decide what to with them)
 * Loading data (PreLoader loads only swf's and images)

## Contribute
We have been working a lot with the PreLoader class. It can be called "well tested". However, if you find an issue or miss a feature, please let us know.
