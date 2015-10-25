package com.kiosks {
	
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	import flash.errors.IOError;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	
	import com.greensock.plugins.TweenPlugin; 
	import com.greensock.plugins.DropShadowFilterPlugin; 
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import com.kiosks.Tracer;	
	import com.kiosks.PDFDrawer;	

	
	public class PDFViewer extends Sprite {

		private var pdf;
		private var pdfDrawer;
		private var pdfControls;
		
		private var pageWidth = 1450; // pass these down through all subclasses
		private var pageHeight = 1880; 
		//private var smallPosition = new Point(


		public function PDFViewer(folder:String) {
			
			Tracer("creating PDF");

			var directory:File = File.applicationDirectory.resolvePath("Content/pdfs/" + folder);
			var fileArray = directory.getDirectoryListing();
		
			if(fileArray.length) {
			
				pdfControls = new PDFControls;
				if(fileArray.length <= 2) {
					
					pdfControls.currentOfTotal.visible = false;
					pdfControls.nextBtn.visible = false;
					pdfControls.prevBtn.visible = false;
					pdfControls.drawerBtn.visible = false;
					pdfControls.zoomBtn.y = 120;
				}
				
				pdf = new PDF("Content/pdfs/" + folder, fileArray, pdfControls);
				pdf.x = 300; pdf.y = 20;
				pdf.scaleX = pdf.scaleY = .5; // allow double zoom
				pdf.mask = pdfMask;
				pdf.addEventListener("updatePages", updatePages);
				
				pdfDrawer = new PDFDrawer("Content/pdfs/" + folder, fileArray, pdf);
				pdfDrawer.x = -200;
	
				addChild(pdf);
				addChild(pdfDrawer);
				addChild(pdfControls);
								
				setupControls();			
			}
			else {
				
				Tracer("Couldn't find any files here: " + name);
			}
		}

		private function setupControls() {
			
			pdfControls.nextBtn.addEventListener(MouseEvent.CLICK, nextPage);
			pdfControls.prevBtn.addEventListener(MouseEvent.CLICK, prevPage);
			pdfControls.zoomBtn.addEventListener(MouseEvent.CLICK, zoomPage);
			//pdf.addEventListener(MouseEvent.DOUBLE_CLICK, zoomPage);
			pdfControls.drawerBtn.addEventListener(MouseEvent.CLICK, openCloseDrawer);
		}
		
		private function openCloseDrawer(e:MouseEvent):void {
			
			TweenLite.to(pdf, .5, { x:(pdfDrawer.x > -200 ? 320 : 450) });
			TweenLite.to(pdfDrawer, .5, { x:(pdfDrawer.x > -200 ? -200 : 120)});
			TweenLite.to(pdfMask, .5, { x:(pdfDrawer.x > -200 ? 120 : 440), width:(pdfDrawer.x > -200 ? 1800 : 1480) });
			pdfControls.drawerBtn.gotoAndPlay(pdfDrawer.x > -200 ? "in" : "out");
			
			
		}
		
		private function nextPage(e:MouseEvent):void {

			pdf.nextPage();
			pdfDrawer.highlightThumb(pdf.currentPageIndex+1);
			if(pdf.currentPageIndex >= 1 && pdfControls.prevBtn.alpha == .5) TweenLite.to(pdfControls.prevBtn, .5, { alpha:1 });
			if(pdf.currentPageIndex >= pdf.totalPages - 3 && pdfControls.nextBtn.alpha > .5) TweenLite.to(pdfControls.nextBtn, .5, { alpha:.5 });
		}
		
		private function prevPage(e:MouseEvent):void {

			pdf.prevPage();
			pdfDrawer.highlightThumb(pdf.currentPageIndex-2);			
			if(pdf.currentPageIndex <= 2 && pdfControls.prevBtn.alpha > .5) TweenLite.to(pdfControls.prevBtn, .5, { alpha:.5 });
			if(pdf.currentPageIndex <= pdf.totalPages - 2 && pdfControls.nextBtn.alpha == .5) TweenLite.to(pdfControls.nextBtn, .5, { alpha:1 });
		}

		private function updatePages(e:Event):void {
			
			Tracer("pages updated, " + pdf.currentPageIndex);
			pdfDrawer.highlightThumb(pdf.currentPageIndex);

			if(pdf.currentPageIndex >= 1 && pdfControls.prevBtn.alpha == .5) TweenLite.to(pdfControls.prevBtn, .5, { alpha:1 });
			if(pdf.currentPageIndex >= pdf.totalPages - 3 && pdfControls.nextBtn.alpha > .5) TweenLite.to(pdfControls.nextBtn, .5, { alpha:.5 });
			if(pdf.currentPageIndex <= 2 && pdfControls.prevBtn.alpha > .5) TweenLite.to(pdfControls.prevBtn, .5, { alpha:.5 });
			if(pdf.currentPageIndex <= pdf.totalPages - 2 && pdfControls.nextBtn.alpha == .5) TweenLite.to(pdfControls.nextBtn, .5, { alpha:1 });

		}

		private function zoomPage(e:MouseEvent):void {
			
			pdf.scaleX > .5 ? zoomOut() : zoomIn();
		}

		private function zoomIn():void {
			
			pdfControls.zoomBtn.gotoAndPlay("out");
			TweenLite.to(pdf, .5, { x:pdfDrawer.x > -200 ? 320 : 160, scaleX:1, scaleY:1 });
			TweenLite.to(pdfMask, .2, { height: 960 });
			pdf.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingPDF);
			pdf.addEventListener(MouseEvent.MOUSE_UP, stopDraggingPDF);
		}
		
		private function zoomOut():void {
			
			pdfControls.zoomBtn.gotoAndPlay("in");
			TweenLite.to(pdf, .5, { x:(pdfDrawer.x > -200 ? 480 : 320), y:40, scaleX:.5, scaleY:.5 });
			TweenLite.to(pdfMask, .2, { height: 1080 });
			pdf.removeEventListener(MouseEvent.MOUSE_DOWN, startDraggingPDF);
			pdf.removeEventListener(MouseEvent.MOUSE_UP, stopDraggingPDF);
		}
		
		private function startDraggingPDF(e:MouseEvent):void {
			
			pdf.startDrag();
		}
		
		private function stopDraggingPDF(e:MouseEvent):void {
			
			pdf.stopDrag();
			var xTarget = pdf.x;
			var yTarget = pdf.y;
			if(pdf.x > (pdfDrawer.x > -200 ? 320 : 160)) xTarget = pdfDrawer.x > -200 ? 480 : 120;
			if(pdf.x < pdfMask.x + pdfMask.width - (pageWidth * 2)) xTarget = pdfMask.x + pdfMask.width - (pageWidth * 2);
			if(pdf.y > 20) yTarget = 20;
			if(pdf.y <  pdfMask.height - pageHeight) yTarget = pdfMask.height - pageHeight;
			
			TweenLite.to(pdf, .25, { x:xTarget, y:yTarget });
		}
		
		public function openIt():void {
			
			Tracer("opening pdf viewer");
			pdfControls.prevBtn.alpha = .5;
			zoomOut();
		}
		
		public function closeIt():void {
			
			pdf.reset();
			pdf.x = 320;
			pdf.scaleX = pdf.scaleY = .5;
			pdfMask.x = 160;
			pdfMask.width = 1720;
			pdfDrawer.reset();
			pdfDrawer.x = -200;
			pdfControls.drawerBtn.gotoAndStop("out");
			pdfControls.zoomBtn.gotoAndStop("out");
			pdfControls.prevBtn.alpha = .5;
		}
	}
}