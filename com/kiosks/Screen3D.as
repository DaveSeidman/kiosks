package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.media.SoundTransform;
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.AutoAlphaPlugin; 

	
	public class Screen3D extends MovieClip {

		public var animations;					// if there are any animations on the screen they will be triggered when it becomes the current screen and finishes tweening into position
		public var background;					// a background video
		public var layers;						// parallax layers, move faster or slower than their parent containers based on ratio defined inside object
		public var video;						// a video popup (fullscreen)
		public var videoPopup;					// a video popup (fullscreen)
		private var volumeTransform;			// used for fading volume up and down on video popup
		
		public function Screen3D() {

			//background = undefined;

			dispatchEvent(new DataEvent("trace", true, false, "Screen3D.constructor"));
			TweenPlugin.activate([AutoAlphaPlugin]);					// Activates the autoalpha plugin which tweens an object to or from hidden and automatically changes it's display between visible and invisible

			if(videoPopup) {

				volumeTransform = new SoundTransform(1);
				TweenLite.to(videoPopup, 0, { autoAlpha:0 });
				//videoPopup.stop();
				videoPopup.gotoAndStop(0);
				videoPopup.soundTransform = volumeTransform;
				//videoBtn.addEventListener(MouseEvent.CLICK, openVideo);
				videoPopup.returnBtn.addEventListener(MouseEvent.CLICK, closeVideo);
			}
		}

		private function openVideo(e:MouseEvent = null):void {

			dispatchEvent(new DataEvent("trace", true, false, "Screen3D.opening video"));
			
			TweenLite.to(videoPopup, .5, { autoAlpha:1 });
		//	st.volume = 1;
			videoPopup.soundTransform = volumeTransform;
			videoPopup.play();
			dispatchEvent(new Event("hideMenu", true));
			dispatchEvent(new Event("lockSlider", true));

			addEventListener(Event.ENTER_FRAME, videoPlaying);
		}
		public function closeVideo(e:MouseEvent = null):void {

			dispatchEvent(new DataEvent("trace", true, false, "Screen3D.closeVideo"));
			TweenLite.to(videoPopup, .5, { autoAlpha:0, onUpdate:fadeVolume, onComplete:function() { videoPopup.gotoAndStop(1); } });
			dispatchEvent(new Event("showMenu", true));
			dispatchEvent(new Event("freeSlider", true));

			removeEventListener(Event.ENTER_FRAME, videoPlaying);
		}
		private function fadeVolume():void {
		//	st.volume = videoPopup.alpha;
			videoPopup.soundTransform = volumeTransform;
		}

		private function videoPlaying(e:Event):void {

			if(videoPopup.currentFrame >= videoPopup.totalFrames)  closeVideo();
		}

		public function animate():void {
			dispatchEvent(new DataEvent("trace", true, false, "Screen3D.animate"));
			for(var i:uint = 0; i < animations.length; i++) {
				var animation = animations[i];
				animation.gotoAndPlay(2);
			}
		}
		
		public function playBackground():void {

			dispatchEvent(new DataEvent("trace", true, false, "Screen3D.playBackground"));
			background.play();
		}

		public function pauseBackground():void {

			dispatchEvent(new DataEvent("trace", true, false, "Screen3D.pauseBackground"));
			background.stop();
		}

		public function offset3DLayers(amount:Number):void {
			
			for(var i:uint = 0; i < layers.length; i++) {
				var layer = layers[i];
				layer["clip"].x = layer["position"] + (layer["ratio"] * amount);
			}

		}
	}
}
