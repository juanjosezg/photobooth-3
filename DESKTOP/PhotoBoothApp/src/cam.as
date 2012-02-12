import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.effects.Zoom;
import mx.events.ResizeEvent;
import mx.graphics.codec.JPEGEncoder;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.Base64Encoder;

import spark.events.TextOperationEvent;

private var mainWindow:NativeWindow;
private var displayWidth:int = Screen.mainScreen.visibleBounds.width;
private var displayHeight:int = Screen.mainScreen.visibleBounds.height;
private var splashTimer:Timer;
private var displayRatio:Number;
private var dispState:String;
private var picture:BitmapData;
private var encodedData:String;
private var camera:Camera;
private var saveTimer:Timer;
private var sendTimer:Timer;

private function init():void {
	displayRatio = displayWidth / displayHeight;
	
	mainWindow = this.stage.nativeWindow;
	mainWindow.width = mainWindow.height * displayRatio - 63;
	
	mainWindow.x = displayWidth/2 - mainWindow.width/2;
	mainWindow.y = displayHeight/2 - mainWindow.height/2;
	
	dispState = systemManager.stage.displayState;
	getCam();
}

private function registerGlobalKeyHandler():void {
	systemManager.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
	systemManager.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
	
	saveTimer = new Timer(12000, 1);
	saveTimer.addEventListener(TimerEvent.TIMER_COMPLETE, saveTimerHandler);
	
	sendTimer = new Timer(100, 1);
	sendTimer.addEventListener(TimerEvent.TIMER_COMPLETE, sendTimerHandler);
}

private function serverURL_changeHandler(event:TextOperationEvent):void {
	remoteURL = remoteURLField.text;
	Alert.show(remoteURL);
}

private function onResize(e:ResizeEvent):void {
	//camera.setMode(theCam.width, theCam.height, 30);
}

private function getCam():void {
	if (Camera.getCamera()) {
		camera = Camera.getCamera();
		camera.setQuality(0, 100);
		camera.setMode(theCam.width, theCam.height, 30, false);
		//camera.setMode(theCam.width, (theCam.width / 4) * 3, 30);
		//camera.setMotionLevel(30, 10000);
		//camera.addEventListener(ActivityEvent.ACTIVITY, camActivityHandler);
		theCam.attachCamera(camera);
	} else {
		Alert.show("The Camera cannot be found!");
	}	
}

private function initPicture():void {
	if (controlBlock.visible) {
		previewBox.visible = false;
		controlBlock.visible = false;
		
		var counter:int = 4;
		var myTimer:Timer = new Timer(1000, 4);
		myTimer.addEventListener(TimerEvent.TIMER, countDown);
		myTimer.start();
		
		counterDisplay.visible = true;
	}
	
	function countDown(event:TimerEvent):void {
		counter -= 1;
		if (counter <= 0) {
			counterDisplay.visible = false;
			takePicture();
		} else {
			counterDisplay.text = counter.toString();
		}
	}
}

private function handleKeyDown(e:KeyboardEvent):void {
	switch(e.keyCode) {
		case 32:
			initPicture();
			break;
		case 37:
			discardPicture();
			break;
		case 39:
			savePicture();
			break;
	}
}

private function takePicture():void {
		
	//create a BitmapData variable called picture that has theCam's size
	picture = new BitmapData(theCam.width, theCam.height);
	
	//the BitmapData draws our theCam
	picture.draw(theCam);		
	
	//Our preview's source is a new Bitmap made of picture's BitmapData
	preview.source = new Bitmap(picture);
	
	//makes the previewBox visible, so we can see our picture
	previewBox.visible = true;
	
	//displays the flashLight
	flashLight.visible = true;
	
	//makes the flashLight go way
	flashLight.visible = false;
		
	saveResetBlock.visible = true;
	saveTimer.start();
}

private function saveTimerHandler(e:TimerEvent):void {
	discardPicture(true);
}

private function discardPicture(override:Boolean = false):void {
	saveTimer.stop();
	saveTimer.reset();
	if (saveResetBlock.visible || override == true) {
		counterDisplay.text = "Ready";
		saveResetBlock.visible = false;
		controlBlock.visible = true;
		previewBox.visible = false;
		counterDisplay.visible = false;
	}
}

private function savePicture():void {
	saveTimer.stop();
	saveTimer.reset();
	if (saveResetBlock.visible) {
		counterDisplay.text = "Saving";
		counterDisplay.visible = true;
		saveResetBlock.visible = false;
		sendTimer.reset();
		sendTimer.start();
	}
}

private function sendTimerHandler(e:TimerEvent):void {
	sendPic();
}

private function sendPic():void {
	var je:JPEGEncoder = new JPEGEncoder(90);
	
	//creates a new ByteArray called "ba"
	//JPEGEnconder encodes our "bm" Bitmap data: our "picture"	
	var ba:ByteArray = je.encode(picture);
	//this ByteArray is now an encoded JPEG
	
	//creates a new Base64Encoder called "be"
	var be:Base64Encoder = new Base64Encoder();
	
	//encodes our "ba" ByteArray (wich is our JPEG encoded picture) with base64Encoder
	be.encodeBytes(ba);
	
	//Now we have our "encodedData" string to send to the server
	encodedData = be.flush();
	
	handleService.send({content: encodedData});
}

private function httpResult(event:ResultEvent):void {	
	discardPicture(true);
}

private function httpFault(event:FaultEvent):void {
	discardPicture(true);
	
	//var faultstring:String = event.fault.faultString;
	//Alert.show(faultstring);
	
	counterDisplay.text = "ERROR!";
	counterDisplay.visible = true;
}

/*private function camActivityHandler(e:ActivityEvent):void {
	if (e.activating == true) {
		//t.start();
		//Alert.show("camera activity");
	} else {
		discardPicture();
		Alert.show("no camera activity");
	}
}*/

private function fullScreenHandler(evt:FullScreenEvent):void {
	dispState = systemManager.stage.displayState + " (fullScreen=" + evt.fullScreen.toString() + ")";
	if (evt.fullScreen) {
		fullscreenButton.visible = false;
		fullscreenButton.enabled = false;
		remoteURLField.visible = false;
		//camera.setQuality(0, 50);
	} else {
		fullscreenButton.visible = true;
		fullscreenButton.enabled = true;
		remoteURLField.visible = true;
		//camera.setQuality(0, 100);
	}
	preview.width = systemManager.stage.stageWidth;
	preview.height = systemManager.stage.stageHeight;
}

private function toggleFullScreen():void {
	try {
		switch (systemManager.stage.displayState) {
			case StageDisplayState.FULL_SCREEN_INTERACTIVE:
				systemManager.stage.displayState = StageDisplayState.NORMAL;
				break;
			default:
				systemManager.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				break;
		}
	} catch (err:SecurityError) {
		// ignore
	}
}