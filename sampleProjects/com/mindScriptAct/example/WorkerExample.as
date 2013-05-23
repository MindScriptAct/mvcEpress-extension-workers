package com.mindScriptAct.example {
	import com.adobe.example.vo.CountResult;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.registerClassAlias;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;

	public class WorkerExample extends Sprite {
		// ------- Embed the background worker swf as a ByteArray -------
		[Embed(source="../workerswfs/BackgroundWorker.swf", mimeType="application/octet-stream")]
		private static var BackgroundWorker_ByteClass:Class;

		public static function get BackgroundWorker():ByteArray {
			return new BackgroundWorker_ByteClass();
		}


		private var bgWorker:Worker;
		private var bgWorkerCommandChannel:MessageChannel;
		private var progressChannel:MessageChannel;
		private var resultChannel:MessageChannel;


		public function WorkerExample() {
			initialize();
		}


		private function initialize():void {
			// create the user interface
			setupStage();
			createStatusText();
			createProgressBar();

			// Register the alias so we can pass CountResult objects between workers
			registerClassAlias("com.adobe.test.vo.CountResult", CountResult);

			// Create the background worker
			bgWorker = WorkerDomain.current.createWorker(BackgroundWorker);

			// Set up the MessageChannels for communication between workers
			bgWorkerCommandChannel = Worker.current.createMessageChannel(bgWorker);
			bgWorker.setSharedProperty("incomingCommandChannel", bgWorkerCommandChannel);

			progressChannel = bgWorker.createMessageChannel(Worker.current);
			progressChannel.addEventListener(Event.CHANNEL_MESSAGE, handleProgressMessage)
			bgWorker.setSharedProperty("progressChannel", progressChannel);

			resultChannel = bgWorker.createMessageChannel(Worker.current);
			resultChannel.addEventListener(Event.CHANNEL_MESSAGE, handleResultMessage);
			bgWorker.setSharedProperty("resultChannel", resultChannel);

			// Start the worker
			bgWorker.addEventListener(Event.WORKER_STATE, handleBGWorkerStateChange);
			bgWorker.start();
		}


		private function handleBGWorkerStateChange(event:Event):void {
			if (bgWorker.state == WorkerState.RUNNING) {
				_statusText.text = "Background worker started";
				bgWorkerCommandChannel.send(["startCount", 100000000]);
			}
		}


		private function handleProgressMessage(event:Event):void {
			var percentComplete:Number = progressChannel.receive();
			setPercentComplete(percentComplete);
			_statusText.text = Math.round(percentComplete).toString() + "% complete";
		}


		private function handleResultMessage(event:Event):void {
			var result:CountResult = resultChannel.receive() as CountResult;
			setPercentComplete(100);
			_statusText.text = "Counted to " + result.countTarget + " in " + (Math.round(result.countDurationSeconds * 10) / 10) + " seconds";
		}


		// ------- Create UI -------

		private var _currentPercentComplete:int = 0;
		private var _needsValidation:Boolean = false;
		private var _statusText:TextField;
		private var _progressBarRect:Shape;
		private var _progressBar:Shape;

		private function setupStage():void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageWidth = 800;
			stage.stageHeight = 600;
			stage.color = 0xffffff;
		}


		private function createStatusText():void {
			_statusText = new TextField();
			_statusText.width = 400;
			_statusText.height = 25;
			_statusText.x = (stage.stageWidth - _statusText.width) / 2;
			_statusText.y = 150;

			var statusTextFormat:TextFormat = new TextFormat();
			statusTextFormat.color = 0xeeeeee;
			statusTextFormat.font = "Verdana";
			statusTextFormat.align = TextFormatAlign.CENTER;
			statusTextFormat.size = 16;
			_statusText.defaultTextFormat = statusTextFormat;
			_statusText.wordWrap = false;
			_statusText.opaqueBackground = 0x999999;
			_statusText.selectable = false;

			_statusText.text = "Initializing...";

			addChild(_statusText);
		}


		private function createProgressBar():void {
			_progressBarRect = new Shape();
			_progressBarRect.graphics.beginFill(0x000000, 0);
			_progressBarRect.graphics.lineStyle(2, 0x000000);
			_progressBarRect.graphics.drawRect(0, 0, 400, 30);
			_progressBarRect.graphics.endFill();

			_progressBarRect.x = (stage.stageWidth - _progressBarRect.width) / 2;
			_progressBarRect.y = 100;

			addChild(_progressBarRect);

			_progressBar = new Shape();
			_progressBar.graphics.beginFill(0x0000ee);
			_progressBar.graphics.drawRect(0, 0, 391, 21);
			_progressBar.x = _progressBarRect.x + 4;
			_progressBar.y = _progressBarRect.y + 4;

			addChild(_progressBar);

			_progressBar.scaleX = 0;
		}

		private function setPercentComplete(percentComplete:int):void {
			if (_currentPercentComplete == percentComplete)
				return;

			_currentPercentComplete = percentComplete;
			invalidateValue();
		}


		private function invalidateValue():void {
			if (_needsValidation)
				return;

			_needsValidation = true;
			addEventListener(Event.EXIT_FRAME, validate);
		}

		private function validate(event:Event):void {
			removeEventListener(Event.EXIT_FRAME, validate);
			_needsValidation = false;

			_redrawProgressBar();
		}

		private function _redrawProgressBar():void {
			_progressBar.scaleX = _currentPercentComplete / 100;
		}
	}
}