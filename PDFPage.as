package com.kiosks {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.errors.IOError;
	
	import com.kiosks.Tracer;
		
	public class PDFPage extends MovieClip {

		private var imageLoader = new Loader();
		private var offset;
		public var pageID:uint;
		
		public var pageWidth = 1450;
		public var pageHeight = 1880;
		
		public function PDFPage(file:String) {
			
			if(file != null) {
				imageLoader.addEventListener(IOErrorEvent.IO_ERROR, errorEvent);
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
				imageLoader.load(new URLRequest(file));
			}
		}
		
		private function imageLoaded(e:Event):void {

			addChild(imageLoader.content);
			dispatchEvent(new Event("pageLoaded", true));
		}

		private function errorEvent(e:IOError):void {
			
			Tracer(e.message);
		}
		
		public function getPageWidth():Number {
			return pageWidth;
		}
		
		public function getPageHeight():Number {
			return pageHeight;
		}
	}
}