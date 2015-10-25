package com.kiosks {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.DataEvent;
	import com.greensock.TweenLite;
	import flash.filesystem.File;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.events.NativeProcessExitEvent;	
	//import com.kiosks.Tracer;
	
	public class Watermark extends MovieClip {
		
		private var process = new NativeProcess(); 
		private var bytes:ByteArray = new ByteArray(); 
		private var approvedSerialNumbers = new Array("7HFJL02","JWSBK02","JWS8K02","JWS9L02","JWS8L02","JWS9K02","JWSCK02","JWSBL02","JWR2L02","JWRMK02","JWQQK02","JWQPK02","JWQ5K02","JWQ8L02","JWQTL02","JWQNL02","JWS3M02","JWQQL02","JWQBK02","JWRLL02","JWQHK02","JWRPK02","JWQ1L02","JWQHL02","JWQVL02","JWRPL02","JWQGK02","JWRNK02","JWQ9K02","JWS3K02","JWS5K02","JWQCL02","JWQ6L02","JWQXK02","JWQGL02","JWQNK02","JWRQL02","JWQ2L02","JWQZK02","JWQJL02","JWR1L02","JWRRL02","JWPKL02","JWRML02","JWRSL02","JWRCL02","JWR6M02","JWQ3L02","JWPSL02","JWPYL02","JWQ6K02","JWQML02","JWQLL02","JWR0K02","JWQ8K02","JWS2L02","JWQRK02","JWRRK02","JWQWK02","JWRQK02","JWQ7L02","JWS4M02","JWQMK02","JWPKK02","JWRTL02","JWRZK02","JWQ7K02","JWRKK02","JWQ3K02","JWPML02","JWS1L02","JWR7K02","JWQ4M02","JWRXK02","JWQDK02","JWQBL02","JWRJK02","JWPQL02","JWR4L02","JWRJL02","JWQCK02","JWRNL02","JWS1M02","JWS4K02","JWRDK02","JWRFK02","JWR5L02","JWRCK02","JWQ5L02","JWS0K02","JWQ5M02","JWR3K02","JWQ9L02","JWPPL02","JWPLK02","JWR8L02","JWRHK02","JWRGL02","JWR3L02","JWQJK02","JWR4K02","JWRFL02","JWPMK02","JWPNL02","JWP2L02","JWPBK02","JWMPK02","JWN3K02","JWMFL02","JWPBL02","JWN0M02","JWN6L02","JWMJL02","JWPGL02","JWNVL02","JWMLK02","JWMNL02","JWNKK02","JWP5M02","JWMQK02","JWMJK02","JWN0K02","JWP9K02","JWP6L02","JWNSL02","JWNGL02","JWN0L02","JWP0K02","JWMGL02","JWNJL02","JWN7K02","JWPGK02","JWMPL02","JWN7L02","JWNTL02","JWP3K02","JWPCK02","JWMML02","JWNMK02","JWN5L02","JWMQL02","JWN8K02","JWN5M02","JWP8L02","JWNGK02","JWPCL02","JWP1L02","JWMNK02","JWN9L02","JWNQL02","HLVBDZ1","JWPDL02","JWMRL02","JWPDK02","JWMLL02","JWPFK02","JWMGK02","JWNRK02","JWNDK02","JWP8K02","JWNKL02","JWMVL02","JWNHK02","JWP7L02","JWP9L02","JWNLL02","JWPFL02","JWMMK02","JWMWK02","JWN9K02","JWMTL02","JWN3L02","JWNPK02","JWNFL02","JWMHL02","JWNBK02","JWNNL02","JWN1L02","JWN2M02","JWN4L02","JWMZJ02","JWNLK02","JWNCL02","JWNBL02","JWMHK02","JWMXK02","JWNQK02","JWNRL02","JWP0L02","JWP5K02","JWNFK02","JWP6K02","JWN6K02","JWP6K02","JWP4L02","JWPHK02","JWP3L02","JWN4K02","JWMWL02","JWNDL02","JWNPL02","JWMSL02","JWP5L02","JWNCK02","JWP4K02","JWP7K02","JWMKK02","JWNHL02","JWNJK02","JWNNK02","JWMRK02","JWN2L02","JWN5K02","JWN8L02","JWPLL02","JWPPK02","JWR3M02","JWQSL02","JWR9K02","JWPVL02","JWPRL02","JWR8K02","JWR6K02","JWRBK02","JWQFK02","JWR5M02","JWQ0K02","JWR4M02","JWQRL02","JWR5K02","JWQDL02","JWQLK02","JWR9L02","JWRVL02","JWQKK02","JWR6L02","JWR0L02","JWRDL02","JWPTL02","JWPWK02","JWRKL02","JWS0L02","JWQ4L02","JWRYL02","JWQPL02","JWPNK02","JWQKL02","JWRBL02","JWPZK02","JWQ4K02","JWRLK02","JWRHL02","JWQ0L02","JWQYL02","JWS3L02","JWS4L02","JWRGK02","JWQFL02","JWPQK02","JWPRK02","JWPTK02","JWR7L02");
		private var serialNumber:TextField;

		public function Watermark() {

			serialNumber = new TextField;
			serialNumber.x = -150;
			serialNumber.y = -40;
			serialNumber.width = 300;
			serialNumber.height = 22;
			addChild(serialNumber);
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo(); 
			var file:File = File.applicationDirectory.resolvePath("Content/Commands/getSerialNumber.cmd"); 
			nativeProcessStartupInfo.executable = file; 
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, dataHandler); 
			try {
				process.start(nativeProcessStartupInfo); 
			}
			catch(error:Error) {
				trace("watermark not supported in IDE only when run on AIR platform");
			}
		}
				
		private function dataHandler(e:ProgressEvent):void { 
			
			var bytes = new String(process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable));
			var matched:Boolean = false;
			
			for(var i = 0; i < approvedSerialNumbers.length; i++) {
				dispatchEvent(new DataEvent("trace", true, false, "Checking Serial Number: " + approvedSerialNumbers[i] + "," + bytes.indexOf(approvedSerialNumbers[i])));
				if(bytes.indexOf(approvedSerialNumbers[i]) > -1) { matched = true; break; }
			}
			if(matched) dispatchEvent(new DataEvent("trace", true, false, "Serial Number Found"));
			serialNumber.text = matched ? "serial number matched" : "nVision Inc. Version 3.2.0";
			TweenLite.to(this, 2, { delay:5, y:matched ? -50 : 0 });
		}
		
		private function errorHandler(e:ProgressEvent):void {
			
			serialNumber.text = "Couldn't get serial#, standardError";
		}
		
		//private function onExit(e:NativeProcessExitEvent):void {
			//serialNumber.text = "Process exited";
		//}
	}
	
}
