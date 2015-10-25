// Main class for Kohler DTV touchscreen program

// to do:
// clicking current overlay's tab reloads it, should do nothing

package com {
	
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Stage;
	
	import flash.events.Event;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.events.FocusEvent;
	import flash.events.ActivityEvent;
	import flash.events.NativeWindowBoundsEvent;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import flash.media.Video;
	import flash.media.SoundChannel;
	import flash.media.Sound;
	
	import flash.utils.Timer;

	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
		
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.AutoAlphaPlugin; 
	
	//import com.kiosks.Tracer;
	import com.kiosks.Attract;
	import com.kiosks.Button;
//	import com.kiosks.PDFViewer;
	import com.kiosks.VideoPlayer;
	import com.kiosks.VideoGallery;
	import com.kiosks.Config;
	import com.kiosks.Watermark;
	import com.kiosks.Slider;
	import com.kiosks.Screen;


	public class DTV extends MovieClip {

		private static var instance:DTV;											// create a private instance of DTV (so far only used by Tracer)
		
		public var config:Config;												// Config class gives the administrator hidden control over the program
		//private static var config = new Config;
		//public static var dbText;
		private var attract;														// An Attract loop that runs while users aren't interacting with program
		private var features;														// A container for all the features this program can display
		private var featureArray = new Array();										// An array of these features
		private var menu;															// A menu for the features									
		private var menuArray = new Array();										// An array of menu items (should probably be rolled into assoc array with features)
		private var watermark;														// A watermark to be displayed if a matching system serial number is not found
		private var useWatermark:Boolean = false;
		private var currentOverlay = undefined;										// The current overlay (object)
		private var currentButton = undefined;										// The current tab selected (Tab object)
		private var overlayTimer;													// A timer to close any open features after a set duration
		private var TIMEOUT = 60000;												// Duration before timing out (consider changing type to Const or pulling from Config Constants)
		private var menuTimer;														// A timer for when the menu "un-dims" to dim it again after no activity
		private var MENUTIMEOUT = 4000;	
		private var stageWidth;
		private var stageHeight;
		private var currentVol;
				
		public static function getInstance():DTV { return instance; }					// return an instance of DTV to any class that asks for it								  


		public function DTV() {
	
			//Tracer("DTV.constructor");

			TweenPlugin.activate([AutoAlphaPlugin]);								// Activates the autoalpha plugin which tweens an object to or from hidden and automatically changes it's display between visible and invisible
					
			instance = this;														// an instance of DTV
			stage.align = StageAlign.TOP_LEFT;										// do not scale to match swf dimensions, all positions and dimensions are 1 to 1.
					
			stageWidth = stage.stageWidth;		
			stageHeight = stage.stageHeight;		
		
			attract = new Attract("Attract", stageWidth, stageHeight);				
			addChild(attract);														// create and add attract overlay to stage (the rest of the modules will be placed inside of features)
			
			features = new Sprite;							
			addChild(features);
			features.addEventListener("hideMenu", hideMenu);						// create and add an overlay container
			features.addEventListener("showMenu", showMenu);
			features.addEventListener("closeMe", closeFeature);
			features.addEventListener("resetTimeout", resetTimeout);

			features.addEventListener("trace", traceMessage);

			//var what = new Screen("What/what.swf", stageWidth, stageHeight);		// DS: change all these loading paths to be more explicit (ie: Content/what/what.swf)
			

			var what = new Slider("What", stageWidth, stageHeight, true);
			featureArray.push({"title" : "What is DTV+", "object" : what });
			
//			var why = new Slider("Why", stageWidth, stageHeight, true);				// create a slider with "Why go digital" content; path = ApplicationFolder/Content/Why/				
			//featureArray.push({"title" : "Why DTV+", "object" : why });				// and add it to the overlay array
		/*
			var teaser = new VideoPlayer("Teaser/Teaser.flv", stageWidth, stageHeight);						// create a new video player with the Teaser video
			teaser.controls.y -= 120;
			featureArray.push({"title" : "Watch DTV+", "object" : teaser});			// and add it to the overlay array
			*/
			//var spa = new Slider("Spa", stageWidth, stageHeight, true);					// create a slider with "Spa Experiences" content; path = ApplicationFolder/Content/Spa/				
			//featureArray.push({"title" : "Discover Spa Experiences", "object" : spa });	// and add it to the overlay array
			/*			
			var learn = new VideoGallery("Showering");
			featureArray.push({"title" : "Learn Kohler Showering", "object" : learn });
			*/
			
			menu = new Menu;														// create a new menu
			menu.y = stage.stageHeight;	
			menu.x = 0;																// bottom align it, DS Future Update: Create Menu class, pass it menu items along with where to align itself
			
			for(var i = 0; i < featureArray.length; i++) {							// place each overlay inside of container and create menu item for each (may be replaced once I create a Meny class)
						
				var feature = featureArray[i];										// get overlay
				//TweenLite.to(overlay["object"], 0, { autoAlpha:0 });				// cheap way of setting overlays alpha and visibility (rewrite as two lines?)
				feature["object"].visible = feature["object"].alpha = 0;
				features.addChild(feature["object"]);							// add each overlay to container
				
				var button = new Button(feature["title"], feature["object"]);		// create a new button which takes the name of the overlay as well as a reference to it's stage instance
				button.x = i * 300 + 0;											// set it's position
				//button.alpha = .7;												// set it's opacity
				button.mouseChildren = false;										// prevent anything inside the button from firing mouse events since our link to the actual overlay is based on the Tab object
				button.addEventListener("clicked", buttonClicked);					// fire click event (future update: look into touch events to see if they're any more responsive as is the case in javascript)
				menu.addChild(button);												// add the tab to the meny
			}
			
			
			addChild(menu);															// add the menu to the stage
			
			currentVol = 1;
			menu.volumeBtn.volumeIcon.gotoAndStop(1);
			menu.volumeBtn.addEventListener(MouseEvent.CLICK, adjustVolume);
			SoundMixer.soundTransform = new SoundTransform(currentVol/4);
			//var volBtn = new VolumeBtn();
			//volBtn.x = 1600;
			//volBtn.y = 820;
			//volBtn.volumeIcon.gotoAndStop(1);
			//menu.addChild(volBtn);

			overlayTimer = new Timer(TIMEOUT, 1);									// create a timer to close the currently open overlay if not already closed by user
			overlayTimer.addEventListener(TimerEvent.TIMER, featureTimeout);		// set the timeout duration and event listener	

			menuTimer = new Timer(MENUTIMEOUT, 1);
			menuTimer.addEventListener(TimerEvent.TIMER, hideMenu);
											
			addEventListener(MouseEvent.MOUSE_DOWN, holdTimeout);					// any touch to the screen will reset the timeout and prevent the program from closing any open features
			addEventListener(MouseEvent.MOUSE_UP, releaseTimeout);		
			addEventListener(Event.MOUSE_LEAVE, releaseTimeout);		
			
			//watermark = new Watermark();
			//watermark.x = 800; watermark.y = 0;									// position and add the watermark. Note, this is currently disabled to allow for IDE debugging, uncomment before final publish
			//addChild(watermark);

			config = new Config();
			config.x = stage.stageWidth/2; 											// position the config dialog to the middle of the screen
			config.y = stage.stageHeight/2;		
			addChild(config);														// add config to the stage; note that the placement of every stage item is intentional for layering purpose, first the attract (bottom-most), then the features, then the menu, finally the config (top-most)
			config.closeConfig();	// close the config by default. Note that for some installations, the client would like this visible on startup
		}
		
		
//		public static function getInstance():DTV { return instance; }					// return an instance of DTV to any class that asks for it								  


		private function buttonClicked(e:Event):void {								// handle menu clicks DS: (this may end up in a Menu class eventually)		
			
			if(menu.alpha == 1) {

				if(currentOverlay != undefined && e.target.link != currentOverlay) { 	// if a currentOverlay exists 

					currentButton.deactivate();											// all this code is duplicated in "closeFeature", consider combining
					TweenLite.to(currentOverlay, .25, { autoAlpha:0 });					// hide the current feature
					currentOverlay.close();												// run the current features's close function 
					menuTimer.stop();												
				}		
				if(e.target.link != currentOverlay) { // make sure it's not the one that's already open
					
					currentOverlay = e.target.link;											// switch the new overlay
					currentButton = e.target;												// switch the new tab (again, this should be one associative array for elegance)
					currentOverlay.open();													// run the new overlay's open function DS: (rename to 'open')
					TweenLite.to(currentOverlay, .25, { autoAlpha:1 });						// show the new overlay
					currentButton.activate();			
					attract.hold();
				}
			}
			else {

				showMenu();										// a button was clicked but menu was faded back, fade it back in (which allows it to be clicked next time);
				menuTimer.start();

				// DS: maybe we should add a timer here for about 5 seconds to dim again
			}
			//TweenLite.to(currentButton, .25, { alpha:1 });						// brighten the new tab
		}
		private function hideMenu(e:Event = null):void {

			TweenLite.to(menu, .5, { alpha:.25 });
		} 
		private function showMenu(e:Event = null):void {

			TweenLite.to(menu, .5, { alpha:1 });
		}

		private function featureTimeout(e:TimerEvent):void {						// timeout duration has elapsed
			
			if(currentOverlay != undefined) {	

				trace("DTV.featureTimeout", currentOverlay, currentOverlay.dontTimeout)
						
				if(!currentOverlay.dontTimeout) {									// if overlay exists and it's not preventing timeouts  DS: might not be able to use && operator since asking for the dontTimeout public variable of an object that doesn't exist may throw a runtime error and crash the program, use a try/catch?
	
					closeFeature();							
				}
				else {
					overlayTimer.reset();
					overlayTimer.start();
				}
			}
		}
		private function holdTimeout(e:MouseEvent = null):void {

			overlayTimer.stop();
		}
		private function releaseTimeout(e:MouseEvent = null):void {

			overlayTimer.reset();
			overlayTimer.start();
		}
		private function resetTimeout(e:MouseEvent = null):void {					// any touch to the screen should reset the timeout
			
			overlayTimer.reset();
			overlayTimer.start();													// reset timeout
		}		

		private function closeFeature(e:Event = null):void {

			TweenLite.to(currentOverlay, .25, { autoAlpha:0 });				// hide the current overlay DS: we repeat this code, should write a "close" and "open" function 
			//TweenLite.to(currentButton, .25, { alpha:.7 });					// dim the current tab
			currentButton.deactivate();	
			currentOverlay = undefined;						// reset current overlay variable
			attract.release();
			showMenu();	
			//menuTimer.reset();
			menuTimer.stop();
		}

		private function adjustVolume(e:MouseEvent):void {

			currentVol++;
			if(currentVol > 4) currentVol = 1;
			menu.volumeBtn.volumeIcon.gotoAndStop(currentVol);
			SoundMixer.soundTransform = new SoundTransform(currentVol/4);
		}


		/*public function Tracer(e:Event):void {

			trace("tracing:", e);
		}*/

		private function traceMessage(e:DataEvent):void {

			trace("tracer:" + e.data);
		}
		
	}
}