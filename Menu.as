package com.kiosks {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import com.kiosks.Tab;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Menu extends Sprite {

		private var tabTimer = new Timer(3000, 1);
		private var currentTab = undefined;

		public function Menu() {
			// constructor code
		}

	    public function addTab(myTab:Tab):void {
			
			addChild(myTab);
			myTab.titleBtn.addEventListener(MouseEvent.CLICK, tabClicked);	
			myTab.addEventListener("linkClicked", linkClicked);
			
			tabTimer.addEventListener(TimerEvent.TIMER, tabTimerDone);
		}
		
		private function tabClicked(e:MouseEvent):void {
			
			var myTab = e.target.parent as Tab;
			if(myTab.isOpen) closeTab(myTab);
			else openTab(myTab); 
		}
		
		private function tabTimerDone(e:TimerEvent):void {
			
			closeTab(currentTab);
		}
		
		private function linkClicked(e:Event):void {
			
			closeTab(e.currentTarget as Tab);
		}
		
		private function openTab(tab:Tab):void {
			
			if(currentTab != undefined) closeTab(currentTab);
			tab.isOpen = true;
			currentTab = tab;
			TweenLite.to(tab, .25, { alpha:1 });
			/*tabTimer.reset();
			tabTimer.start();*/
		}
		
		private function closeTab(tab:Tab):void {
			TweenLite.to(tab, .25, { alpha:.7 });
			tab.isOpen = false;
			currentTab = undefined;
			
		}
	}
}
