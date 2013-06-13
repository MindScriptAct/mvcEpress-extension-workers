package com.mindScriptAct.helloWorker {
import flash.display.Sprite;
import flash.events.Event;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.utils.getDefinitionByName;
import flash.utils.getTimer;
import flash.utils.setTimeout;

public class HelloManyWorker extends Sprite {

	protected var debug_mainToWorkers:Vector.<MessageChannel> = new <MessageChannel>[];
	protected var debug_workerToMains:Vector.<MessageChannel> = new <MessageChannel>[];

	protected var debug_workers:Vector.<Worker> = new <Worker>[];
	private var primeTestNr:Number;

	public function HelloManyWorker() {
		trace("hi");
		/**
		 * Start Main thread
		 **/
		trace("isPrimordial?", Worker.current.isPrimordial);
		if (Worker.current.isPrimordial) {


			setTimeout(createWorker, 1000);

		} else {
			/**
			 * Start Worker thread
			 **/
			//Inside of our worker, we can use static methods to
			//access the shared messgaeChannel's

			var debug_mainToWorker:MessageChannel = Worker.current.getSharedProperty("mainToWorker");
			var debug_workerToMain:MessageChannel = Worker.current.getSharedProperty("workerToMain");

			//Listen for messages from the mian thread
			debug_mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);


			primeTestNr = 123456789;

//			this.addEventListener(Event.ENTER_FRAME, handleTick)

		}
	}

	private function handleTick(event:Event):void {

//		primeTestNr++;
//
//		for(var i:int = 2; i < primeTestNr; i++) {
//			if () {
//
//			}
//		}

		var timer:int = getTimer();

//		trace("handleTick" + timer);

		while (timer + 5000 > getTimer()) {
			var tang:Number = Math.tan(Math.random());
		}

	}

	private function createWorker():void {

		trace("create worker");

		//Create worker from our own loaderInfo.bytes
		var worker:Worker = WorkerDomain.current.createWorker(this.loaderInfo.bytes);

		//Create messaging channels for 2-way messaging
		var debug_mainToWorker:MessageChannel = Worker.current.createMessageChannel(worker)
		var debug_workerToMain:MessageChannel = worker.createMessageChannel(Worker.current)

		debug_mainToWorkers.push(debug_mainToWorker);
		debug_workerToMains.push(debug_workerToMain);

		//Inject messaging channels as a shared property
		worker.setSharedProperty("mainToWorker", debug_mainToWorker);
		worker.setSharedProperty("workerToMain", debug_workerToMain);

		//Listen to the response from our worker
		debug_workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);

		//Start worker (re-run document class)
		worker.start();

		debug_workers.push(worker);

		setTimeout(createWorker, 6000);
	}


	//Main >> Worker
	protected function onMainToWorker(event:Event):void {
	}

	//Worker >> Main
	protected function onWorkerToMain(event:Event):void {
	}
}
}