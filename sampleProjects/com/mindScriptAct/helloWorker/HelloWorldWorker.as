package com.mindScriptAct.helloWorker {
import com.mindScriptAct.binaryTest.DemoWorkerProxy;

import flash.display.Sprite;
import flash.events.Event;
import flash.net.registerClassAlias;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

public class HelloWorldWorker extends Sprite {
	protected var debug_mainToWorker:MessageChannel;
	protected var debug_workerToMain:MessageChannel;

	protected var debugf_worker:Worker;

	private var proxyTest:DemoWorkerProxy;

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


			registerClassAlias('com.mindScriptAct.helloWorker.HelloDataVO', HelloDataVO);

			registerClassAlias("com.mindScriptAct.binaryTest.DemoWorkerProxy", DemoWorkerProxy);

			//Set an interval that will ask the worker thread to do some math
			setTimeout(debugCommunicationMain, 1000);

			setTimeout(initSharedProxy, 500);

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

			setTimeout(debugCommunicationWorker, 2000);

			registerClassAlias('com.mindScriptAct.helloWorker.HelloDataVO', HelloDataVO);
		}
	}


	private function initSharedProxy():void {
		proxyTest = new DemoWorkerProxy();
		proxyTest.publicVar = "data1";
		proxyTest.getSetVar = "data2";
		proxyTest.setCustomGetterSetterVar("data3");

		var testBytes:ByteArray = new ByteArray();
		testBytes.writeObject(proxyTest);
		testBytes.shareable = true;


		debug_mainToWorker.send("SHARED_PPROXY_COMMING");
		debug_mainToWorker.send(proxyTest);

	}

	private function debugCommunicationMain():void {
//		debug_mainToWorker.send("Main > worker...");
		var mainData:HelloDataVO = new HelloDataVO();
		mainData.data = "Main > worker...";
		trace("MAIN SEND>", mainData);
//		registerClassAlias('com.mindScriptAct.helloWorker.HelloDataVO', HelloDataVO);
		debug_mainToWorker.send(mainData);

		setTimeout(debugCommunicationMain, 2000);
	}

	private function debugCommunicationWorker():void {
//		debug_workerToMain.send("Worker > main...")
		var mainData:HelloDataVO = new HelloDataVO();
		mainData.data = "Worker > main...";
		trace("WORKER SEND>", mainData);
//		registerClassAlias('com.mindScriptAct.helloWorker.HelloDataVO', HelloDataVO);
		debug_workerToMain.send(mainData);

		setTimeout(debugCommunicationWorker, 2000);
	}

	//Main >> Worker
	protected function onMainToWorker(event:Event):void {
		var obj:Object = debug_mainToWorker.receive();
		if (obj != null) {
			if (obj == "SHARED_PPROXY_COMMING") {
				var testProxy:Object = debug_mainToWorker.receive();
				var biteProxy:Object = debug_mainToWorker.receive();
				proxyTest = testProxy as DemoWorkerProxy;
				trace("Proxy data... ", testProxy);
				trace("Proxy received... ", proxyTest);
			} else {
				trace("[Worker] " + obj);
			}
		}
	}

	//Worker >> Main
	protected function onWorkerToMain(event:Event):void {
		trace("[Main] " + debug_workerToMain.receive());
	}
}
}