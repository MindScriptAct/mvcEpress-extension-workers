package com.mindScriptAct.helloWorker {
import flash.display.Sprite;
import flash.events.Event;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.utils.setInterval;

public class HelloWorldWorker2 extends Sprite {
	protected var mainToWorker:MessageChannel;
	protected var workerToMain:MessageChannel;

	protected var worker:Worker;

	public function HelloWorldWorker2() {
		/**
		 * Start Main thread
		 **/
		if (Worker.current.isPrimordial) {
			//Create worker from our own loaderInfo.bytes
			worker = WorkerDomain.current.createWorker(this.loaderInfo.bytes);

			//Create messaging channels for 2-way messaging
			mainToWorker = Worker.current.createMessageChannel(worker);
			workerToMain = worker.createMessageChannel(Worker.current);

			//Inject messaging channels as a shared property
			worker.setSharedProperty("mainToWorker", mainToWorker);
			worker.setSharedProperty("workerToMain", workerToMain);

			//Listen to the response from our worker
			workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);

			//Start worker (re-run document class)
			worker.start();


			//Set an interval that will ask the worker thread to do some math
			setInterval(function () {
				mainToWorker.send("ADD");
				mainToWorker.send(2);
				mainToWorker.send(2);
			}, 1000);

		}
		/**
		 * Start Worker thread
		 **/
		else {

			//Inside of our worker, we can use static methods to
			//access the shared messgaeChannel's
			mainToWorker = Worker.current.getSharedProperty("mainToWorker");
			workerToMain = Worker.current.getSharedProperty("workerToMain");
			//Listen for messages from the mian thread
			mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
		}
	}

	//Main >> Worker
	protected function onMainToWorker(event:Event):void {
		var msg:* = mainToWorker.receive();
		//When the main thread sends us HELLO, we'll send it back WORLD
		if (msg == "HELLO") {
			workerToMain.send("WORLD");
		}
		else if (msg == "ADD") {
			//Receive the 2 numbers and add them together
			var result:int = mainToWorker.receive() + mainToWorker.receive();
			//Return the result to the main thread
			workerToMain.send(result);
		}
	}

	//Worker >> Main
	protected function onWorkerToMain(event:Event):void {
		//Trace out whatever message the worker has sent us.
		trace("[Worker] " + workerToMain.receive());
	}
}
}