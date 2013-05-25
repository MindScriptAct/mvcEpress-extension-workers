package org.mvcexpress.extensions.workers.modules {
import flash.display.Sprite;
import flash.events.Event;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import org.mvcexpress.core.namespace.pureLegsCore;

public class ModuleWorkerBase extends Sprite {


	private static const MODULE_NAME_KEY:String = "$_moduleName_$";
	private static const MODULE_CLASS_NAME_KEY:String = "$_moduleClassName_$";
	private static const INIT_REMOTE_WORKER:String = "$_init_remote_worker_$";

	public static const debug_coreId:int = Math.random() * 100000000;

	public var debug_objectID:int = Math.random() * 100000000;

	private static var $primordialBytes:ByteArray;

	private var moduleName:String;

	pureLegsCore static var canInitChildModule:Boolean = false;

	private var sendMessageChannels:Vector.<MessageChannel> = new <MessageChannel>[];

	// todo : check if needed.
	private var receiveMessageChannels:Vector.<MessageChannel> = new <MessageChannel>[];
	// todo : check if needed.
	private var messageChannelsWorkerNames:Vector.<String> = new <String>[];

	private var messageSendChannelsRegistry:Dictionary = new Dictionary();


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

				setUpWorkerChildCommunication();


				setInterval(debug_CommunicationWorker, 1000);

			}
		}
		return true;
	}


	// TODO : consider creating it as static public funcion.
	protected function startWorkerModule(workerModuleClass:Class):void {
		// TODO : check extended form workerModule class.

		//
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: startWorkerModule: " + workerModuleClass, "isPrimordial:" + Worker.current.isPrimordial);
		if (Worker.current.isPrimordial) {
			var thisWorker:Worker = WorkerDomain.current.createWorker($primordialBytes);
			thisWorker.addEventListener(Event.WORKER_STATE, workerStateHandler);
			thisWorker.setSharedProperty(MODULE_CLASS_NAME_KEY, getQualifiedClassName(workerModuleClass));
			//
			connectRemoteWorker(thisWorker);
			//
			thisWorker.start();
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


	private var debug_1:MessageChannel;
	private var debug_2:MessageChannel;


	private function connectRemoteWorker(remoteWorker:Worker):void {
		var workers:Vector.<Worker> = WorkerDomain.current.listWorkers();
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "connectChildWorker " + remoteWorker, "with", workers);
		for (var i:int = 0; i < workers.length; i++) {
			var worker:Worker = workers[i];
			// get model name from worker.
			var workerModuleName:String = worker.getSharedProperty(MODULE_NAME_KEY);
			worker.setSharedProperty(MODULE_NAME_KEY, workerModuleName);
			//
			if (!messageSendChannelsRegistry[workerModuleName]) {
				var debug_mainToWorker:MessageChannel = worker.createMessageChannel(remoteWorker);
				var debug_workerToMain:MessageChannel = remoteWorker.createMessageChannel(worker);

				debug_1 = debug_mainToWorker;
				debug_2 = debug_workerToMain;

				remoteWorker.setSharedProperty("FROM_" + workerModuleName, debug_mainToWorker);
				remoteWorker.setSharedProperty("TO_" + workerModuleName, debug_workerToMain);

				//Listen to the response from our worker
				debug_workerToMain.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);

				//Set an interval that will ask the worker thread to do some math
				setTimeout(initChildDebug, 500);
			}
		}
	}

	private function initChildDebug():void {
		setInterval(debug_CommunicationMain, 1000);
	}


	private function setUpWorkerChildCommunication():void {
		var workers:Vector.<Worker> = WorkerDomain.current.listWorkers();
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "setUpWorkerCommunication " + workers);

		var thisWorker:Worker = Worker.current;
		for (var i:int = 0; i < workers.length; i++) {
			var worker:Worker = workers[i];
			// TODO : decide what to do with self send messages...
			if (worker != Worker.current) {
				var workerModuleName:String = worker.getSharedProperty(MODULE_NAME_KEY);
				worker.setSharedProperty(MODULE_NAME_KEY, workerModuleName);
				//trace(workerModuleName);
				if (!messageSendChannelsRegistry[workerModuleName]) {
					var workerToThis:MessageChannel = thisWorker.getSharedProperty("FROM_" + workerModuleName);
					var thisToWorker:MessageChannel = thisWorker.getSharedProperty("TO_" + workerModuleName);
//					//
					messageSendChannelsRegistry[workerModuleName] = thisToWorker;

					sendMessageChannels.push(thisToWorker);
					receiveMessageChannels.push(workerToThis);
					messageChannelsWorkerNames.push(workerModuleName);

					workerToThis.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);

//					debug_mainToWorker = workerToThis;
//					debug_workerToMain = thisToWorker;


					worker.setSharedProperty("FROM_" + moduleName, thisToWorker);
					worker.setSharedProperty("TO_" + moduleName, workerToThis);

					thisToWorker.send(INIT_REMOTE_WORKER);
					thisToWorker.send(moduleName);
				} else {
					throw Error("2 workers with same name should not exist.");
				}
			}
		}

//		var mainChanel:MessageChannel = Worker.current.getSharedProperty("testSharedChannel") as MessageChannel;
//		//mainChanel.send("WTF...");
//

		/**
		 * Start Worker thread
		 **/
		//Inside of our worker, we can use static methods to
		//access the shared messgaeChannel's

	}

//	private function handleChannelMessage(event:Event):void {
//		var channel:MessageChannel = event.target as MessageChannel;
//		var data:Object = channel.receive();
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "handleChannelMessage " + event, data);
//	}

	private function handleChannelMessage(event:Event):void {
		var channel:MessageChannel = event.target as MessageChannel;
		var messageType:Object = channel.receive();
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "handleChannelMessage " + event, messageType);


//		var remoteModelName:String = data.moduleName;
//		trace(remoteModelName);
		if (messageType == INIT_REMOTE_WORKER) {
			var remoteModuleName:String = channel.receive();

			trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "handle child module init! ", remoteModuleName);

			var thisWorker:Worker = Worker.current;

			var workerToThis:MessageChannel = thisWorker.getSharedProperty("FROM_" + remoteModuleName);
			var thisToWorker:MessageChannel = thisWorker.getSharedProperty("TO_" + remoteModuleName);


//			trace(thisToWorker == debug_mainToWorker);
//			trace(workerToThis == debug_workerToMain);


			messageSendChannelsRegistry[remoteModuleName] = thisToWorker;

			sendMessageChannels.push(thisToWorker);
			receiveMessageChannels.push(workerToThis);
			messageChannelsWorkerNames.push(remoteModuleName);


		}
	}


	protected function demo_sendMessage(obj:Object):void {
		trace("demo_sendMessage", obj);
		for (var i:int = 0; i < sendMessageChannels.length; i++) {
			sendMessageChannels[i].send(obj);
		}
	}

//	public var childWorker:Worker;

	public function debug_CommunicationMain():void {
		trace("MAIN TEST");
		demo_sendMessage("Main > worker...");
	}

	public function debug_CommunicationWorker():void {
		trace("WORKER TEST");
		demo_sendMessage("Worker > main...");
	}

}
}
