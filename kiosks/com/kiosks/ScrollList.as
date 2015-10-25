// Generic scrolling list
// DS: work on this more, it should eventually take the place of Slider.as



package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Graphics;

	import flash.events.Event;
	import flash.events.MouseEvent;

	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.utils.setTimeout;
	
	public class ScrollList extends MovieClip {
		
		private var offsetX = 0;
		private var offsetY = 0;
		public var scrollX:Boolean = false;
		public var scrollY:Boolean = false;
		private var scrollingList:Boolean = false;
		public var list;
		
		private var targetY;
		private var targetX;
		private var dampenY;
		private var dampenX;
		private var deltaX;
		private var deltaY;
		private var previousX;
		private var previousY;

		private var INERTIASPEED:Number = .9;
		private var BOUNCESPEED:uint = 3;		// larger values = slower bounces

		public var moved = false;
		public var locked = false;
		
		private var listMask:Sprite;

		public var listWidth;
		public var listHeight;
		
		private var wrap; // should list bounce back at beginning and end or "wrap" around
		private var snap; // accepts strings: "top", "bottom", "left", "right". If not null, scroller attemps to "snap" list to designated edge based on the items' width or height

		private var upBtn;
		private var dnBtn;
		
		public function ScrollList(_list, _scrollX = false, _scrollY = true, _listWidth = 500, _listHeight = 1000, _wrap = false, _snap = null) {
			
			Tracer("ScrollList.constructor " + _list);
			list = _list;
			
			scrollX = _scrollX;
			scrollY = _scrollY;
			listWidth = _listWidth;
			listHeight = _listHeight;
			wrap = _wrap;
			snap = _snap;


			/*var listBack = new Sprite();
			listBack.graphics.beginFill(0x000000, 1);
			listBack.graphics.drawRect(-10,-10, listWidth +20, listHeight +20);
			listBack.graphics.endFill();
			addChild(listBack);*/

			listMask = new Sprite();
			listMask.graphics.beginFill(0x000000, 1);
			listMask.graphics.drawRect(0, 0, listWidth, listHeight);
			listMask.graphics.endFill();
			addChild(list);
			addChild(listMask);
			list.mask = listMask;

			upBtn = new UpBtn();
			upBtn.x = listWidth/2;
			upBtn.y = 0;
			upBtn.offset = 1;
			addChild(upBtn);

			dnBtn = new UpBtn();
			dnBtn.x = listWidth/2;
			dnBtn.y = listHeight;
			dnBtn.offset = -1;
			dnBtn.scaleY = -1;
			addChild(dnBtn);

			upBtn.addEventListener(MouseEvent.CLICK, upDnBtnClicked);
			dnBtn.addEventListener(MouseEvent.CLICK, upDnBtnClicked);

			list.addEventListener(MouseEvent.MOUSE_DOWN, startScroll);
			list.addEventListener(MouseEvent.MOUSE_OUT, stopScroll);
			
			addEventListener(Event.ENTER_FRAME, scrollInertia);

			reset();
		}
		
		
		private function startScroll(e:MouseEvent):void {

			Tracer("ScrollList.startScroll");
			
			if(!locked) {
				scrollingList = true;
				TweenLite.killTweensOf(list);
			
				offsetX = list.mouseX;
				offsetY = list.mouseY;
				deltaX = 0;
				deltaY = 0;
				
				addEventListener(MouseEvent.MOUSE_MOVE, scrolling);
				addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			}
		}
	
		private function scrolling(e:MouseEvent):void {

			Tracer("ScrollList.scrolling");
		
			deltaX = this.mouseX - previousX;
			deltaY = this.mouseY - previousY;

			if(scrollX) targetX = this.mouseX - offsetX;
			if(scrollY) targetY = this.mouseY - offsetY;

			
			list.x = targetX;
			list.y = targetY;
			
			//handleBounds();
			if(!wrap) elasticEdges();

			previousX = this.mouseX;
			previousY = this.mouseY;

			moved = true;			
		}
		
		private function stopScroll(e:MouseEvent):void {

			Tracer("ScrollList.stopScroll");

			trace("stopping scroll");
			
			removeEventListener(MouseEvent.MOUSE_MOVE, scrolling);
			removeEventListener(MouseEvent.MOUSE_OUT, stopScroll);
			
			// here we can lock to list edges
			
			scrollingList = false;
			setTimeout(function() { moved = false; }, 50);			// helps differentiate between a drag and a click
		}

		private function scrollInertia(e:Event):void {

			if(!scrollingList) {

				if(scrollX) {
					deltaX *= INERTIASPEED;
					if(Math.abs(deltaX) < .05) deltaX = 0;
					else list.x += deltaX;

				}
				if(scrollY) {
					
					deltaY *= INERTIASPEED;
					if(Math.abs(deltaX) < .05) deltaX = 0;
					else list.y += deltaY;

				}
				if(!wrap) bounceList();
			}
			if(wrap && (deltaX != 0 || deltaY != 0)) wrapList();
			//else bounceList();
		}

		private function upDnBtnClicked(e:MouseEvent):void {

			trace("upDnBtnClicked", targetY);
			//deltaY = e.currentTarget.offset * 20;
			var targetY = list.y + (e.currentTarget.offset * 200);
			if(targetY > 0) targetY = 0;
			if(targetY < listMask.height - list.height) targetY = listMask.height - list.height;
			TweenLite.to(list, 1, { y:targetY, ease:Quart.easeOut });
			//targetY = e.currentTarget.offset;
		}

		//private function handleBounds():void {

			//list.y = targetY;
			//if(wrap) wrapList();
			//else elasticEdges();

		//}
		private function wrapList():void {		// check for items out of bounds and replaced at beginning or end of list

			for(var i:uint = 0; i < list.numChildren; i++) {

				var item = list.getChildAt(i);
				if(scrollY) {

					if(list.y + item.y <= -item.height) item.y += item.height * list.numChildren;
					if(list.y + item.y >= listMask.height) item.y -= item.height * list.numChildren;
				}
				if(scrollX) {

					if(list.x + item.x <= -item.width) item.x += item.width * list.numChildren;
					if(list.x + item.x >= listMask.width) item.x -= item.width * list.numChildren;
				}
			}
		}

		private function bounceList():void {

			if(scrollY) {
				if(list.y > 0) 	list.y -= list.y / BOUNCESPEED; 											// bounce top
				if(list.y < listMask.height - list.height) list.y += (listMask.height - list.height - list.y) / BOUNCESPEED; // bounce bottom DS: cache list and mask heights
			}
			if(scrollX) {
				if(list.x > 0) 	list.x -= list.x / BOUNCESPEED; 											// bounce left
				if(list.x < listMask.width - list.width) list.x += (listMask.width - list.width - list.x) / BOUNCESPEED; // bounce right DS: cache list and mask heights
			}
		}
		private function elasticEdges():void {	// check for dragging too far up/down, left/right and slow

			if(scrollY) {
				if(list.y > 0) {
					dampenY = targetY/(listHeight/20);
					dampenY = dampenY * dampenY;
					list.y = targetY - dampenY;
				}
				if(list.y < listMask.height - list.height) {
					dampenY = ((listMask.height - list.height - targetY)/(listHeight/20));
					dampenY = dampenY * dampenY;
					list.y = targetY + dampenY;
				}
			}
			if(scrollX) {
				if(list.x > 0) {
					dampenX = targetX/(listWidth/20);
					dampenX = dampenX * dampenX;
					list.x = targetX - dampenX;
				}
				if(list.x < listMask.width - list.width) {
					dampenX = ((listMask.width - list.width - targetX)/(listWidth/20));
					dampenX = dampenX * dampenX;
					list.x = targetX + dampenX;
				}
			}
		}

		public function reset():void {

			list.x = 0;
			//list.y = 0;

			list.y = listMask.height - list.height;
			TweenLite.to(list, 1.5, { y:0, ease:Expo.easeInOut, delay:.5 });

			for(var i:uint = 0; i < list.numChildren; i++) {

				var item = list.getChildAt(i);
				if(scrollY) item.y = item.height * i;
				if(scrollX) item.x = item.width * i;
			}
			deltaX = 0;
			deltaY = 0;
		}
	}
}
