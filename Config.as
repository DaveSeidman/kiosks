package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.DataEvent;
	import flash.utils.Timer;
	import flash.desktop.NativeApplication;
	//import window.runtime.flash.display.NativeWindow
	import flash.display.NativeWindow;
	
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.DTV;
		
	public class Config extends Sprite {
		
		private var configTimer = new Timer(4000, 1);
		private var configWindow:MovieClip;
		
		public function Config() {

			//Tracer("Config.constructor");
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT; // DS: shouldn't this be in DTV.as?
			/*
			configBtn.addEventListener(MouseEvent.MOUSE_DOWN, function() { startConfigTimer(); });
			configBtn.addEventListener(MouseEvent.MOUSE_UP, function() { stopConfigTimer(); });
			configBtn.addEventListener(MouseEvent.MOUSE_OUT, function() { stopConfigTimer(); });

			configWindow.shutdownBtn.addEventListener(MouseEvent.CLICK, closeProgram);
			configWindow.closeBtn.addEventListener(MouseEvent.CLICK, closeConfig);
			
			if(configWindow.setZoom) {
				configWindow.setZoom.sml.addEventListener(MouseEvent.CLICK, setZoom);
				configWindow.setZoom.med.addEventListener(MouseEvent.CLICK, setZoom);
				configWindow.setZoom.lrg.addEventListener(MouseEvent.CLICK, setZoom);
			}
			
			if(configWindow.contest) {
				configWindow.contest.offBtn.addEventListener(MouseEvent.CLICK, contestOff);
				configWindow.contest.onBtn.addEventListener(MouseEvent.CLICK, contestOn);
			}
			
			if(configWindow.language) {
				configWindow.language.offBtn.addEventListener(MouseEvent.CLICK, languageOff);
				configWindow.language.onBtn.addEventListener(MouseEvent.CLICK, languageOn);
			}
	*/
			configTimer.addEventListener(TimerEvent.TIMER, openConfig);
		}
		
		private function startConfigTimer():void {

			//Tracer("Config.startConfigTimer");

			configTimer.start();
		}
		
		private function stopConfigTimer():void {

			//Tracer("Config.stopConfigTimer");

			configTimer.stop();
		}
		
		public function openConfig(e:TimerEvent = null):void {

			//Tracer("Config.openConfig");
			
			//	TweenLite.to(configWindow, .25, { scaleX:1, scaleY:1, ease:Expo.easeOut  });
		}
		
		public function closeConfig(e:MouseEvent = null):void {

			//Tracer("Config.closeConfig");
	
			/*

			if(configWindow.contest) {
				var contestID = int(configWindow.contest.number1.value.toString() + 
									configWindow.contest.number2.value.toString() +
									configWindow.contest.number3.value.toString());
				dispatchEvent(new DataEvent("setContestID", true, false, contestID));
				Tracer("setting contest ID -> " + contestID);
			}
			TweenLite.to(configWindow, .25, { scaleX:0, scaleY:0, ease:Expo.easeOut });
		*/
		}
		
		private function contestOff(e:MouseEvent = null):void {
			
			//Tracer("turning off contest");
			dispatchEvent(new Event("contestOff"));
		}
		
		private function contestOn(e:MouseEvent):void {
			//Tracer("turning on contest");
			dispatchEvent(new Event("contestOn"));
		}
	
		private function closeProgram(e:MouseEvent):void {
			
			//Tracer("closing program");
			NativeApplication.nativeApplication.exit();
		}
		
		private function languageOn(e:MouseEvent):void {
			
			//Tracer("turning on languages");
			dispatchEvent(new Event("languageOn"));
		}
		
		private function languageOff(e:MouseEvent):void {
			
			//Tracer("turning off languages");
			dispatchEvent(new Event("languageOff"));
		}
		
		private function setZoom(e:MouseEvent):void {

			//Tracer("Config.setZoom " + e.currentTarget.name);

			switch(e.currentTarget.name) {

				case "sml":
					stage.nativeWindow.width = 1280;
					stage.nativeWindow.height = 720;
				break;
					
				case "med":
					stage.nativeWindow.width = 1600;
					stage.nativeWindow.height = 900;
				break;

				case "lrg":
					stage.nativeWindow.width = 1920;
					stage.nativeWindow.height = 1080;
				break;
			}
		}
	}
}
