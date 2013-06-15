package org.mvcexpress.extensions.workers.modules {
import com.mindScriptAct.workerTest.WorkerIds;

import flash.display.Sprite;
import flash.events.Event;
import flash.net.getClassByAlias;
import flash.net.registerClassAlias;
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
import org.mvcexpress.extensions.workers.data.ClassAliasRegistry;

//import flash.system.MessageChannel;
//import flash.system.Worker;
//import flash.system.WorkerDomain;
public class ModuleWorkerBase extends Sprite {


	private static const MODULE_NAME_KEY:String = "$_moduleName_$";
	private static const MODULE_CLASS_NAME_KEY:String = "$_moduleClassName_$";
	private static const INIT_REMOTE_WORKER:String = "$_init_remote_worker_$";
	private static const SEND_WORKER_MESSAGE:String = "$_send_worker_message_$";
	private static const REGISTER_CLASS_ALIAS:String = "$_register_class_alias_$";
	pureLegsCore static const CLASS_ALIAS_NAMES_KEY:String = "$_class_alias_names_key_$";


	// bytes of main swf file. Used for creating workers.
	private static var $primordialBytes:ByteArray;

	pureLegsCore static var canInitChildModule:Boolean = false;

	// channels for all remote workres to send data to them.
	private static var $sendMessageChannels:Vector.<Object> = new <Object>[];

	private static var $messageSendChannelsRegistry:Dictionary = new Dictionary();
	private static var $messageChannelsWorkerNames:Vector.<String> = new <String>[];

	// todo : check if needed.
	private static var $receiveMessageChannels:Vector.<Object> = new <Object>[];

	// store messageChannels so they don't get garbage collected while they are handled by remote worker.
	private var tempChannelStorage:Vector.<Object> = new <Object>[];


	private var debug_moduleName:String;
	public static const debug_coreId:int = Math.random() * 100000000;
	public var debug_objectID:int = Math.random() * 100000000;
	private var debug_doDebugging:Boolean = false;

	pureLegsCore static const $classAliasRegistry:ClassAliasRegistry = new ClassAliasRegistry();
	private var pendingWorkerMessengers:Dictionary = new Dictionary();
	private var workerRegistry:Dictionary = new Dictionary();

	//

	private static var isWorkersDefined:Boolean = false;
	protected static var _isWorkersSupported:Boolean = false;

//	public static var MessageChannelClass:Class;
	public static var WorkerClass:Class;
	public static var WorkerDomainClass:Class;

	//

	pureLegsCore function handleWorker(moduleName:String):Boolean {

		if (!isWorkersDefined) {
			isWorkersDefined = true;

			try {
//				MessageChannelClass = getDefinitionByName("flash.system.MessageChannel") as Class;
				WorkerClass = getDefinitionByName("flash.system.Worker") as Class;
				WorkerDomainClass = getDefinitionByName("flash.system.WorkerDomain") as Class;
			} catch (error:Error) {
				// do nothing.
			}

			if (WorkerClass) {
				_isWorkersSupported = true;
			}
		}


		use namespace pureLegsCore;

		this.debug_moduleName = moduleName;

		if (_isWorkersSupported) {

			trace("[" + moduleName + "]" + "ModuleWorkerBase: CONSTRUCT, 'primordial:", WorkerClass.current.isPrimordial
					+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");

			//
			if (WorkerClass.current.isPrimordial) { // check if primordial.
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
					WorkerClass.current.setSharedProperty(MODULE_NAME_KEY, moduleName);
				}
			} else {
				trace("[" + moduleName + "]" + "ModuleWorkerBase: can init child module?:", ModuleWorkerBase.canInitChildModule
						+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");
				// check if this is temp copy of the main swf
				if (!ModuleWorkerBase.canInitChildModule) {
					// NOT PRIMORDIAL, COPY OF THE MAIN.
					var childModuleClassDefinition:String = WorkerClass.current.getSharedProperty(MODULE_CLASS_NAME_KEY);
					trace("[" + moduleName + "]" + "ModuleWorkerBase: moduleClass:", childModuleClassDefinition
							+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");
					if (childModuleClassDefinition) {
						WorkerClass.current.setSharedProperty(MODULE_CLASS_NAME_KEY, null);

						var childModuleClass:Class = getDefinitionByName(childModuleClassDefinition) as Class;

						ModuleWorkerBase.canInitChildModule = true;
						var childModule:ModuleWorker = new childModuleClass();
						ModuleWorkerBase.canInitChildModule = true;
					}
					return false;
				} else {
					// NOT PRIMORDIAL, CHILD MODULE.
					WorkerClass.current.setSharedProperty(MODULE_NAME_KEY, moduleName);

					// register all already used class aliases.
					var classAliasNames:String = WorkerClass.current.getSharedProperty(CLASS_ALIAS_NAMES_KEY);
					if (classAliasNames != "") {
						var classAliasSplit:Array = classAliasNames.split(",");
						for (var i:int = 0; i < classAliasSplit.length; i++) {
							registerClassNameAlias(classAliasSplit[i])
						}
					}

					setUpRemoteWorkerCommunication();

					// todo: debug
					if (debug_doDebugging) {
						setInterval(debug_CommunicationWorker, 1000);
					}
				}
			}
		} else {
			if (ModuleWorkerBase.canInitChildModule) {

				// todo : get this naime better.
				var workerModuleName:String = WorkerIds.MAIN_WORKER_TEST_MODULE;

				ModuleManager.registerScope(debug_moduleName, workerModuleName, true, true, true);
				ModuleManager.registerScope(debug_moduleName, debug_moduleName, true, true, true);
				ModuleManager.registerScope(workerModuleName, workerModuleName, true, true, true);
			}

		}
		return true;
	}


	// TODO : consider creating it as static public funcion.
	protected function startWorkerModule(workerModuleClass:Class, workerModuleName:String):void {
		// TODO : check extended form workerModule class.

		if (_isWorkersSupported) {
			//
			trace("[" + debug_moduleName + "]" + "ModuleWorkerBase: startWorkerModule: " + workerModuleClass, "isPrimordial:" + WorkerClass.current.isPrimordial
					+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");

			trace("WorkerClass.isSupported:", WorkerClass.isSupported);

			if (WorkerClass.current.isPrimordial) {
				var remoteWorker:Object = WorkerDomainClass.current.createWorker($primordialBytes);
				workerRegistry[workerModuleName] = remoteWorker;

				// todo : debug
				remoteWorker.addEventListener(Event.WORKER_STATE, debug_workerStateHandler);
				remoteWorker.setSharedProperty(MODULE_CLASS_NAME_KEY, getQualifiedClassName(workerModuleClass));

				var classAlianNames:String = $classAliasRegistry.getCustomClasses();

				remoteWorker.setSharedProperty(CLASS_ALIAS_NAMES_KEY, classAlianNames);
				//

				use namespace pureLegsCore;

				// init custom scoped messenger
				var messengerWorker:MessengerWorker = ModuleManager.getScopeMessenger(workerModuleName, MessengerWorker) as MessengerWorker;
				pendingWorkerMessengers[workerModuleName] = messengerWorker;

				ModuleManager.registerScope(debug_moduleName, workerModuleName, true, true, true);
				ModuleManager.registerScope(debug_moduleName, debug_moduleName, true, true, true);
				ModuleManager.registerScope(workerModuleName, workerModuleName, true, true, true);


				//
				connectRemoteWorker(remoteWorker);
				//
				remoteWorker.start();

			} else {
				throw Error("Starting other workers only possible from main(primordial) worker.)");
			}
		} else {
//			throw  Error("TODO");

			ModuleManager.registerScope(debug_moduleName, workerModuleName, true, true, true);
			ModuleManager.registerScope(debug_moduleName, debug_moduleName, true, true, true);
			ModuleManager.registerScope(workerModuleName, workerModuleName, true, true, true);

			ModuleWorkerBase.canInitChildModule = true;
			var childModule:ModuleWorker = new workerModuleClass();
			workerRegistry[workerModuleName] = childModule;
			ModuleWorkerBase.canInitChildModule = true;
		}
	}

	public function stopWorkerModule(workerModuleName:String):void {
		trace("STOP workerModuleName...");

		// todo : decide what to do, if current module name is sent.
		// todo : decide what to do if current worker is not primordial.

		if (_isWorkersSupported) {

			var worker:Object = workerRegistry[workerModuleName];

			if (worker) {

				// remove channels from this module.
				for (var i:int = 0; i < $messageChannelsWorkerNames.length; i++) {
					if ($messageChannelsWorkerNames[i] == workerModuleName) {
						var thisToWorker:Object = $sendMessageChannels.splice(i, 1)[0];
						thisToWorker.close();
						var workerToThis:Object = $receiveMessageChannels.splice(i, 1)[0];
						workerToThis.removeEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);
						workerToThis.close();

						$messageChannelsWorkerNames.splice(i, 1);
						break;
					}
				}

				// todo : send message to other modules to remove channels with

				worker.terminate();

				delete workerRegistry[workerModuleName]
			}
		} else {
			if (workerRegistry[workerModuleName]) {
				(workerRegistry[workerModuleName] as ModuleWorker).disposeModule();

				delete workerRegistry[workerModuleName]
			}
		}
	}


	private function debug_workerStateHandler(event:Event):void {
		var childWorker:Object = event.target;
		trace("[" + debug_moduleName + "]" + "ModuleWorkerBase: workerStateHandler- " + childWorker.state
				+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");
	}

	public function debug_getModuleName():String {
		if (_isWorkersSupported) {
			var retVal:String = WorkerClass.current.getSharedProperty(MODULE_NAME_KEY);
			WorkerClass.current.setSharedProperty(MODULE_NAME_KEY, retVal);
			return retVal;
		} else {
//			throw  Error("TODO");
			return "";
		}

	}

	private function connectRemoteWorker(remoteWorker:Object):void {
		// get all running workers
		var workers:* = WorkerDomainClass.current.listWorkers();
		trace("[" + debug_moduleName + "]" + "connectChildWorker " + remoteWorker, "with", workers
				+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");
		//
		for (var i:int = 0; i < workers.length; i++) {
			var worker:Object = workers[i];
			//
			// get model name from worker.
			var workerModuleName:String = worker.getSharedProperty(MODULE_NAME_KEY);
			worker.setSharedProperty(MODULE_NAME_KEY, workerModuleName);
			//
			if (!$messageSendChannelsRegistry[workerModuleName]) {
				var workerToRemote:Object = worker.createMessageChannel(remoteWorker);
				var remoteToWorker:Object = remoteWorker.createMessageChannel(worker);

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
		var workers:* = WorkerDomainClass.current.listWorkers();
		trace("[" + debug_moduleName + "]" + "setUpWorkerCommunication " + workers
				+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");
		//
		var thisWorker:Object = WorkerClass.current;
		for (var i:int = 0; i < workers.length; i++) {
			var worker:Object = workers[i];
			// TODO : decide what to do with self send messages...
			if (worker != WorkerClass.current) {
				if (worker.isPrimordial) {


					var workerModuleName:String = worker.getSharedProperty(MODULE_NAME_KEY);
					worker.setSharedProperty(MODULE_NAME_KEY, workerModuleName);
//					trace("...processisng..." + workerModuleName);
					// handle communication permissions
					use namespace pureLegsCore;

					// init custom scoped messenger
					(ModuleManager.getScopeMessenger(workerModuleName, MessengerWorker) as MessengerWorker).ready();
					ModuleManager.registerScope(debug_moduleName, workerModuleName, true, true, true);
					ModuleManager.registerScope(debug_moduleName, debug_moduleName, true, true, true);
					ModuleManager.registerScope(workerModuleName, workerModuleName, true, true, true);
					//
					if (!$messageSendChannelsRegistry[workerModuleName]) {
						var workerToThis:Object = thisWorker.getSharedProperty("workerToRemote_" + workerModuleName);
						var thisToWorker:Object = thisWorker.getSharedProperty("remoteToWorker_" + workerModuleName);
						//
						$messageSendChannelsRegistry[workerModuleName] = thisToWorker;

						$sendMessageChannels.push(thisToWorker);
						$receiveMessageChannels.push(workerToThis);
						$messageChannelsWorkerNames.push(workerModuleName);

						workerToThis.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);

						worker.setSharedProperty("thisToWorker_" + debug_moduleName, thisToWorker);
						worker.setSharedProperty("workerToThis_" + debug_moduleName, workerToThis);

						thisToWorker.send(INIT_REMOTE_WORKER);
						thisToWorker.send(debug_moduleName);
					} else {
						throw Error("2 workers with same name should not exist.");
					}
				} else {
					// FEATURE : handle not main module...
				}
			}
		}

	}

	private function handleChannelMessage(event:Event):void {
		use namespace pureLegsCore;

		var channel:Object = event.target;

		if (channel.messageAvailable) {

			var communicationType:Object = channel.receive();

			trace("--[" + debug_moduleName + "]" + "handleChannelMessage : ", communicationType
					+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");

			if (communicationType == INIT_REMOTE_WORKER) {
				// handle special communication for initialization of new worker.
				var remoteModuleName:String = channel.receive(true);

				trace("Init new remote module : ", remoteModuleName);

				trace("[" + debug_moduleName + "]" + "handle child module init! ", remoteModuleName
						+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");

				var thisWorker:Object = WorkerClass.current;

				var workerToThis:Object = thisWorker.getSharedProperty("thisToWorker_" + remoteModuleName);
				var thisToWorker:Object = thisWorker.getSharedProperty("workerToThis_" + remoteModuleName);

				$messageSendChannelsRegistry[remoteModuleName] = thisToWorker;

				$sendMessageChannels.push(thisToWorker);
				$receiveMessageChannels.push(workerToThis);
				$messageChannelsWorkerNames.push(remoteModuleName);

				// send pending messages.
				pendingWorkerMessengers[remoteModuleName].ready();
				delete pendingWorkerMessengers[remoteModuleName]
				// remove  channels from temporal storage.
				for (var i:int = 0; i < tempChannelStorage.length; i++) {
					if (tempChannelStorage[i] == thisToWorker) {
						tempChannelStorage.splice(i, 1);
						i--;
					} else if (tempChannelStorage[i] == workerToThis) {
						tempChannelStorage.splice(i, 1);
						i--;
					}
				}
			} else if (communicationType == REGISTER_CLASS_ALIAS) {
				// handle special message for registering class alias.
				var classQualifiedName:String = channel.receive(true) as String;
				registerClassNameAlias(classQualifiedName);
			} else if (communicationType == SEND_WORKER_MESSAGE) {
				// handle worker to worker communication.
				var messageType:String = channel.receive(true) as String;
				var params:Object = channel.receive(true);
//				trace("       HANDLE SIMPLE MESSAGE!", messageType, params);
				var messageTypeSplite:Array = messageType.split("_^~_");
				ModuleManager.sendScopeMessage(debug_moduleName, debug_moduleName, messageTypeSplite[1], params);
			} else {
				throw Error("ModuleWorkerBase can't handle communicationType:" + communicationType + " This channel designed to be used by framework only.");
			}
		}
	}

	private function registerClassNameAlias(classQualifiedName:String):void {
		trace("Registering new class...", classQualifiedName);

		use namespace pureLegsCore;

		// check if alias is not already created.
		try {
			var mapClass:Class = getClassByAlias(classQualifiedName);
		} catch (error:Error) {
			// do noting
		}
		trace("Alias clas exists?", mapClass)
		if (!mapClass) {
			// try to get it by definition...
			mapClass = getDefinitionByName(classQualifiedName) as Class;
			if (mapClass) {
				registerClassAlias(classQualifiedName, mapClass);
			} else {
				throw Error("Failed to find class with definition:" + classQualifiedName + " in " + debug_moduleName + " add this class to project or use registerClassAlias(" + classQualifiedName + ", YourClass); to register alternative class. ");
			}
		}
		trace("Class got by definition?", mapClass)
		//
		$classAliasRegistry.classes[mapClass] = classQualifiedName;
	}


	static pureLegsCore function startClassRegistration(classFullName:String):void {
		trace(" !! startClassRegistration", classFullName);
		for (var i:int = 0; i < $sendMessageChannels.length; i++) {
			$sendMessageChannels[i].send(REGISTER_CLASS_ALIAS);
			$sendMessageChannels[i].send(classFullName);
		}
	}

	static pureLegsCore function sendMessageToAll(type:String, params:Object = null):void {
		trace(" !! sendMessageToAll", type, params);
		for (var i:int = 0; i < $sendMessageChannels.length; i++) {
			var msgChannel:Object = $sendMessageChannels[i];
//			trace("   " + msgChannel);
			msgChannel.send(SEND_WORKER_MESSAGE);
			msgChannel.send(type);
			if (params) {
				msgChannel.send(params);
			}
		}
	}

	static pureLegsCore function sendMessageToWorker(workerName:String, type:String, params:Object = null):void {
		trace(" !! sendMessageToWorker", workerName, type, params);
		var msgChannel:Object = $messageSendChannelsRegistry[workerName];
		if (msgChannel) {
			msgChannel.send(SEND_WORKER_MESSAGE);
			msgChannel.send(type);
			if (params) {
				msgChannel.send(params);
			}
		}
	}


	public function debug_CommunicationMain():void {
		trace("MAIN TEST");
		use namespace pureLegsCore;
		sendMessageToAll("Main > worker...");
	}

	public function debug_CommunicationWorker():void {
		trace("WORKER TEST");
		use namespace pureLegsCore;
		sendMessageToAll("Worker > main...");
	}


	private function demo_custom_scope():void {
		var moduleBase:ModuleBase
		use namespace pureLegsCore;
		//ModuleManager.registerScope("", "_moduleName", true, true, true);
		//moduleBase.registerScope()
	}


}
}
