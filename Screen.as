package com.kiosks {


	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Graphics;
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	import flash.errors.IOError;

	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	public class Screen extends MovieClip {

		private var stageWidth;
		private var stageHeight;

		private var screenLoader = new Loader;

		public var dontTimeout = false;

		public function Screen(path:String, _stageWidth:uint = 1920, _stageHeight:uint = 1080) {
			
			stageWidth = _stageWidth;
			stageHeight = _stageHeight;
			
			screenLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, screenLoaded);
			screenLoader.load(new URLRequest("Content/" + path));	
		}


		private function screenLoaded(e:Event):void {

			addChild(screenLoader.content);
		}

		public function open():void {

			trace("screen opened");
		}

		public function close():void {

			trace("screen closed");
		}
	}
}