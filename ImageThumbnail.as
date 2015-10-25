package com.kiosks {
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class ImageThumbnail extends MovieClip {
		
		public var description;
		public var ID = 0;
		public var startX = 0;
		public var startY = 0;
		public var startWidth = 0;
		public var startHeight = 0;
		private var loader;
		
		public function ImageThumbnail(name:String) {
			
			mouseChildren = false;
			loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoaded);
			loader.addEventListener(Event.COMPLETE, imgLoaded);
			loader.load(new URLRequest(name));
		}
		
		private function imgLoaded(e:Event):void {
			
			loader.content.smoothing = true;
			
			addChild(loader.content);
			dispatchEvent(new Event("loaded", true, false));
			
			var info:LoaderInfo = e.target as LoaderInfo;
			description = getDescription(info.bytes);
		}
			
		private function getDescription(ba:ByteArray):String {
			
			var LP:ByteArray = new ByteArray();
			var PACKET:ByteArray = new ByteArray();
			var l:int;
			ba.readBytes(LP, 2, 2);
			l = LP.readInt() - 2 - 29;
			ba.readBytes(PACKET, 33, l);

			var p:String = trim(""+PACKET);

			var desc = p.substring(p.search('<dc:description>'), p.search('</dc:description>') + 10);
			desc = desc.substring(desc.indexOf('<rdf:li') + 29, desc.indexOf('</rdf:li>'));
			return desc;
		}
		
		private function getXMP(ba:ByteArray):XML {
			
			var LP:ByteArray = new ByteArray();
			var PACKET:ByteArray = new ByteArray();
			var l:int;

			ba.readBytes(LP, 2, 2);
			l = LP.readInt() - 2 - 29;
			ba.readBytes(PACKET, 33, l);

			var p:String = trim(""+PACKET);
			var i:int = p.search('<x:xmpmeta xmlns:x="adobe:ns:meta/"');

			trace(p.substring(p.search('<dc:description>'), p.search('</dc:description>')));

			
			var ar:Array = p.split('<');
			var s:String = "";
			var q:int;
			var j:int = ar.length;
			for (q=1; q < j; q++) {
				s +=  '<' + ar[q];
			}
			i = s.search('</x:xmpmeta>');
			i += ('</x:xmpmeta>').length;
			s = s.slice(0,i);
			/* Delete all behind the XMP XML */
			return XML(s);
		}

		private function trim(s:String):String {
			
			return s.replace( /^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2" );
		}		
	}
}
