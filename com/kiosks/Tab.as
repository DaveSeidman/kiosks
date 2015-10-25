package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import com.kiosks.Link;
	
	import com.greensock.TweenLite;
	
	
	
	public class Tab extends MovieClip {


		public var isOpen = false;
		private var tabTitleText:String;
		public var link;

		public function Tab(title:String, _link:Object) {
			
			//backing.gotoAndStop(color);
			tabTitleText = title;
			link = _link;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			
			//tabTitle.autoSize = TextFieldAutoSize.LEFT;
			tabTitle.text = tabTitleText;
			backing.width = 390;
			tabTitle.width = 330;
			//backing.width = tabTitle.textWidth + 80;
			//links.y = 100;
			//addChild(links);
		}
		
	}
}