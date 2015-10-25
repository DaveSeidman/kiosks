package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	
	
	public class VideoControls extends MovieClip {
		
		public var video:FLVPlayback;

		private var currentTime:VideoControlsTimecode;
		private var totalTime:VideoControlsTimecode;
		private var playPauseBtn:VideoControlsPlayPauseBtn;
		private var volumeBtn:VideoControlsVolumeBtn;
		private var playerBar:VideoControlsPlayerBar;

		
		public function VideoControls(video:FLVPlayback) {

			dispatchEvent(new DataEvent("trace", true, false, "VideoControls.constructor " + video));
			
			this.video = video;
			playPauseBtn.addEventListener(MouseEvent.CLICK, playPauseClicked);
			volumeBtn.addEventListener(MouseEvent.CLICK, adjustVolume);
			//video.addEventListener(MouseEvent.CLICK, playPauseClicked);
			playerBar.seekBar.addEventListener(MouseEvent.CLICK, seekVideo);
			//playerBar.seekBar.addEventListener(MouseEvent.MOUSE_DOWN, startScrub);
			//addEventListener(MouseEvent.MOUSE_UP, stopScrub);

			volumeBtn.volumeIcon.gotoAndStop(4);
			
			playPauseBtn.pauseIcon.visible = true;
			playPauseBtn.playIcon.visible = false;
			playerBar.progress.x = playerBar.seekBar.x;
			//playerBar.totalTime.text = numToTime(video.totalTime);


			addChild(currentTime);
			addChild(totalTime);
			addChild(playPauseBtn);
			addChild(volumeBtn);
			addChild(playerBar);

			video.addEventListener(Event.ENTER_FRAME, updatePlayhead);
			
			//this.alpha = 0;
		}
		
		public function setTotalTime(total:Number):void {

			dispatchEvent(new DataEvent("trace", true, false, "VideoControls.setTotalTime " + total));
			
			totalTime.time.text = numToTime(total);
		}
		public function setCurrentTime(current:Number):void {

			currentTime.time.text = numToTime(current);
		}
		
		public function playPauseClicked(e:MouseEvent = null):void {

			dispatchEvent(new DataEvent("trace", true, false, "VideoControls.playPauseClicked"));
			if(!video.playing) playVideo();
			else pauseVideo();
		}
		public function playVideo():void {

			dispatchEvent(new DataEvent("trace", true, false, "VideoControls.playVideo"));
			
			if(video.source != "Content/null") {
				video.play();
				video.addEventListener(Event.ENTER_FRAME, updatePlayhead);
				dispatchEvent(new Event("play", true));
				playPauseBtn.pauseIcon.visible = true;
				playPauseBtn.playIcon.visible = false;
			}
		}
		public function pauseVideo():void {

			dispatchEvent(new DataEvent("trace", true, false, "VideoControls.pauseVideo"));
			video.pause();
			dispatchEvent(new Event("pause", true));
			playPauseBtn.pauseIcon.visible = false;
			playPauseBtn.playIcon.visible = true;
			video.removeEventListener(Event.ENTER_FRAME, updatePlayhead);
		}

		public function updatePlayhead(e:Event = null):void {
			
			currentTime.time.text = numToTime(video.playheadTime);
			playerBar.progress.x = playerBar.seekBar.x + playerBar.seekBar.width * (video.playheadPercentage/100);
			
			// prevent timeout from closing overlay while video is playing
			//if(video.playheadTime > video.totalTime - .2) trace("close video player here"); //playPauseClicked();
			//else dispatchEvent(new Event("resetTimeout", true));
		}
		
		private function seekVideo(e:MouseEvent):void {

			dispatchEvent(new DataEvent("trace", true, false, "VideoControls.seekVideo"));
			
			//trace(playerBar.seekBar.mouseX * playerBar.seekBar.scaleX, playerBar.seekBar.width);
			trace(playerBar.seekBar.mouseX, video.totalTime);
		//	trace("------ - - - - - ----------", video.source);
			//if(video.source != "Content/null") video.seekPercent(playerBar.seekBar.mouseX);
			if(video.totalTime) video.seekPercent(playerBar.seekBar.mouseX);
			//video.play();
		}
		
		/*private function startScrub(e:MouseEvent):void {

			addEventListener(MouseEvent.MOUSE_MOVE, scrubVideo);
		}*/

		//private function scrubVideo(e:MouseEvent):void {

			//trace("scrubbing video", (playerBar.seekBar.mouseX / playerBar.seekBar.width) * 100);
		//	video.pause();
			//video.seekPercent((playerBar.seekBar.mouseX / playerBar.seekBar.width) * 100);
			
		//}

		/*private function stopScrub(e:MouseEvent):void {

			removeEventListener(MouseEvent.MOUSE_MOVE, scrubVideo)
			video.play();
		}*/


		private function adjustVolume(e:MouseEvent):void {
			
			dispatchEvent(new DataEvent("trace", true, false, "VideoControls.ajustVolume"+ video.volume));
			if(video.volume == 1) video.volume = 0;
			video.volume += .25;
			
			volumeBtn.volumeIcon.gotoAndStop(video.volume * 4);
		}
		
		private function numToTime(num:Number):String {
			
			var minutes = Math.floor(num/60);
			var seconds = int((num%60).toString().substr(0,2)) + 0;
			if(seconds < 10) seconds = "0" + seconds;
			return minutes + ":" + seconds;
		}
	}
	
}
