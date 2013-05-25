package com.mindScriptAct.helloWorker {
import flash.display.Sprite;
import flash.events.Event;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.utils.setInterval;

public class HelloWorldWorker extends Sprite {
	protected var debug_mainToWorker:MessageChannel;
	protected var debug_workerToMain:MessageChannel;

	protected var debugf_worker:Worker;

	public function HelloWorldWorker() {
		trace("hi");
		/**
		 * Start Main thread
		 **/
		trace("isPrimordial?", Worker.current.isPrimordial);
		if (Worker.current.isPrimordial) {
			//Create worker from our own loaderInfo.bytes
			debugf_worker = WorkerDomain.current.createWorker(this.loaderInfo.bytes);
			trace(debugf_worker);
			//Create messaging channels for 2-way messaging
			debug_mainToWorker = Worker.current.createMessageChannel(debugf_worker);
			debug_workerToMain = debugf_worker.createMessageChannel(Worker.current);

			//Inject messaging channels as a shared property
			debugf_worker.setSharedProperty("mainToWorker", debug_mainToWorker);
			debugf_worker.setSharedProperty("workerToMain", debug_workerToMain);

			//Listen to the response from our worker
			debug_workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);

			//Start worker (re-run document class)
			debugf_worker.start();


			//Set an interval that will ask the worker thread to do some math
			setInterval(debugCommunicationMain, 2000);

		} else {
			/**
			 * Start Worker thread
			 **/
				//Inside of our worker, we can use static methods to
				//access the shared messgaeChannel's
			debug_mainToWorker = Worker.current.getSharedProperty("mainToWorker");
			debug_workerToMain = Worker.current.getSharedProperty("workerToMain");
			//Listen for messages from the mian thread
			debug_mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);

			setInterval(debugCommunicationWorker, 2000);
		}
	}

	private function debugCommunicationMain():void {
		trace("MAIN TEST");
		debug_mainToWorker.send("Main > worker...")
	}

	private function debugCommunicationWorker():void {
		trace("WORKER TEST");
		debug_workerToMain.send("Worker > main...")
	}

	//Main >> Worker
	protected function onMainToWorker(event:Event):void {
		trace("[Worker] " + debug_mainToWorker.receive());
	}

	//Worker >> Main
	protected function onWorkerToMain(event:Event):void {
		trace("[Worker] " + debug_workerToMain.receive());
	}
}
}