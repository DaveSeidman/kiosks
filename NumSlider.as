package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import com.greensock.TweenLite;
	
	public class NumSlider extends MovieClip {
		
		public var value = 0;
		
		private var offset = 0;
		private var spacing = 65;
		
		public function NumSlider() {
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	
		private function init(e:Event):void {
			
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
	
		private function mouseDown(e:MouseEvent):void {
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			
		//	offset = numbers.mouseY;
		}
		
		
		private function mouseMove(e:MouseEvent):void {
			
		//	numbers.y = mouseY - offset;
		//	if(numbers.y > 0) numbers.y = 0;
		//	if(numbers.y < -numbers.height + spacing/2) numbers.y = -numbers.height + spacing/2;
		}
		
		private function mouseUp(e:MouseEvent):void {
			
			//value = Math.round(-numbers.y /spacing);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		//	TweenLite.to(numbers, .2, { y:-value * spacing });
		}
	}
}