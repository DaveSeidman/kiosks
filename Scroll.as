package com.kiosks {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class Scroll extends Sprite {

		private var area;
		private var container;
		private var scrollX;
		private var scrollY;
		private var xMin:Number;
		private var xMax:Number;
		private var yMin:Number;
		private var yMax:Number;
		private var xOff:Number;
		private var yOff:Number;
		
		public var scrolled:Boolean = false;

		public function Scroll(area:Sprite, container:Sprite, scrollX:Boolean = false, scrollY:Boolean = true, lockX:Number = undefined, lockY:Number = undefined) {
			
			this.area = area;
			this.container = container;
			this.scrollX = scrollX;
			this.scrollY = scrollY;
			
			area.x = 0;
			area.y = 0;
			//area.mask = container;
			container.addChild(area);
			container.addEventListener(MouseEvent.MOUSE_DOWN, beginScroll);
		}
		
		private function beginScroll(e:MouseEvent):void {
			
			xOff = area.mouseX;
			yOff = area.mouseY;
			addEventListener(Event.ENTER_FRAME, scroll);
			area.addEventListener(MouseEvent.MOUSE_UP, endScroll);
		}
		
		private function endScroll(e:MouseEvent):void {
			trace("mouse up");
			removeEventListener(Event.ENTER_FRAME, scroll);
		}
		
		
		private function scroll(e:Event):void {
			
			if(scrollX) area.x = container.mouseX - xOff;
			if(scrollY) area.y = container.mouseY - yOff;
		}



	}
	
}
