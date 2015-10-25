package com.kiosks
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	import flash.errors.IOError;
	
	import flash.events.TouchEvent;
	import flash.events.GesturePhase;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.events.TransformGestureEvent;
	import fl.motion.MatrixTransformer;
	import flash.geom.Matrix;
	import flash.geom.Point;	
	
	import com.kiosks.Tracer;
	import com.kiosks.ImageThumbnail;
	import com.kiosks.ScrollWindow;
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.AutoAlphaPlugin; 


	public class ImageGallery extends Sprite
	{
		TweenPlugin.activate([AutoAlphaPlugin]);
		
		private var path;
		private var imageArray = new Array();
		private var thumbsArray = new Array();
		//private var thumbsArray = new Array();
		private var loadedCount = 0;
		private var thumbs = new Sprite;
		private var currentImage = undefined;
		//private var curImage;
		private var currentX;
		private var currentY;
		private var currentWidth;
		private var currentHeight;
		private var imageLoader = new Loader;
		private var tweenSpeed:Number = .25;
		
		private var pageWidth = 1500;
		private var pageHeight = 800;
		private var thumbHeight = 255;
		private var imageHeight = 800;
		private var thumbPadding = 25;
		
		private var tweening:Boolean = false;

		private var scrollWindow;
		private var startIndex = 0;
		
		//private var panel; // this needs to be updated, written when we were automatically declaring stage instances and this could get hold of the config panel
		//private var nextPageBtn;

		public function ImageGallery(name:String) {

			Tracer("creating new image Gallery: " + name);
			trace("image gallery here:" + name);
			//panel.title.text = name;
			//panel.description.text = "";
			path = "Content/" + name + "/Images";
			var dir:File = File.applicationDirectory.resolvePath(path);
			imageArray = dir.getDirectoryListing();
			
			//TweenLite.to(panel.nextBtn, 0, { autoAlpha:0 });
			//TweenLite.to(panel.prevBtn, 0, { autoAlpha:0 });
			//TweenLite.to(panel.closeBtn, 0, { autoAlpha:0 });
					
			//thumbs.x = 440;
			//thumbs.y = 40;
			
			scrollWindow = new ScrollWindow(thumbs, false, true);
			scrollWindow.x = 440;
			scrollWindow.y = 40;
			addChild(scrollWindow);

			//setChildIndex(panel, numChildren - 1);
			for(var i:uint = 0; i < imageArray.length; i++) {
				
				var imageThumbnail = new ImageThumbnail(path + "/" + imageArray[i].name);
				imageThumbnail.ID = i;
				imageThumbnail.addEventListener("loaded", function() { loadedCount++; if(loadedCount == imageArray.length) arrangeThumbs(); });
	
				imageThumbnail.addEventListener(MouseEvent.CLICK, thumbClicked);
				imageThumbnail.mouseChildren = false;
				thumbsArray.push(imageThumbnail);
			}	
			//panel.closeBtn.addEventListener(MouseEvent.CLICK, function() { closeImage(); });
			//panel.nextBtn.addEventListener(MouseEvent.CLICK, nextImage);
			//panel.prevBtn.addEventListener(MouseEvent.CLICK, prevImage); 
				
		}
		

		private function arrangeThumbs() {
			
			var row = 0;
			while (thumbs.numChildren > 0) { thumbs.removeChildAt(0); }

			for(var i:uint = startIndex; i < thumbsArray.length; i++) {
				var thumb = thumbsArray[i];
				
				thumb.startWidth = thumb.width = (thumb.width * thumbHeight)/1080;
				thumb.startHeight = thumb.height = thumbHeight;
				if(i > 0) thumb.startX = thumb.x = thumbsArray[i-1].x + thumbsArray[i-1].width + thumbPadding;
				if(thumb.x + thumb.width > pageWidth) {	row++; 	thumb.startX = thumb.x = 0;	}
				thumb.startY = thumb.y = (thumbHeight + thumbPadding) * row;
				thumb.alpha = 1;
				thumbs.addChild(thumb);
			}
		}

		private function thumbClicked(e:MouseEvent):void {
			
			if(!scrollWindow.moved) {
				if(e.target == currentImage) {
					closeImage();
				}
				else {
					if(currentImage) {
						closeImage();
					}
					else {
						currentImage = e.target;
						openImage();
					}
				}
			}
		}

		private function nextImage(e:MouseEvent):void {
			
			TweenLite.to(currentImage, tweenSpeed, { x:currentImage.startX, y:currentImage.startY, width:currentImage.startWidth, height:currentImage.startHeight, alpha:.25 });
			currentImage = (currentImage.ID + 1 >= thumbsArray.length) ? thumbsArray[0] : thumbsArray[currentImage.ID + 1];
			
			thumbs.setChildIndex(currentImage, thumbs.numChildren-1);
			zoomIn();
		}
		
		private function prevImage(e:MouseEvent):void {
			
			TweenLite.to(currentImage, tweenSpeed, { x:currentImage.startX, y:currentImage.startY, width:currentImage.startWidth, height:currentImage.startHeight, alpha:.25 });
			currentImage = (currentImage.ID - 1 < 0) ? thumbsArray[thumbsArray.length - 1] : thumbsArray[currentImage.ID - 1];
			
			thumbs.setChildIndex(currentImage, thumbs.numChildren-1);
			zoomIn();
		}

		private function closeImage() { 
		
			Tracer("closing image, " + currentImage + "," + currentImage.ID);
			showThumbs();
			hideControls();
			zoomOut();	
			currentImage = undefined;
		}
		
		private function openImage() {
			
			hideThumbs();
			thumbs.setChildIndex(currentImage, thumbs.numChildren-1);
			
			zoomIn();
		}			
		
		private function zoomIn():void {
			scrollWindow.locked = true;
			//panel.description.text = currentImage.description;
			TweenLite.to(currentImage, tweenSpeed, { x:(1400 - (currentImage.width * imageHeight)/thumbHeight)/2, y:-scrollWindow.scrollContent.y, height:800, width:(currentImage.width * imageHeight)/thumbHeight, alpha:1, onComplete:showControls });
		}
		
		private function zoomOut():void {
			scrollWindow.locked = false;
			//panel.description.text = "";
			TweenLite.to(currentImage, tweenSpeed, { x:currentImage.startX, y:currentImage.startY, width:currentImage.startWidth, height:currentImage.startHeight, alpha:1 });
		}
		
		private function showControls():void {
						
			//TweenLite.to(panel.prevBtn, tweenSpeed, { autoAlpha:.6, x: currentImage.x + 460, scaleX:1, scaleY:1 });
			//TweenLite.to(panel.nextBtn, tweenSpeed, { autoAlpha:.6, x:currentImage.x + currentImage.width + 340, scaleX:1, scaleY:1 });
			//TweenLite.to(panel.closeBtn, tweenSpeed, { autoAlpha:.6, x:currentImage.x + currentImage.width + 340, scaleX:1, scaleY:1 });
		}
		
		private function hideControls():void {
			
			//TweenLite.to(panel.prevBtn, tweenSpeed, { autoAlpha:.6, scaleX:0, scaleY:0 });
			//TweenLite.to(panel.nextBtn, tweenSpeed, { autoAlpha:.6, scaleX:0, scaleY:0 });
			//TweenLite.to(panel.closeBtn, tweenSpeed, { autoAlpha:.6, scaleX:0, scaleY:0 });
		}
		
		private function hideThumbs():void {

			for(var i:uint = 0; i < thumbsArray.length; i++) {	TweenLite.to(thumbsArray[i], tweenSpeed, { alpha:.25 }); }
		}

		private function showThumbs():void {

			for(var i:uint = 0; i < thumbsArray.length; i++) {	TweenLite.to(thumbsArray[i], tweenSpeed, { alpha:1 }); }
		}

		
		public function openIt():void {
			
			Tracer("opening image gallery");
			currentImage = undefined;
			scrollWindow.scrollContent.y = 0;
		}

		public function closeIt():void	{

			// DS: should we do this here or just reset everything in OpenIt?
			if(currentImage) closeImage();
		}
	}
}