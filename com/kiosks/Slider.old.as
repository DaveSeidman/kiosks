package com.kiosks {
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
//	import flash.display.Graphics;
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	import flash.errors.IOError;

	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;

	import flash.utils.getQualifiedClassName;
	
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

		private var dragStart; 
		private var dragOffset;
		private var dragPosition;
		private var lastPosition;
		private var dragSpeed;
		private var edgeAdjust;
		private var swipeThresh = 125; // DS: maybe make proportional to screen size?

		private var nextBtn;
		private var prevBtn;

		private var boundsLo = 0;
		private var boundsHi = 0;

		private var direction = "";
		private var oldIndex = 0;
		private var currentIndex = 0;
		private var currentScreen;
		
		public var dontTimeout = false;
		private var locked = false;

		public function Slider(pathName:String, _stageWidth:uint = 1920, _stageHeight:uint = 1080) {
			
			stageWidth = _stageWidth;
			stageHeight = _stageHeight;
			path = pathName;
			
/*			graphics.beginFill(0x000000, 1);
			graphics.drawRect(0, 0, stageWidth, stageHeight);
			graphics.endFill();
*/
			contentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, addImage);
			contentLoader.addEventListener(IOErrorEvent.IO_ERROR, loadError);

			var dir:File = File.applicationDirectory.resolvePath("Content/" + path);
			fileArray = dir.getDirectoryListing();
			
			Tracer("Loading Slider screens:");
			for(var i:uint = 0; i < fileArray.length; i++) {
				
				Tracer("-->"+fileArray[i].name);
			}
			
			addChild(screens);
			screens.addEventListener(MouseEvent.MOUSE_DOWN, startDragging); // don't allow dragging until all screens have finished loading			//wrapLastScreen();
			screens.addEventListener("lockSlider", function() { locked = true; });  // DS: consider consolidating these functions
			screens.addEventListener("freeSlider", function() { locked = false; });
			screens.addEventListener("hideMenu", hideNextPrevButtons);
			screens.addEventListener("showMenu", showNextPrevButtons);
			
			nextBtn = new NextBtn;
			prevBtn = new PrevBtn;
			nextBtn.x = stageWidth;
			prevBtn.x = 0;
			nextBtn.y = 700;
			prevBtn.y = 700;

			addChild(nextBtn);
			addChild(prevBtn);

			if(fileArray.length) contentLoader.load(new URLRequest("Content/" + path + "/" + fileArray[index].name));
			else Tracer("<b>No screens found in the 'Image' path, please add</b>");		
		}

		private function loadError(e:IOErrorEvent):void {
			
			Tracer("image load error");
		}
		private function addImage(e:Event):void {
			
			contentLoader.content.x = stageWidth * screens.numChildren;
			screens.addChild(contentLoader.content);
			screenArray.push(contentLoader.content);
			sliderWidth = stageWidth * screens.numChildren;
			boundsLo = stageWidth - sliderWidth;
			index++;
			if(index < fileArray.length) contentLoader.load(new URLRequest("Content/" + path + "/" + fileArray[index].name));
			else reset(); 
		}

/*		private function screensLoaded():void {

			//currentScreen = screenArray[currentIndex]; // DS: add this to reset as well
			
			//prevBtn.addEventListener(MouseEvent.CLICK, nextPrevClicked);
			//nextBtn.addEventListener(MouseEvent.CLICK, nextPrevClicked);
			//direction = "right"; // add to reset
			slideFinished();
			//showNextPrevButtons();
		}
		*/
		
		private function startDragging(e:MouseEvent):void {
			
			if(!locked) {
				if(TweenMax.getTweensOf(screens).length == 0) {

					//TweenLite.killTweensOf(screens);
					//currentScreen.stop();
					//currentScreen.background.stop();
					//currentScreen.pauseBackground();
					dragStart = mouseX;
					dragOffset = screens.mouseX;
					screens.addEventListener(MouseEvent.MOUSE_MOVE, drag);
					screens.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
					//	addEventListener(Event.ENTER_FRAME, checkSpeed);
					
					hideNextPrevButtons();
				}
			}
		}

		private function stopDragging(e:MouseEvent):void {
			
			screens.removeEventListener(MouseEvent.MOUSE_MOVE, drag);
			screens.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			//	removeEventListener(Event.ENTER_FRAME, checkSpeed);
			
			// add inertia
			/*currentIndex = -Math.round((screens.x+(dragSpeed*120))/stageWidth);
			*/
			oldIndex = currentIndex;

			if(mouseX - dragStart < -swipeThresh) { direction = "left"; currentIndex++; }
			if(mouseX - dragStart > swipeThresh) { direction = "right"; currentIndex--; }

			if(currentIndex < 0) currentIndex = screenArray.length-1;
			if(currentIndex > screenArray.length-1) currentIndex = 0;

			currentScreen = screenArray[currentIndex];
			
			TweenLite.to(screens, .7, { x:-currentScreen.x, onUpdate:adjust3DLayers, onComplete:slideFinished });
			
		}

		private function slideFinished():void {

			for(var i:uint = 0; i < screenArray.length; i++) {

				var screen = screenArray[i];
				if(direction == "left")  if(screen.x + screens.x <= (screenArray.length-1) * -stageWidth) screen.x += (screenArray.length * stageWidth);
				if(direction == "right") if(screen.x + screens.x >= (screenArray.length-1) *  stageWidth) screen.x -= (screenArray.length * stageWidth);
			}

			adjust3DLayers();
			
			if(currentScreen.animations != null) currentScreen.animate();
			//currentScreen.play();
			//currentScreen.background.play();
			//currentScreen.playBackground();
			showNextPrevButtons();
		}


		private function drag(e:MouseEvent):void {

			dragPosition = mouseX - dragOffset;
			// elastic edges
			/*if(mouseX - dragOffset > 0) {
				//           		actual      div by	mult     [0 - 1]         offset
				dragPosition = (mouseX - dragOffset) / ((3 * (mouseX/stageWidth)) + 1);
				dragSpeed = 0;
			}
			if(mouseX - dragOffset < boundsLo) {

				//dragPosition += 100;
				dragSpeed = 0;
			}*/
			screens.x = dragPosition;
			adjust3DLayers();
		}

		
		private function nextPrevClicked(e:MouseEvent):void {

			if(e.currentTarget.alpha) {	// don't register a next/prev click unless button is still active
			
				currentIndex += e.currentTarget.offset;

				var clip = MovieClip(screenArray[currentIndex]);  // ds: dupe of lines in function above, class out?
				if(clip.animations) clip.animate();

				//TweenLite.to(prevBtn, .25, { autoAlpha:currentIndex == 0 ? 0 : 1 });
				//TweenLite.to(nextBtn, .25, { autoAlpha:currentIndex == screenArray.length-1 ? 0 : 1 });
			}
		}

		private function adjust3DLayers():void {

			for(var i:uint = 0; i < screenArray.length; i++) {
				var clip = screenArray[i] as MovieClip;
				if(clip.layers) clip.offset3DLayers(screens.x + clip.x);
			}
		}


		private function showNextPrevButtons(e:Event = null):void {


			var nextIndex = currentIndex + 1;
			var prevIndex = currentIndex - 1;

			if(prevIndex < 0) prevIndex = screenArray.length-1;
			if(nextIndex > screenArray.length-1) nextIndex = 0;

			nextBtn.field.text = (fileArray[nextIndex].name.substring(0, fileArray[nextIndex].name.indexOf(".")).toUpperCase());
			prevBtn.field.text = (fileArray[prevIndex].name.substring(0, fileArray[prevIndex].name.indexOf(".")).toUpperCase());
			
			TweenLite.to(prevBtn, .25, { x:prevBtn.width });
			TweenLite.to(nextBtn, .25, { x:stageWidth - nextBtn.width });
		}

		private function hideNextPrevButtons(e:Event = null):void {

			TweenLite.to(prevBtn, .25, { x:0 });
			TweenLite.to(nextBtn, .25, { x:stageWidth });
		}


		public function open():void {
			
			reset();
			//screenArray[0].play();
			//screenArray[0].background.play();
			//screenArray[0].playBackground();
			showNextPrevButtons();

		}

		public function close():void {
			
			// DS: this is a good place to stop any videos that are playing
		}

		private function reset():void {

			screens.x = 0;
			currentIndex = 0;
			currentScreen = screenArray[currentIndex]; // DS: add this to reset as well
			for(var i:uint = 0; i < screenArray.length; i++) {

				var screen = screenArray[i];
				screen.x = i * stageWidth;
			}
			direction = "right"; // add to reset
			slideFinished();
			showNextPrevButtons();
		}
	}
	
}
