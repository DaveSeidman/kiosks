package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	import flash.utils.setTimeout;
	
	public class ScrollWindow extends MovieClip {
		
		private var offsetX = 0;
		private var offsetY = 0;
		public var scrollX:Boolean = false;
		public var scrollY:Boolean = false;
		public var scrollContent;
		public var moved = false;
		public var locked = false;
		
		public function ScrollWindow(_scrollContent, _scrollX = false, _scrollY = false) {
			
			scrollContent = _scrollContent;
			scrollX = _scrollX;
			scrollY = _scrollY;
			
			this.addChild(scrollContent);
			scrollContent.cacheAsBitmap = true;
			//scrollMask.cacheAsBitmap = true;
		//	scrollContent.mask = scrollMask;
			this.addEventListener(MouseEvent.MOUSE_DOWN, startScroll);
			
		}
		
		
		private function startScroll(e:MouseEvent):void {
			
			if(!locked) {
				offsetX = scrollContent.mouseX;
				offsetY = scrollContent.mouseY;
				
				addEventListener(MouseEvent.MOUSE_MOVE, scrolling);
				addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			}
		}
		
		
		private function scrolling(e:MouseEvent):void {
			
			if(scrollX) scrollContent.x = this.mouseX - offsetX;
			if(scrollY) scrollContent.y = this.mouseY - offsetY;
			moved = true;
		}
		
		
		private function stopScroll(e:MouseEvent):void {
			
			removeEventListener(MouseEvent.MOUSE_MOVE, scrolling);
			if(scrollX) {
				
				if(scrollContent.x > 0) TweenLite.to(scrollContent, .5, { x:0, ease:Expo.easeOut });
		//		if(scrollContent.x < scrollMask.width - scrollContent.width) TweenLite.to(scrollContent, .5, { x:scrollMask.width - scrollContent.width, ease:Expo.easeOut });
			}
			if(scrollY) {
				if(scrollContent.y > 0) TweenLite.to(scrollContent, .5, { y:0, ease:Expo.easeOut });
			//	if(scrollContent.y < scrollMask.height - scrollContent.height) TweenLite.to(scrollContent, .5, { y:scrollMask.height - scrollContent.height, ease:Expo.easeOut });				
			}
			
			//setTimeout(function() { justScrolled = false; }, 10);
			setTimeout(function() { moved = false; }, 50);
		}
	}
	
}
