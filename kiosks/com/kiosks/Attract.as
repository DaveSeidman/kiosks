// to do:
// don't load images each time they cycle, load once then store them in an array

package com.kiosks {
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	import flash.errors.IOError;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	/*import flash.text.TextFormat;*/
	
	public class Attract extends Sprite {

		// don't call "new" here, should happen in the constructor...
		private var imageArray;
		private var images;
		
		private var index:uint = 0;
		private var imageLoader = new Loader;
		private var path;
		
		private var stageWidth;
		private var stageHeight;
		private var direction;

		private var pausing:Boolean = false;
		
		public function Attract(_path:String, _stageWidth:uint = 1920, _stageHeight:uint = 1080, _direction:String = "left") {

			stageWidth = _stageWidth;
			stageHeight = _stageHeight;
			direction = _direction;
			path = _path;

			images = new Sprite;
			imageArray = [];

			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, addImage);
			imageLoader.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			
			var dir:File = File.applicationDirectory.resolvePath("Content/" + path);
			imageArray = dir.getDirectoryListing();
			
			dispatchEvent(new DataEvent("trace", true, false, "Loading Background Images:"));
			for(var i:uint = 0; i < imageArray.length; i++) {
				
				dispatchEvent(new DataEvent("trace", true, false, "-->"+imageArray[i].name));
			}
			
			addChild(images);

			var tempImage = new Sprite();
			images.addChild(tempImage);
			
			if(imageArray.length) imageLoader.load(new URLRequest("Content/" + path + "/" + imageArray[index].name));
			else dispatchEvent(new DataEvent("trace", true, false, "<b>No images found in the 'Image' path, please add</b>"));
			
		}


		public function hold():void {

			trace("pausing attract");
			pausing = true;
		}

		public function release():void {

			trace("releasing attract");
			pausing = false;
			//nextImage();
			images.getChildAt(1).x = 0;
			panImage(); // DS: might need to reset images position before this.
		}

		private function addImage(e:Event):void {
			
			//imageLoader.content.y = 0;
			imageLoader.content.x = stageWidth;
			images.addChild(imageLoader.content);
			
		
			TweenLite.to(images.getChildAt(0), .5, { x:-stageWidth, ease:Expo.easeInOut });
			TweenLite.to(images.getChildAt(1), .5, { x:0, ease:Expo.easeInOut, onComplete:panImage });
		}
		
		private function panImage() {
			
			TweenLite.to(images.getChildAt(1), 8, { x:-100, ease:Linear.easeNone, onComplete:nextImage });
		}
		
		private function nextImage():void {
			
			if(!pausing) {
				images.removeChildAt(0);
				index++;
				if(index == imageArray.length) index = 0;
				imageLoader.load(new URLRequest("Content/" + path + "/" + imageArray[index].name));
			}
			
		}
		
		private function loadError(e:IOErrorEvent):void {
			
			dispatchEvent(new DataEvent("trace", true, false, "image load error"));
		}
				
	}
}