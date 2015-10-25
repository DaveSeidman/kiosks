package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class Link extends MovieClip {
		
		public var overlay:Object;
		
		public function Link() {
			
			addEventListener(MouseEvent.CLICK, linkClicked);
		}
		
		private function linkClicked(e:MouseEvent):void {
			
			dispatchEvent(new Event("linkClicked", true));
		}
	}
	
}
