package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import com.greensock.TweenLite;
	
	public class Button extends MovieClip {

		public var link;
		public var active:Boolean = false;
		private var body:ButtonBody;
		private var labelOn:ButtonLabelOn;
		private var labelOff:ButtonLabelOff;

		public function Button(title:String, _link:Object) {
			

			link = _link;

			body = new ButtonBody;
			body.x = 20;
			body.y = -90;
			body.width = 280;
			addChild(body);

			labelOn = new ButtonLabelOn;
			labelOn.x = 10;
			labelOn.y = -84;
			addChild(labelOn);

			labelOff = new ButtonLabelOff;
			labelOff.x = 10;
			labelOff.y = -84;			
			addChild(labelOff);
			
			labelOn.field.text = title;
			labelOff.field.text = title;
			labelOff.alpha = 0;
			var tf:TextFormat = new TextFormat();
			tf.letterSpacing = 1;
			labelOn.field.setTextFormat(tf); 
			labelOff.field.setTextFormat(tf);
			body.inner.alpha = 0;
			body.inner.scaleX = .95;
			body.inner.scaleY = .80;

			this.addEventListener(MouseEvent.CLICK, onClick);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseIn);
			//this.addEventListener(MouseEvent.MOUSE_UP, onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			

		}
		private function onMouseIn(e:MouseEvent):void {

			trace("button.mousein");
		//	if(!active) TweenLite.to(body.inner, .33, { alpha:.35 });
		}
		private function onMouseOut(e:MouseEvent):void {

			trace("button.mouseout");
			//if(!active) TweenLite.to(body.inner, .33, { alpha:0 });
		}
		private function onClick(e:MouseEvent):void {

			trace("button.click");
			dispatchEvent(new Event("clicked", true));
			//if(!active) TweenLite.to(body.inner, .33, { alpha:0 });
		}
		public function activate():void {

			trace("button.activate");
			active = true;
			//TweenLite.to(body.inner, .33, { alpha:1, scaleX:1, scaleY:1 });
			//TweenLite.to(labelOn, .33, { alpha:0 });
			//TweenLite.to(labelOff, .33, { alpha:1 });
		}
		public function deactivate():void {

			trace("button.deativate");
			active = false;
			//TweenLite.to(body.inner, .33, { alpha:0, scaleX:.95, scaleY:.80 });
			//TweenLite.to(labelOn, .33, { alpha:1 });
			//TweenLite.to(labelOff, .33, { alpha:0 });
		}
	}
}