// Since the factor "trace" function cannot be overridden, this does the same job but also places traced text and values in the config window for easier degugging when outside of the flash IDE.

// To do:
// We probably only need to call getInstance once and cache it somehow.
// allow tracing of any variable type, not just strings
// I think we need to define a function within Tracer called Trace and maybe rename Tracer to kiosks.tracer.
// that might be the only way to allow it to save variables so we can hold the last message.
// this would be helpful when tracing functions that loop quickly, mimic dev tools behavior where it just adds a number to the end of the call instead of writing it many times

package com.kiosks {
	

	public class Tracer {


		private var outputPanel;
	
	/*import com.DTV;*/
	//import com.kiosks.Config;
	
	//var lastMessage;
	//var lastMessage:String;

	public function Tracer(s:*):void {
	//public class Tracer {
			
		/*var dtv = DTV.getInstance();
		var debugText = DTV.getInstance().config.configWindow.debug.textField; 		// get an instance of our main class DS: seems like this should happen only once yet placing it here will make it look up this object every time Tracer is called, find a better way
		
		//debugText.htmlText += (s + "<br>");
		debugText.appendText(s + "\n");*/
		trace(s); 
		//debugText.scrollToRange(debugText.htmlText.length, debugText.htmlText.length);


/*		public function doTrace(s:*) {

			trace("dotrace" + s);
		}
		*/

	}
}
}