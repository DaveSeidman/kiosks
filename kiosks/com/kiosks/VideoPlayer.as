package com.kiosks {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
		
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.AutoAlphaPlugin; 	
	import com.kiosks.Tracer;
	import com.kiosks.VideoControls;

	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	import flash.text.TextFormat;
	
	public class VideoPlayer extends MovieClip {

		private var path;
		
		public var controls;
		private var controlTimer;
		private var video;
		private var currentTime;
		private var videoWidth;
		private var videoHeight;
		private var smoothing;

		private var videoCover;
		public var dontTimeout:Boolean = false;
		
		public function VideoPlayer(_path:String = null, _videoWidth = 1280, _videoHeight = 720, smoothing = false) {
			
			Tracer("VideoPlayer.constructor " + path);
			TweenPlugin.activate([AutoAlphaPlugin]);
			path = _path;
			videoWidth = _videoWidth;
			videoHeight = _videoHeight;

			video = new FLVPlayback;

			addChild(video);
			video.autoPlay = false;
			video.width = videoWidth;
			video.height = videoHeight;
			
			video.source = "Content/" + path;
			var innerVidPlayer = video.getVideoPlayer(0);
			innerVidPlayer.smoothing = smoothing;
			video.addEventListener(VideoEvent.READY, videoReady);
			video.addEventListener(VideoEvent.COMPLETE, videoComplete);
		
			addChild(video);
			
			videoCover = new MovieClip();
			videoCover.graphics.beginFill(0x000000, 0);
			videoCover.graphics.drawRect(0,0,videoWidth,videoHeight);
			videoCover.graphics.endFill();
			videoCover.addEventListener(MouseEvent.CLICK, videoClicked);
			addChild(videoCover);

			controls = new VideoControls(video);
			controls.x = 0;
			controls.y = videoHeight;
			controls.maxTime.x = videoWidth;
			controls.volumeBtn.x = videoWidth;
			controls.playerBar.seekBar.width = videoWidth - 200;
			controls.addEventListener(MouseEvent.CLICK, videoClicked);
			controls.addEventListener("play", function() { dontTimeout = true; });
			controls.addEventListener("pause", function() { dontTimeout = false; });
			addChild(controls);

			controlTimer = new Timer(3000, 1);
			controlTimer.addEventListener(TimerEvent.TIMER, hideControls);
			controlTimer.start();
			
		}
		
		private function videoReady(e:VideoEvent):void {
			
			Tracer("VideoPlayer.videoReady");
			controls.setTotalTime(video.totalTime);
		}

		private function videoComplete(e:VideoEvent):void {

			Tracer("VideoPlayer.videoComplete");
			//dispatchEvent(new Event("closeMe", true));
			dispatchEvent(new Event("showMenu", true));
			dontTimeout = false;
		}
		private function videoClicked(e:MouseEvent):void {

			Tracer("VideoPlayer.videoClicked");

			showControls();
			controlTimer.reset();
			controlTimer.start();
			
			if(e.currentTarget != "[object VideoControls]") controls.playPauseClicked();
		}

		private function showControls():void {

			Tracer("VideoPlayer.showControls");
			TweenLite.to(controls, .5, { alpha:1 });
		}
		private function hideControls(e:TimerEvent):void {

			Tracer("VideoPlayer.hideControls");
			TweenLite.to(controls, .5, { alpha:.3 });
		}

		public function open(source:String = null):void {
			
			Tracer("VideoPlayer.open");
			if(source) video.source = source;
			else video.seek(0);
			video.visible = true;
			video.volume = 1;
			controls.setTotalTime(video.totalTime);
			controls.playVideo();
			dispatchEvent(new Event("hideMenu", true));
		}
		
		public function close():void {

			Tracer("VideoPlayer.close"); 
			// DS: open uses controls to play video but it's handled here in line, should we push to controls.as?
			//controls.pauseVideo();
			video.visible = false;
			video.volume = 0;
			if(video.source != "Content/null") {
				video.seek(0);
				video.stop();
			}
			controls.setTotalTime(0);
			controls.setCurrentTime(0);
			controls.updatePlayhead();
		}
	}
}
