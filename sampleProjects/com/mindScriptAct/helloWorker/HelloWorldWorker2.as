package com.mindScriptAct.helloWorker {
import com.mindScriptAct.binaryTest.DemoWorkerProxy;

import flash.display.Sprite;
import flash.events.Event;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.getDefinitionByName;
import flash.utils.setTimeout;

//import flash.system.MessageChannel;
//import flash.system.Worker;
//import flash.system.WorkerDomain;
public class HelloWorldWorker2 extends Sprite {


	private static var isWorkersDefined:Boolean = false;
	private static var isWorkersSupported:Boolean = false;

	public static var MessageChannelClass:Class;
	public static var WorkerClass:Class;
	public static var WorkerDomainClass:Class;


	protected var debug_mainToWorker:Object;
	protected var debug_workerToMain:Object;

	protected var debug_worker:Object;

	private var proxyTest:DemoWorkerProxy;

	public function HelloWorldWorker2() {

		if (!isWorkersDefined) {
			isWorkersDefined = true;

			try {
				MessageChannelClass = getDefinitionByName("flash.system.MessageChannel") as Class;
				WorkerClass = getDefinitionByName("flash.system.Worker") as Class;
				WorkerDomainClass = getDefinitionByName("flash.system.WorkerDomain") as Class;
			} catch (error:Error) {
				// do nothing.
			}

			if (WorkerClass) {
				isWorkersSupported = true;
			}
		}


		trace("hi");
		/**
		 * Start Main thread
		 **/

		trace("WorkerClass:", WorkerClass, isWorkersSupported);
		if (isWorkersSupported) {


			trace("isPrimordial?", WorkerClass.current.isPrimordial);
			if (WorkerClass.current.isPrimordial) {
				//Create worker from our own loaderInfo.bytes
				debug_worker = WorkerDomainClass.current.createWorker(this.loaderInfo.bytes);
				trace(debug_worker);
				//Create messaging channels for 2-way messaging
				debug_mainToWorker = WorkerClass.current.createMessageChannel(debug_worker);
				debug_workerToMain = debug_worker.createMessageChannel(WorkerClass.current);

				//Inject messaging channels as a shared property
				debug_worker.setSharedProperty("mainToWorker", debug_mainToWorker);
				debug_worker.setSharedProperty("workerToMain", debug_workerToMain);

				//Listen to the response from our worker
				debug_workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);

				//Start worker (re-run document class)
				debug_worker.start();


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
				debug_mainToWorker = WorkerClass.current.getSharedProperty("mainToWorker");
				debug_workerToMain = WorkerClass.current.getSharedProperty("workerToMain");
				//Listen for messages from the mian thread
				debug_mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);

				setTimeout(debugCommunicationWorker, 2000);

				registerClassAlias('com.mindScriptAct.helloWorker.HelloDataVO', HelloDataVO);
			}
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