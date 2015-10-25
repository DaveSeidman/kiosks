package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import com.kiosks.ImageGallery;
	import com.kiosks.VideoGallery;
	import com.kiosks.PDFViewer;
	import com.greensock.TweenLite;

	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.AutoAlphaPlugin; 	

	public class Overlays extends MovieClip {

		public var currentOverlay = null;

		public function Overlays() {
			
			TweenPlugin.activate([AutoAlphaPlugin]);
		}
		
		public function addOverlay(myOverlay:Object):Object {
			
			var newOverlay;
					
			switch(myOverlay["type"]) {
								
				case "PDF":
					newOverlay = new PDFViewer(myOverlay["name"]);
					addChild(newOverlay);
					break;
				case "IMG":
					newOverlay = new ImageGallery(myOverlay["name"]);
					addChild(newOverlay);
					break;
				case "VID":
					newOverlay = new VideoGallery(myOverlay["name"]);
					addChild(newOverlay);
					break;
			}

			newOverlay.visible = false;
			newOverlay.alpha = 0;
			return newOverlay;
		}
		
		public function openOverlay(myOverlay:Object):void {
			
			if(currentOverlay) closeOverlay(currentOverlay);
			currentOverlay = myOverlay;
			TweenLite.to(currentOverlay, .5, { autoAlpha:1 });
			currentOverlay.openIt();
		}
		
		public function closeOverlay(myOverlay:Object):void {
			
			if(currentOverlay) TweenLite.to(currentOverlay, .5, { autoAlpha:0, onComplete:function() { myOverlay.closeIt(); } });
		}
	}
}
