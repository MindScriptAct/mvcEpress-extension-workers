package org.mvcexpress.extensions.workers.modules {
import flash.display.Sprite;
import flash.events.Event;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.utils.ByteArray;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;
import flash.utils.setInterval;

import org.mvcexpress.core.namespace.pureLegsCore;

public class ModuleWorkerBase extends Sprite {


	private static const MODULE_NAME_KEY:String = "$_moduleName_$";
	private static const MODULE_CLASS_NAME_KEY:String = "$_moduleClassName_$";

	public static const debug_coreId:int = Math.random() * 100000000;

	public var debug_objectID:int = Math.random() * 100000000;

	private static var $primordialBytes:ByteArray;

	private var moduleName:String;

	pureLegsCore static var canInitChildModule:Boolean = false;

//	private var sendMessageChannels:Vector.<MessageChannel> = new <MessageChannel>[];
//	private var messageChannelsRegistry:Dictionary = new Dictionary();


	pureLegsCore function checkWorker(moduleName:String):Boolean {
		use namespace pureLegsCore;

		this.moduleName = moduleName;
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: CONSTRUCT, 'primordial:", Worker.current.isPrimordial);
		if (Worker.current.isPrimordial) { // check if primordial.
			if ($primordialBytes) { // check if grimordial bytes are already stored.
				throw Error("Only first(main) ModuleWorker can be instantiated. Use createWorker(MyBackgroundWorkerModule) to create background workers. ");
			} else {
				// handle primordial worker.
				$primordialBytes = this.loaderInfo.bytes;
				CONFIG::debug {
					if (!moduleName) {
						throw Error("Worker must have not empty moduleName. (It is used for module to module communication.)");
					}
				}
				Worker.current.setSharedProperty(MODULE_NAME_KEY, moduleName);
			}
		} else {
			trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: can init child module?:", ModuleWorkerBase.canInitChildModule);
			// check if this is temp copy of the main swf
			if (!ModuleWorkerBase.canInitChildModule) {
				// not primordial copy of the main module.
				var childModuleClassDefinition:String = Worker.current.getSharedProperty(MODULE_CLASS_NAME_KEY);
				trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: moduleClass:", childModuleClassDefinition);
				if (childModuleClassDefinition) {
					Worker.current.setSharedProperty(MODULE_CLASS_NAME_KEY, null);

					var childModuleClass:Class = getDefinitionByName(childModuleClassDefinition) as Class;

					ModuleWorkerBase.canInitChildModule = true;
					var childModule:ModuleWorker = new childModuleClass();
					ModuleWorkerBase.canInitChildModule = true;
				}
				return false;
			} else {
				// not primordial child module.
				Worker.current.setSharedProperty(MODULE_NAME_KEY, moduleName);
//				setUpWorkerChildCommunication();

				/**
				 * Start Worker thread
				 **/
					//Inside of our worker, we can use static methods to
					//access the shared messgaeChannel's
				debug_mainToWorker = Worker.current.getSharedProperty("mainToWorker");
				debug_workerToMain = Worker.current.getSharedProperty("workerToMain");
				//Listen for messages from the mian thread
				debug_mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, debug_onMainToWorker);

				setInterval(debug_CommunicationWorker, 500);

			}
		}
		return true;
	}


	public var debug_mainToWorker:MessageChannel;
	public var debug_workerToMain:MessageChannel;

	public var childWorker:Worker;

	public function debug_CommunicationMain():void {
		trace("MAIN TEST");
		debug_mainToWorker.send("Main > worker...")
	}

	public function debug_CommunicationWorker():void {
		trace("WORKER TEST");
		debug_workerToMain.send("Worker > main...")
	}

	//Main >> Worker
	public function debug_onMainToWorker(event:Event):void {
		trace("[Worker] " + debug_mainToWorker.receive());
	}

	//Worker >> Main
	public function debug_onWorkerToMain(event:Event):void {
		trace("[Worker] " + debug_workerToMain.receive());
	}

	// TODO : consider creating it as static public funcion.
	protected function startWorkerModule(workerModuleClass:Class):void {
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: startWorkerModule: " + workerModuleClass, "isPrimordial:" + Worker.current.isPrimordial);
		if (Worker.current.isPrimordial) {
			var childWorker:Worker = WorkerDomain.current.createWorker($primordialBytes);
			childWorker.addEventListener(Event.WORKER_STATE, workerStateHandler);
			childWorker.setSharedProperty(MODULE_CLASS_NAME_KEY, getQualifiedClassName(workerModuleClass));
			//
			connectChildWorker(childWorker);
			//
			childWorker.start();
		} else {
			throw Error("Starting child workers from other child workers not supported yet.)");
		}

	}


	private function workerStateHandler(event:Event):void {
		var childWorker:Worker = event.target as Worker;
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: workerStateHandler- " + childWorker.state);
	}

	public function debug_getModuleName():String {
		var retVal:String = Worker.current.getSharedProperty(MODULE_NAME_KEY);
		Worker.current.setSharedProperty(MODULE_NAME_KEY, retVal);
		return retVal;
	}


	private function connectChildWorker(childWorker:Worker):void {
//		var workers:Vector.<Worker> = WorkerDomain.current.listWorkers();
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "connectChildWorker " + childWorker, "with", workers);
//		for (var i:int = 0; i < workers.length; i++) {
//			var worker:Worker = workers[i];
//			var workerModuleName:String = worker.getSharedProperty(MODULE_NAME_KEY);
//			worker.setSharedProperty(MODULE_NAME_KEY, workerModuleName);
//			//
//			if (!messageChannelsRegistry[workerModuleName]) {
//				var workerToChild:MessageChannel = worker.createMessageChannel(childWorker);
//				var childToWorker:MessageChannel = childWorker.createMessageChannel(worker);
//				//
//				childWorker.setSharedProperty("FROM_" + workerModuleName, workerToChild);
//				childWorker.setSharedProperty("TO_" + workerModuleName, childToWorker);
//				//
//				childToWorker.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);
//
//				workerToChild.send("debug_MAIN->CHILD");
//			}
//


		if (childWorker) {
			//	Create worker from our own loaderInfo.bytes
			trace(childWorker);
			//Create messaging channels for 2-way messaging
			debug_mainToWorker = Worker.current.createMessageChannel(childWorker);
			debug_workerToMain = childWorker.createMessageChannel(Worker.current);

			//Inject messaging channels as a shared property
			childWorker.setSharedProperty("mainToWorker", debug_mainToWorker);
			childWorker.setSharedProperty("workerToMain", debug_workerToMain);

			//Listen to the response from our worker
			debug_workerToMain.addEventListener(Event.CHANNEL_MESSAGE, debug_onWorkerToMain);

			//Set an interval that will ask the worker thread to do some math
			setInterval(debug_CommunicationMain, 500);
		}

	}


//		var testChannel:MessageChannel = Worker.current.createMessageChannel(childWorker);
////		var testChannel:MessageChannel = childWorker.createMessageChannel(Worker.current);
//		testChannel.addEventListener(Event.CHANNEL_MESSAGE, handleTest);
//		childWorker.setSharedProperty("testSharedChannel", testChannel);
//	}

//	private function handleTest(event:Event):void {
//		trace("oooooooooooooooooooooooooo...................");
//	}


//	private function setUpWorkerChildCommunication():void {
//		var workers:Vector.<Worker> = WorkerDomain.current.listWorkers();
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "setUpWorkerCommunication " + workers);
//		var childWorker:Worker = Worker.current;
//		for (var i:int = 0; i < workers.length; i++) {
//			var worker:Worker = workers[i];
//			// TODO : decide what to do with self send messages...
//			if (worker != Worker.current) {
//				var workerModuleName:String = worker.getSharedProperty(MODULE_NAME_KEY);
//				worker.setSharedProperty(MODULE_NAME_KEY, workerModuleName);
//				//trace(workerModuleName);
//				if (!messageChannelsRegistry[workerModuleName]) {
//					var workerToThis:MessageChannel = childWorker.getSharedProperty("FROM_" + workerModuleName);
//					var thisToWorker:MessageChannel = childWorker.getSharedProperty("TO_" + workerModuleName);
//					//
////					workerToThis.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);
////					sendMessageChannels.push(thisToWorker);
////					messageChannelsRegistry[workerModuleName] = thisToWorker;
//					//
//					//workerToThis.send("Child with name:" + moduleName + " is set up!");
//				} else {
//					throw Error("2 workers with same name should not exist.");
//				}
//			}
//		}
//
//		var mainChanel:MessageChannel = Worker.current.getSharedProperty("testSharedChannel") as MessageChannel;
//		//mainChanel.send("WTF...");
//
//	}


//	private function handleChannelMessage(event:Event):void {
//		var channel:MessageChannel = event.target as MessageChannel;
//		var data:Object = channel.receive();
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "handleChannelMessage " + event, data);
//	}


//	protected function demo_sendMessage(obj:Object):void {
//		for (var i:int = 0; i < sendMessageChannels.length; i++) {
//			sendMessageChannels[i].send(obj);
//		}
//	}
}
}
