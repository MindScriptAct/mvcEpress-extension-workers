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

import org.mvcexpress.core.ModuleBase;
import org.mvcexpress.core.ModuleManager;
import org.mvcexpress.core.namespace.pureLegsCore;
import org.mvcexpress.extensions.workers.core.messenger.MessengerWorker;

public class ModuleWorkerBase extends Sprite {


	private static const MODULE_NAME_KEY:String = "$_moduleName_$";
	private static const MODULE_CLASS_NAME_KEY:String = "$_moduleClassName_$";
	private static const INIT_REMOTE_WORKER:String = "$_init_remote_worker_$";


	// bytes of main swf file. Used for creating workers.
	private static var $primordialBytes:ByteArray;

	pureLegsCore static var canInitChildModule:Boolean = false;

	// channels for all remote workres to send data to them.
	private static var $sendMessageChannels:Vector.<MessageChannel> = new <MessageChannel>[];

	// todo : check if needed.
	private var receiveMessageChannels:Vector.<MessageChannel> = new <MessageChannel>[];
	private var messageSendChannelsRegistry:Dictionary = new Dictionary();
	private var messageChannelsWorkerNames:Vector.<String> = new <String>[];

	// store messageChannels so they don't get garbage collected while they are handled by remote worker.
	private var tempChannelStorage:Vector.<MessageChannel> = new <MessageChannel>[];


	private var debug_moduleName:String;
	public static const debug_coreId:int = Math.random() * 100000000;
	public var debug_objectID:int = Math.random() * 100000000;
	private var debug_doDebugging:Boolean = false;


	pureLegsCore function handleWorker(moduleName:String):Boolean {

		use namespace pureLegsCore;

		this.debug_moduleName = moduleName;
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: CONSTRUCT, 'primordial:", Worker.current.isPrimordial);
		//
		if (Worker.current.isPrimordial) { // check if primordial.
			if ($primordialBytes) { // check if primordial bytes are already stored.
				throw Error("Only first(main) ModuleWorker can be instantiated. Use createWorker(MyBackgroundWorkerModule) to create background workers. ");
			} else {
				// PRIMORDIAL, MAIN.
				$primordialBytes = this.loaderInfo.bytes;
				CONFIG::debug {
					if (!moduleName) {
						throw Error("Worker must have not empty moduleName. (It is used for module to module communication.)");
					}
				}
				Worker.current.setSharedProperty(MODULE_NAME_KEY, moduleName);
				//
				// init custom scoped messenger
				ModuleManager.getScopeMessenger(moduleName, MessengerWorker);
			}
		} else {
			trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: can init child module?:", ModuleWorkerBase.canInitChildModule);
			// check if this is temp copy of the main swf
			if (!ModuleWorkerBase.canInitChildModule) {
				// NOT PRIMORDIAL, COPY OF THE MAIN.
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
				// NOT PRIMORDIAL, CHILD MODULE.
				Worker.current.setSharedProperty(MODULE_NAME_KEY, moduleName);

				setUpRemoteWorkerCommunication();

				// todo: debug
				if (debug_doDebugging) {
					setInterval(debug_CommunicationWorker, 1000);
				}
			}
		}
		return true;
	}


	// TODO : consider creating it as static public funcion.
	protected function startWorkerModule(workerModuleClass:Class):void {
		// TODO : check extended form workerModule class.

		//
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + debug_moduleName + "]" + "ModuleWorkerBase: startWorkerModule: " + workerModuleClass, "isPrimordial:" + Worker.current.isPrimordial);
		if (Worker.current.isPrimordial) {
			var remoteWorker:Worker = WorkerDomain.current.createWorker($primordialBytes);
			// todo : debug
			remoteWorker.addEventListener(Event.WORKER_STATE, debug_workerStateHandler);
			remoteWorker.setSharedProperty(MODULE_CLASS_NAME_KEY, getQualifiedClassName(workerModuleClass));
			//
			connectRemoteWorker(remoteWorker);
			//
			remoteWorker.start();
		} else {
			throw Error("Starting other workers only possible from main(primordial) worker.)");
		}
	}


	private function debug_workerStateHandler(event:Event):void {
		var childWorker:Worker = event.target as Worker;
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + debug_moduleName + "]" + "ModuleWorkerBase: workerStateHandler- " + childWorker.state);
	}

	public function debug_getModuleName():String {
		var retVal:String = Worker.current.getSharedProperty(MODULE_NAME_KEY);
		Worker.current.setSharedProperty(MODULE_NAME_KEY, retVal);
		return retVal;
	}

	private function connectRemoteWorker(remoteWorker:Worker):void {
		// get all running workers
		var workers:Vector.<Worker> = WorkerDomain.current.listWorkers();
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + debug_moduleName + "]" + "connectChildWorker " + remoteWorker, "with", workers);
		//
		for (var i:int = 0; i < workers.length; i++) {
			var worker:Worker = workers[i];
			//
			// get model name from worker.
			var workerModuleName:String = worker.getSharedProperty(MODULE_NAME_KEY);
			worker.setSharedProperty(MODULE_NAME_KEY, workerModuleName);
			//
			if (!messageSendChannelsRegistry[workerModuleName]) {
				var workerToRemote:MessageChannel = worker.createMessageChannel(remoteWorker);
				var remoteToWorker:MessageChannel = remoteWorker.createMessageChannel(worker);

				// store so they don't get garabage collected.
				tempChannelStorage.push(workerToRemote);
				tempChannelStorage.push(remoteToWorker);

				//
				remoteWorker.setSharedProperty("workerToRemote_" + workerModuleName, workerToRemote);
				remoteWorker.setSharedProperty("remoteToWorker_" + workerModuleName, remoteToWorker);

				//Listen to the response from our worker
				remoteToWorker.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);

				// todo : debug
				if (debug_doDebugging) {
					setTimeout(debug_initChildDebug, 500);
				}
			}
		}
	}

	private function debug_initChildDebug():void {
		setInterval(debug_CommunicationMain, 1000);
	}


	private function setUpRemoteWorkerCommunication():void {
		// get all workers
		var workers:Vector.<Worker> = WorkerDomain.current.listWorkers();
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + debug_moduleName + "]" + "setUpWorkerCommunication " + workers);
		//
		var thisWorker:Worker = Worker.current;
		for (var i:int = 0; i < workers.length; i++) {
			var worker:Worker = workers[i];
			// TODO : decide what to do with self send messages...
			if (worker != Worker.current) {
				var workerModuleName:String = worker.getSharedProperty(MODULE_NAME_KEY);
				worker.setSharedProperty(MODULE_NAME_KEY, workerModuleName);
				//trace(workerModuleName);
				// handle communication permissions
				use namespace pureLegsCore;

				ModuleManager.registerScope(debug_moduleName, workerModuleName, true, true, false);
				//
				if (!messageSendChannelsRegistry[workerModuleName]) {
					var workerToThis:MessageChannel = thisWorker.getSharedProperty("workerToRemote_" + workerModuleName);
					var thisToWorker:MessageChannel = thisWorker.getSharedProperty("remoteToWorker_" + workerModuleName);
					//
					messageSendChannelsRegistry[workerModuleName] = thisToWorker;

					$sendMessageChannels.push(thisToWorker);
					receiveMessageChannels.push(workerToThis);
					messageChannelsWorkerNames.push(workerModuleName);

					workerToThis.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);

					worker.setSharedProperty("thisToWorker_" + debug_moduleName, thisToWorker);
					worker.setSharedProperty("workerToThis_" + debug_moduleName, workerToThis);

					thisToWorker.send(INIT_REMOTE_WORKER);
					thisToWorker.send(debug_moduleName);
				} else {
					throw Error("2 workers with same name should not exist.");
				}
			}
		}

	}

	private function handleChannelMessage(event:Event):void {
		var channel:MessageChannel = event.target as MessageChannel;
		var messageType:String = channel.receive();
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + debug_moduleName + "]" + "handleChannelMessage " + event, messageType);
		if (messageType) {


			if (messageType == INIT_REMOTE_WORKER) {
				var remoteModuleName:String = channel.receive();

				use namespace pureLegsCore;

				// init custom scoped messenger
				ModuleManager.getScopeMessenger(remoteModuleName, MessengerWorker);
				//ModuleManager.getScopeMessenger(remoteModuleName, MessengerWorker);

				ModuleManager.registerScope(debug_moduleName, remoteModuleName, true, true, false);

				trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + debug_moduleName + "]" + "handle child module init! ", remoteModuleName);

				var thisWorker:Worker = Worker.current;

				var workerToThis:MessageChannel = thisWorker.getSharedProperty("thisToWorker_" + remoteModuleName);
				var thisToWorker:MessageChannel = thisWorker.getSharedProperty("workerToThis_" + remoteModuleName);

				messageSendChannelsRegistry[remoteModuleName] = thisToWorker;

				$sendMessageChannels.push(thisToWorker);
				receiveMessageChannels.push(workerToThis);
				messageChannelsWorkerNames.push(remoteModuleName);

				// remove channels from temporal storage.
				for (var i:int = 0; i < tempChannelStorage.length; i++) {
					if (tempChannelStorage[i] == thisToWorker) {
						tempChannelStorage.splice(i, 1);
						i--;
					} else if (tempChannelStorage[i] == workerToThis) {
						tempChannelStorage.splice(i, 1);
						i--;
					}
				}
			} else {
				trace("HANDLE SIMPLE MESSAGE");
				trace(messageType);
				var params:Object = channel.receive();
				trace(params);
			}
		} else {
			trace("WARNING !!!  null received... why?");
		}
	}


	static pureLegsCore function demo_sendMessage(type:String, params:Object = null):void {
		trace("demo_sendMessage", type, params);
		for (var i:int = 0; i < $sendMessageChannels.length; i++) {
			trace("   " + $sendMessageChannels[i]);
			$sendMessageChannels[i].send(type);
			if(params){
				$sendMessageChannels[i].send(params);
			}
		}
	}


	public function debug_CommunicationMain():void {
		trace("MAIN TEST");

		use namespace pureLegsCore;

		demo_sendMessage("Main > worker...");
	}

	public function debug_CommunicationWorker():void {
		trace("WORKER TEST");

		use namespace pureLegsCore;

		demo_sendMessage("Worker > main...");
	}


	private function demo_custom_scope():void {
		var moduleBase:ModuleBase

		use namespace pureLegsCore;

		//ModuleManager.registerScope("", "_moduleName", true, true, true);
		//moduleBase.registerScope()
	}
}
}
