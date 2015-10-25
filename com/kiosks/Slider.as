package com.kiosks {
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
//	import flash.display.Graphics;
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.errors.IOError;

	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;

//	import flash.utils.getQualifiedClassName;
	
	public class Slider extends Sprite {
		
		private var fileArray = new Array(); // DS: don't init these here
		private var screenArray = new Array();
		private var screens = new Sprite();
		private var sliderWidth = 0; 			// using this instead of looking it up each time

		private var index:uint = 0;
		private var contentLoader = new Loader;
		private var path;
				
		private var stageWidth;
		private var stageHeight;
		private var wrap; // indicates whether slider should wrap or end after the last item

		private var dragOffset;  // calculated at mouse_down event
		private var dragPosition;  // current position based on mouse position - offset
		private var lastPosition; // previous position sampled while dragging to determine inertia
		private var landingPosition; // this is where the screen will end up after inertia is added
		private var dragSpeed;
		private var edgeAdjust;
		private var swipeThresh = 125; // DS: maybe make proportional to screen size?

		private var nextBtn;
		private var prevBtn;

		private var direction = "";
	//	private var oldIndex = 0;
		private var currentIndex = 0;
		private var currentScreen;
		
		public var dontTimeout = false;
		private var locked = false;

		private var checkSpeedInterval;

		public function Slider(_path:String, _stageWidth:uint = 1920, _stageHeight:uint = 1080, _wrap = true) {
			
			dispatchEvent(new DataEvent("trace", true, false, "Slider.constructer:" + _path));
			stageWidth = _stageWidth;
			stageHeight = _stageHeight;
			path = _path;
			
			wrap = _wrap;

			/*
			DS: we may still use this for the non-wrap version
			graphics.beginFill(0x000000, 1);
			graphics.drawRect(0, 0, stageWidth, stageHeight);
			graphics.endFill();
			*/
			contentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, addImage);
			contentLoader.addEventListener(IOErrorEvent.IO_ERROR, loadError);

			var dir:File = File.applicationDirectory.resolvePath("Content/" + path);
			fileArray = dir.getDirectoryListing();
			
			for(var i:uint = 0; i < fileArray.length; i++) {
				
				dispatchEvent(new DataEvent("trace", true, false, "Slider. loading screen --> " + fileArray[i].name));
			}
			
			addChild(screens);
			screens.addEventListener(MouseEvent.MOUSE_DOWN, startDragging); // don't allow dragging until all screens have finished loading			//wrapLastScreen();
			screens.addEventListener("lockSlider", lockSlider);  // DS: consider consolidating these functions
			screens.addEventListener("freeSlider", freeSlider);
			//screens.addEventListener("hideMenu", hideNextPrevButtons);
			//screens.addEventListener("showMenu", showNextPrevButtons);
			
			nextBtn = new NextBtn;
			prevBtn = new PrevBtn;
			nextBtn.x = stageWidth;
			prevBtn.x = 0;
			nextBtn.y = 400;
			prevBtn.y = 400;
			//nextBtn.label.visible = false;
			//prevBtn.label.visible = false;
			prevBtn.offset = 1;
			nextBtn.offset = -1;
			addChild(nextBtn);
			addChild(prevBtn);
			prevBtn.addEventListener(MouseEvent.CLICK, nextPrevClicked);
			nextBtn.addEventListener(MouseEvent.CLICK, nextPrevClicked);

			if(fileArray.length) contentLoader.load(new URLRequest("Content/" + path + "/" + fileArray[index].name));
			else dispatchEvent(new DataEvent("trace", true, false, "<b>No screens found in the 'Image' path, please add</b>"));
		}

		private function loadError(e:IOErrorEvent):void {
			
			dispatchEvent(new DataEvent("trace", true, false, "Slider.loadError" + e.text));
		}
		private function addImage(e:Event):void {

			dispatchEvent(new DataEvent("trace", true, false, "Slider.addImage " + contentLoader.content));
			contentLoader.content.x = stageWidth * screens.numChildren;
			screens.addChild(contentLoader.content);
			screenArray.push(contentLoader.content);
			sliderWidth = stageWidth * screens.numChildren;
			//boundsLo = stageWidth - sliderWidth;
			index++;
			if(index < fileArray.length) contentLoader.load(new URLRequest("Content/" + path + "/" + fileArray[index].name));
			//else reset();  // all screens loaded, setup feature
		}

		
		private function startDragging(e:MouseEvent):void {

			dispatchEvent(new DataEvent("trace", true, false,"Slider.startDragging"));
			
			if(!locked) {

				TweenLite.killTweensOf(screens);

				dragOffset = screens.mouseX;
				dragSpeed = 0;
				screens.addEventListener(MouseEvent.MOUSE_MOVE, drag);
				screens.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
				
				hideNextPrevButtons();

				//trace(currentScreen, currentScreen.background);
				if(currentScreen == "[object Screen3D]" && currentScreen.background) currentScreen.pauseBackground();

			}
		}
		private function drag(e:MouseEvent):void {

			dragPosition = mouseX - dragOffset;
			dragSpeed = dragPosition - lastPosition;


			// elastic edges
			/*if(!wrap) {
				if(mouseX - dragOffset > 0) {
					dragPosition = (mouseX - dragOffset) / ((3 * (mouseX/stageWidth)) + 1);
					dragSpeed = 0;
				}
				if(mouseX - dragOffset < boundsLo) {

					//dragPosition += 100;
					dragSpeed = 0;
				}
			}*/
			screens.x = dragPosition;
			wrapScreens();
			lastPosition = dragPosition;
		}
		private function stopDragging(e:MouseEvent):void {
				
			dispatchEvent(new DataEvent("trace", true, false,"Slider.stopDragging"));
			if(dragSpeed > 100) dragSpeed = 100;
			if(dragSpeed < -100) dragSpeed = -100;
			landingPosition = Math.round((screens.x + dragSpeed * 30)/stageWidth);
			currentIndex = Math.abs(landingPosition % screenArray.length);
			currentScreen = screenArray[currentIndex];

			TweenLite.to(screens, dragSpeed ? 1 : 0, { x:landingPosition * stageWidth, ease:Quart.easeOut, onUpdate:wrapScreens, onComplete:slideFinished });
			
			screens.removeEventListener(MouseEvent.MOUSE_MOVE, drag);
			screens.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			showNextPrevButtons();
		}
		private function slideFinished():void {

			if(currentScreen != "[object Bitmap]") {
				if(currentScreen == "[object Screen3D]" && currentScreen.background) currentScreen.playBackground();
				if(currentScreen.animations) currentScreen.animate();
			}
			//showNextPrevButtons();
		}
		private function wrapScreens():void { // DS: rename this
			//if(wrap) {
				for(var i:uint = 0; i < screenArray.length; i++) {
					var screen = screenArray[i];
					if(screen.x + screens.x <= (screenArray.length-1) * -stageWidth) screen.x += (screenArray.length * stageWidth); 
					if(screen.x + screens.x >= (screenArray.length-1) *  stageWidth) screen.x -= (screenArray.length * stageWidth); 
					if(screen == "[object Screen3D]" && screen.layers) screen.offset3DLayers(screens.x + screen.x);
				}	
			//}
		}
		private function adjust3DLayers():void {

			for(var i:uint = 0; i < screenArray.length; i++) {
				var screen = screenArray[i];
				if(screen == "[object Screen3D]" && screen.layers) screen.offset3DLayers(screens.x + screen.x);
			}
		}

		
		private function nextPrevClicked(e:MouseEvent):void {

			dispatchEvent(new DataEvent("trace", true, false, "Slider.nextPrevClicked, offset=" + e.currentTarget.offset));

			currentIndex -= e.currentTarget.offset;
			if(currentIndex > screenArray.length - 1) currentIndex = 0;
			if(currentIndex < 0) currentIndex = screenArray.length - 1;
			currentScreen = screenArray[currentIndex];
			landingPosition = stageWidth * (Math.round((screens.x + (e.currentTarget.offset * stageWidth))/stageWidth)); // DS: the screens.x + is allowing in-between values, 
			TweenLite.to(screens, 1, { x:landingPosition, ease:Quart.easeOut, onUpdate:wrapScreens, onComplete:slideFinished }); 
			showNextPrevButtons();
		}

		private function lockSlider(e:Event = null):void {

			dispatchEvent(new DataEvent("trace", true, false,"Slider.lockSlider"));

			locked = true;
			dontTimeout = true;
			if(currentScreen == "[object Screen3D]" && currentScreen.background) currentScreen.pauseBackground();
			hideNextPrevButtons();
		}
		private function freeSlider(e:Event = null):void {

			dispatchEvent(new DataEvent("trace", true, false,"Slider.freeSlider"));
			locked = false;
			dontTimeout = false;
			if(currentScreen == "[object Screen3D]" && currentScreen.background) currentScreen.playBackground();
			showNextPrevButtons();
		}

		private function showNextPrevButtons(e:Event = null):void {

			dispatchEvent(new DataEvent("trace", true, false,"Slider.showNextPrevButtons"));

			if(wrap) {
				var nextIndex = currentIndex + 1;
				var prevIndex = currentIndex - 1;
	
				if(prevIndex < 0) prevIndex = screenArray.length-1;
				if(nextIndex > screenArray.length-1) nextIndex = 0;
	
				//trace("current", currentIndex, prevIndex, nextIndex);
	
			//	nextBtn.label.field.text = (fileArray[nextIndex].name.substring(0, fileArray[nextIndex].name.indexOf(".")).toLowerCase());
				//prevBtn.label.field.text = (fileArray[prevIndex].name.substring(0, fileArray[prevIndex].name.indexOf(".")).toLowerCase());
				
				TweenLite.to(prevBtn, .5, { x:prevBtn.width, ease:Quart.easeOut });
				TweenLite.to(nextBtn, .5, { x:stageWidth - nextBtn.width, ease:Quart.easeOut });
			}
		}
		
		private function hideNextPrevButtons(e:Event = null):void {

			dispatchEvent(new DataEvent("trace", true, false,"Slider.hideNextPrevButtons"));

			TweenLite.to(prevBtn, .5, { x:0, ease:Quart.easeOut });
			TweenLite.to(nextBtn, .5, { x:stageWidth, ease:Quart.easeOut });
		}

		public function open():void {

			dispatchEvent(new DataEvent("trace", true, false,"Slider.open"));

			screens.x = 0;
			currentIndex = 0;
			currentScreen = screenArray[currentIndex]; 
			//trace("setting currentscreen", currentScreen);
			for(var i:uint = 0; i < screenArray.length; i++) {

				var screen = screenArray[i];
				
				if(screen == "[object Screen3D]" && screen.background) screen.pauseBackground();
				//if(screen != "[object Bitmap]") screen.pauseBackground();
				screen.x = i * stageWidth;
			}
			adjust3DLayers();
			if(currentScreen == "[object Screen3D]" && currentScreen.background) currentScreen.playBackground();
			//wrapScreens();
			//if(currentScreen.background) currentScreen.playBackground();  // DS: errors out because background isn't ready yet?
			showNextPrevButtons();
		}
		public function close():void {

			dispatchEvent(new DataEvent("trace", true, false,"Slider.close"));
			
			// DS: this is a good place to stop any videos that are playing
			if(currentScreen == "[object Screen3D]" && currentScreen.background) currentScreen.pauseBackground();

			try {
				if(currentScreen.video != undefined)  
				currentScreen.closeVideo();
			 }
			catch(error:Error) { 

				trace("no video on currentscreen");
			}
			// DS: add a close and stop for when a video (not background video) is playing
		}
	}	
}