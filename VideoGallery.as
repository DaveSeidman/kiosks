// Kiosk VideoGallery Class
// Consists of a video list (ScrollList componenet)
// and a video player (VideoPlayer component)

package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.Sprite;
	import fl.video.FLVPlayback;
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.errors.IOError;

	import com.greensock.TweenLite;
	import com.greensock.easing.*;

	import com.kiosks.ScrollList;
	import com.kiosks.VideoThumb;
	import com.kiosks.VideoPlayer;

	public class VideoGallery extends MovieClip {
		
		private var fileArray;; // DS: don't init these here

		private var stageWidth;
		private var stageHeight;
		
		private var contentLoader = new Loader;
		private var index:uint = 0;		// multiuse?
		private var path;

		private var videoList;
		private var videoScrollList;

		private var videoPlayer;

		private var backgroundLoader;
		private var background;

		public var dontTimeout:Boolean = false;

		public function VideoGallery(_path:String, _stageWidth:uint = 1920, _stageHeight:uint = 1080, _background = "Content/Showering/backdrop.jpg") {

			//Tracer("VideoGallery.constructor " + _path);
			//Tracer.doTrace("testing123");
			trace(Tracer);
			stageWidth = _stageWidth;
			stageHeight = _stageHeight;
			path = _path;


			backgroundLoader = new Loader();
			backgroundLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, backgroundLoaded);
			backgroundLoader.load(new URLRequest(_background));
			background = new Sprite();
			addChild(background);
			//var backing = new Sprite();
			//backing.graphics.beginFill(0x000000, 1);
			//backing.graphics.drawRect(0,0,stageWidth,stageHeight);
			//backing.graphics.endFill();
			//addChild(backing);

			var dir:File = File.applicationDirectory.resolvePath("Content/" + path);
			fileArray = new Array();
			fileArray = dir.getDirectoryListing();		// DS: add check for filetype and match flv or mp4
			
			videoList = new Sprite();
			for(var i:uint = 0; i < fileArray.length; i++) {
				
				Tracer("VideoGallery.loading --> " + fileArray[i].name);
				var filename = fileArray[i].name;
				
				if(filename.substring(filename.length - 3, filename.length).toLowerCase() == "flv") {
					var videoThumb = new VideoThumb("Content" + "/" + _path + "/" + filename, 355.33, 200);
					videoThumb.y = videoList.height;
					videoThumb.addEventListener(MouseEvent.CLICK, thumbClicked);
					videoList.addChild(videoThumb);
				}
			}
			

			videoScrollList = new ScrollList(videoList, false, true, 355.33, 600, false, false);
			videoScrollList.x = 50;
			videoScrollList.y = 100;

			addChild(videoScrollList);

			videoPlayer = new VideoPlayer(null, 1066, 600, true);
			videoPlayer.x = 480;
			videoPlayer.y = 100;
			videoPlayer.addEventListener("hideMenu", hideMenuCalled);
			videoPlayer.addEventListener("showMenu", showMenuCalled);
			videoPlayer.addEventListener("play", playClicked);
			videoPlayer.addEventListener("pause", pauseClicked);
			addChild(videoPlayer);

		}


		private function playClicked(e:Event):void {

			Tracer("VideoGallery.playClicked");

			dontTimeout = true;
		}

		private function pauseClicked(e:Event):void {

			Tracer("VideoGallery.pauseClicked");

			dontTimeout = false;
		}
		private function hideMenuCalled(e:Event):void {

			Tracer("VideoGallery.hideMenuCalled");
			Tracer("learning is trying to hide menu, but it doesn't need to");

			e.preventDefault();
			e.stopImmediatePropagation();
			dontTimeout = true;
		}

		private function showMenuCalled(e:Event):void {

			Tracer("VideoGallery.showMenuCalled");

			e.preventDefault();
			e.stopImmediatePropagation();
			dontTimeout = false;
		}


		private function backgroundLoaded(e:Event):void {

			Tracer("VideoGallery.backgroundLoaded");

			background.addChild(backgroundLoader.content);
		}

		private function thumbClicked(e:MouseEvent):void {

			Tracer("VideoGallery.thumbClicked");

			if(!videoScrollList.moved) {
				//trace("play video", e.target);
				//trace(e.target.source);
				videoPlayer.open(e.target.source);
				dontTimeout = true;
			}
		}

		public function open():void {

			Tracer("VideoGallery.open");

			for(var i = 0; i < videoList.numChildren; i++) {

				var videoThumb = videoList.getChildAt(i);
				videoThumb.playVideo();
			}
			videoScrollList.reset();
			//videoPlayer.load("");
			//videoPlayer.reset();
		}
		public function close():void {

			Tracer("VideoGallery.close");
			
			for(var i = 0; i < videoList.numChildren; i++) {

				var videoThumb = videoList.getChildAt(i);
				videoThumb.stopVideo();
			}
			videoPlayer.close();
		}
	}
}
