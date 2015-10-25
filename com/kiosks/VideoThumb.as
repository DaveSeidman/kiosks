package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
//	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	
	public class VideoThumb extends MovieClip {

		private var flvPlayback;
		private var cover:MovieClip;
		private var thumbWidth;
		private var thumbHeight;
		public var source;

		public function VideoThumb(_path:String, _thumbWidth, _thumbHeight) {

			Tracer("VideoThumb.constructor " + _path);
			
			this.mouseChildren = false;

			source = _path;
			thumbWidth = _thumbWidth;
			thumbHeight = _thumbHeight;

			flvPlayback = new FLVPlayback();
			flvPlayback.source = source;
			flvPlayback.addEventListener(VideoEvent.READY, videoReady);
			flvPlayback.volume = 0;
			flvPlayback.width = thumbWidth;
			flvPlayback.height = thumbHeight;
			addChild(flvPlayback);

			cover = new MovieClip();
			/*cover.graphics.beginFill(0x000000, 0);
			cover.graphics.drawRect(0,0, 400, 300);
			cover.graphics.endFill();*/
			cover.width = thumbWidth;
			cover.height = thumbHeight;
			
			
			addChild(cover);

		}
		
		private function videoReady(e:VideoEvent):void {

			Tracer("VideoThumb.videoReady");

			flvPlayback.volume = 0;
			flvPlayback.stop();
			flvPlayback.addEventListener(VideoEvent.COMPLETE, videoComplete);
			//flvPlayback.stop();
		}
		private function videoComplete(e:VideoEvent):void {

			Tracer("VideoThumb.videoComplete");

			flvPlayback.seek(0);
			flvPlayback.play();
		}
		public function playVideo():void {

			Tracer("VideoThumb.playVideo");

			flvPlayback.seek(1);
			flvPlayback.play();
		}
		public function stopVideo():void {

			Tracer("VideoThumb.stopVideo");

			flvPlayback.seek(0);
			flvPlayback.stop();
		}
	}
}