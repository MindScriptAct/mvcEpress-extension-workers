package mvcexpress.extensions.scopedWorkers.modules {
import flash.events.Event;
import flash.net.getClassByAlias;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mvcexpress.core.ExtensionManager;
import mvcexpress.core.namespace.pureLegsCore;
import mvcexpress.extensions.scoped.core.ScopeManager;
import mvcexpress.extensions.scoped.modules.ModuleScoped;
import mvcexpress.extensions.scopedWorkers.core.messenger.MessengerWorker;
import mvcexpress.extensions.scopedWorkers.data.ClassAliasRegistry;

//import flash.system.MessageChannel;
//import flash.system.Worker;
//import flash.system.WorkerDomain;
public class ModuleScopedWorker extends ModuleScoped {

	/**
	 * If set to true, class aliases will be registered before sending between modules. (untyped objects will be sent otherwise)
	 */
	static public var doAutoRegisterClasses:Boolean = true;


	//---------------------
	// internal properties
	//---------------------

	// keys for worker shared data.
	private static const WORKER_MODULE_NAME_KEY:String = "$_wmn_$";
	private static const MODULE_NAME_KEY:String = "$_mn_$";
	private static const CHILD_MODULE_CLASS_NAME_KEY:String = "$_cmcn_$";
	private static const INIT_REMOTE_WORKER:String = "$_irw_$";
	private static const SEND_WORKER_MESSAGE:String = "$_sm_$";
	private static const REGISTER_CLASS_ALIAS:String = "$_rca_$";
	pureLegsCore static const CLASS_ALIAS_NAMES_KEY:String = "$_can_$";

	// worker support
	private static var needWorkerSupportCheck:Boolean = true;
	private static var _isWorkersSupported:Boolean = false;

	public static var WorkerClass:Class;
	public static var WorkerDomainClass:Class;

	// root class bytes.
	static private var $primordialBytes:ByteArray;

	// channels for all remote workers.
	private static var $sendMessageChannels:Vector.<Object> = new <Object>[];

	// registry of all workers.
	private var workerRegistry:Dictionary = new Dictionary()

	//  messenger  waiting for remote worker to be initialized. (All messages send while waiting will be stacked, and send then remote module is ready.)
	private var pendingWorkerMessengers:Dictionary = new Dictionary();

	// collection of registered class aliases.
	pureLegsCore static const $classAliasRegistry:ClassAliasRegistry = new ClassAliasRegistry();

	// todo : check if needed.
	private var receiveMessageChannels:Vector.<Object> = new <Object>[];
	private var messageSendChannelsRegistry:Dictionary = new Dictionary();
	private var messageChannelsWorkerNames:Vector.<String> = new <String>[];

	// store messageChannels so they don't get garbage collected while they are handled by remote worker.
	private var tempChannelStorage:Vector.<Object> = new <Object>[];

	// debug ids, for tracing.
	public static const debug_coreId:int = Math.random() * 100000000;
	public var debug_objectID:int = Math.random() * 100000000;


	public function ModuleScopedWorker(moduleName:String, mediatorMapClass:Class = null, proxyMapClass:Class = null, commandMapClass:Class = null, messengerClass:Class = null) {

		trace("-----[" + moduleName + "]" + "ModuleWorker: try to create module."
				+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");

		use namespace pureLegsCore;

		CONFIG::debug {
			enableExtension(EXTENSION_WORKER_ID);
		}

		if (initWorker(moduleName)) {
			trace("-----[" + moduleName + "]" + "ModuleWorker: Create module!"
					+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");
			super(moduleName, mediatorMapClass, proxyMapClass, commandMapClass, messengerClass);
		}

	}

	/**
	 * Set root swf file Bytes. (used toe create workers from self, as alternative to leading it.)
	 * @param rootSwfBytes
	 */
	public static function setRootSwfBytes(rootSwfBytes:ByteArray):void {
		$primordialBytes = rootSwfBytes;
	}

	/**
	 * True if workers are supported.
	 */
	public static function get isWorkersSupported():Boolean {
		return _isWorkersSupported;
	}


	/**
	 * Starts background worker.
	 *        If workerSwfBytes property is not provided - rootSwfBytes will be used.
	 * @param workerModuleClass
	 * @param workerModuleName
	 * @param workerSwfBytes
	 */
	public function createBackgroundWorker(workerModuleClass:Class, workerModuleName:String, workerSwfBytes:ByteArray = null):void {

		// TODO : check extended form workerModule class.

		if (_isWorkersSupported) {
			//
			trace("------[" + moduleName + "]" + "ModuleWorkerBase: startWorkerModule: " + workerModuleClass, "isPrimordial:" + WorkerClass.current.isPrimordial
					+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");

			//trace("WorkerClass.isSupported:", WorkerClass.isSupported);

			if (WorkerClass.current.isPrimordial) {
				var remoteWorker:Object = WorkerDomainClass.current.createWorker($primordialBytes);
				workerRegistry[workerModuleName] = remoteWorker;

				// todo : debug
				remoteWorker.addEventListener(Event.WORKER_STATE, debug_workerStateHandler);
				remoteWorker.setSharedProperty(CHILD_MODULE_CLASS_NAME_KEY, getQualifiedClassName(workerModuleClass));

				var classAlianNames:String = $classAliasRegistry.getCustomClasses();

				remoteWorker.setSharedProperty(CLASS_ALIAS_NAMES_KEY, classAlianNames);
				//

				use namespace pureLegsCore;

				// init custom scoped messenger
				var messengerWorker:MessengerWorker = ScopeManager.getScopeMessenger(workerModuleName, MessengerWorker) as MessengerWorker;
				pendingWorkerMessengers[workerModuleName] = messengerWorker;

				ScopeManager.registerScope(moduleName, workerModuleName, true, true, false);
				ScopeManager.registerScope(moduleName, moduleName, true, true, false);
				ScopeManager.registerScope(workerModuleName, workerModuleName, true, true, false);

				//
				connectRemoteWorker(remoteWorker);
				//
				remoteWorker.start();

			} else {
				throw Error("Starting other workers only possible from main(primordial) worker.)");
			}
		} else {
			throw  Error("TODO");

//			ScopeManager.registerScope(debug_moduleName, workerModuleName, true, true, false);
//			ScopeManager.registerScope(debug_moduleName, debug_moduleName, true, true, false);
//			ScopeManager.registerScope(workerModuleName, workerModuleName, true, true, false);
//
//			ModuleScopedWorker.canInitChildModule = true;
//			var childModule:Object = new workerModuleClass();
//			workerRegistry[workerModuleName] = childModule;
//			ModuleScopedWorker.canInitChildModule = true;
		}
	}

	/**
	 * Stops background worker.s
	 * @param workerModuleName
	 */
	public function terminateBackgroundWorker(workerModuleName:String):void {
		trace("STOP worker :", workerModuleName);

		// todo : decide what to do, if current module name is sent.
		// todo : decide what to do if current worker is not primordial.

		if (_isWorkersSupported) {
			var worker:Object = workerRegistry[workerModuleName];
			if (worker) {
				// remove channels from this module.
				for (var i:int = 0; i < messageChannelsWorkerNames.length; i++) {
					if (messageChannelsWorkerNames[i] == workerModuleName) {
						var thisToWorker:Object = $sendMessageChannels.splice(i, 1)[0];
						thisToWorker.close();
						var workerToThis:Object = receiveMessageChannels.splice(i, 1)[0];
						workerToThis.removeEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);
						workerToThis.close();

						messageChannelsWorkerNames.splice(i, 1);
						break;
					}
				}
				// todo : send message to other modules to remove channels with
				worker.terminate();
				delete workerRegistry[workerModuleName]
			}
		} else {
			if (workerRegistry[workerModuleName]) {
				(workerRegistry[workerModuleName] as ModuleScopedWorker).disposeModule();

				delete workerRegistry[workerModuleName]
			}
		}
	}


	//////////////////////////////
	//	INTERNALS
	//////////////////////////////

	// inits main worker
	pureLegsCore function initWorker(moduleName:String):Boolean {

		// dynamically get worker classes.
		if (needWorkerSupportCheck) {
			needWorkerSupportCheck = false;

			try {
				WorkerClass = getDefinitionByName("flash.system.Worker") as Class;
				WorkerDomainClass = getDefinitionByName("flash.system.WorkerDomain") as Class;
			} catch (error:Error) {
				// do nothing.
			}

			if (WorkerClass && WorkerDomainClass && WorkerClass.isSupported) {
				_isWorkersSupported = true;
			}
		}

		use namespace pureLegsCore;

		if (_isWorkersSupported) {

			trace("------[" + moduleName + "]" + "ModuleWorkerBase: CONSTRUCT, 'primordial:", WorkerClass.current.isPrimordial
					+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");

			if (WorkerClass.current.isPrimordial) { // check if primordial.
				var rootModuleName:String = WorkerClass.current.getSharedProperty(WORKER_MODULE_NAME_KEY);
				if (rootModuleName != null) { // check if root module is already created.
					throw Error("Only first(main) ModuleScopedWorker can be instantiated. Use createBackgroundWorker(MyBackgroundWorkerModule) to create background workers. ");
				} else { // PRIMORDIAL, MAIN.

					CONFIG::debug {
						if (!moduleName) {
							throw Error("Worker must have not empty moduleName. (It is used for module to module communication.)");
						}
					}
					WorkerClass.current.setSharedProperty(MODULE_NAME_KEY, moduleName);
					WorkerClass.current.setSharedProperty(WORKER_MODULE_NAME_KEY, moduleName);
				}
			} else {
				// not primordial workers.

				// check if child must be created.
				var childModuleClassDefinition:String = WorkerClass.current.getSharedProperty(CHILD_MODULE_CLASS_NAME_KEY);

				trace("------[" + moduleName + "]" + "ModuleWorkerBase: should init child module?:", childModuleClassDefinition
						+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");

				if (childModuleClassDefinition) {
					// NOT PRIMORDIAL, COPY OF THE MAIN.

					trace("------[" + moduleName + "]" + "ModuleWorkerBase: moduleClass:", childModuleClassDefinition
							+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");

					WorkerClass.current.setSharedProperty(CHILD_MODULE_CLASS_NAME_KEY, null);


					try {
						var childModuleClass:Class = getDefinitionByName(childModuleClassDefinition) as Class;
					} catch (error:Error) {
						throw Error("Failed to get a class from class definition: " + childModuleClassDefinition + " - " + error)
					}

					try {
						var childModule:Object = new childModuleClass();
					} catch (error:Error) {
						throw Error("Failed to construct class for: " + childModuleClass + " - " + error)
					}

					// end this module.
					return false;
				} else {
					// NOT PRIMORDIAL, CHILD MODULE.

					var workerModuleName:String = WorkerClass.current.getSharedProperty(WORKER_MODULE_NAME_KEY);

					WorkerClass.current.setSharedProperty(MODULE_NAME_KEY, moduleName);

					// register all already used class aliases.
					var classAliasNames:String = WorkerClass.current.getSharedProperty(CLASS_ALIAS_NAMES_KEY);
					if (classAliasNames != "") {
						var classAliasSplit:Array = classAliasNames.split(",");
						for (var i:int = 0; i < classAliasSplit.length; i++) {
							registerClassNameAlias(classAliasSplit[i])
						}
					}

					setUpRemoteWorkerCommunication(moduleName);
				}


			}
		} else {
			throw Error("TODO");
//			if (ModuleScopedWorker.canInitChildModule) {
//
//				// todo : get this naime better.
//				var workerModuleName:String = WorkerIds.MAIN_WORKER;
//
//				ScopeManager.registerScope(debug_moduleName, workerModuleName, true, true, false);
//				ScopeManager.registerScope(debug_moduleName, debug_moduleName, true, true, false);
//				ScopeManager.registerScope(workerModuleName, workerModuleName, true, true, false);
//			}
		}
		return true;
	}


	private function connectRemoteWorker(remoteWorker:Object):void {
		// get all running workers
		var workers:* = WorkerDomainClass.current.listWorkers();
		trace("------[" + moduleName + "]" + "connectChildWorker " + remoteWorker, "with", workers
				+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");
		//
		for (var i:int = 0; i < workers.length; i++) {
			var worker:Object = workers[i];
			//
			// get model name from worker.
			var workerModuleName:String = worker.getSharedProperty(MODULE_NAME_KEY);
			worker.setSharedProperty(MODULE_NAME_KEY, workerModuleName);
			//
			if (!messageSendChannelsRegistry[workerModuleName]) {
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

			}
		}
	}


	private function setUpRemoteWorkerCommunication(moduleName:String):void {
		// get all workers
		var workers:* = WorkerDomainClass.current.listWorkers();
		trace("------[" + moduleName + "]" + "setUpWorkerCommunication " + workers
				+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");
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
					(ScopeManager.getScopeMessenger(workerModuleName, MessengerWorker) as MessengerWorker).ready();
					ScopeManager.registerScope(moduleName, workerModuleName, true, true, false);
					ScopeManager.registerScope(moduleName, moduleName, true, true, false);
					ScopeManager.registerScope(workerModuleName, workerModuleName, true, true, false);
					//
					if (!messageSendChannelsRegistry[workerModuleName]) {
						var workerToThis:Object = thisWorker.getSharedProperty("workerToRemote_" + workerModuleName);
						var thisToWorker:Object = thisWorker.getSharedProperty("remoteToWorker_" + workerModuleName);
						//
						messageSendChannelsRegistry[workerModuleName] = thisToWorker;

						$sendMessageChannels.push(thisToWorker);
						receiveMessageChannels.push(workerToThis);
						messageChannelsWorkerNames.push(workerModuleName);

						workerToThis.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);

						worker.setSharedProperty("thisToWorker_" + moduleName, thisToWorker);
						worker.setSharedProperty("workerToThis_" + moduleName, workerToThis);


						trace("INIT_REMOTE_WORKER !!! ", moduleName);
						thisToWorker.send(INIT_REMOTE_WORKER);
						thisToWorker.send(moduleName);
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

//			trace("--[" + debug_moduleName + "]" + "handleChannelMessage : ", communicationType
//					+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");

			if (communicationType == INIT_REMOTE_WORKER) {
				// handle special communication for initialization of new worker.
				var remoteModuleName:String = channel.receive(true);

				//trace("Init new remote module : ", remoteModuleName);

				trace("------[" + moduleName + "]" + "handle child module init! ", remoteModuleName
						+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");

				var thisWorker:Object = WorkerClass.current;

				var workerToThis:Object = thisWorker.getSharedProperty("thisToWorker_" + remoteModuleName);
				var thisToWorker:Object = thisWorker.getSharedProperty("workerToThis_" + remoteModuleName);

				messageSendChannelsRegistry[remoteModuleName] = thisToWorker;

				$sendMessageChannels.push(thisToWorker);
				receiveMessageChannels.push(workerToThis);
				messageChannelsWorkerNames.push(remoteModuleName);

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
				ScopeManager.sendScopeMessage(moduleName, moduleName, messageTypeSplite[1], params);
			} else {
				throw Error("ModuleWorkerBase can't handle communicationType:" + communicationType + " This channel designed to be used by framework only.");
			}
		}
	}

	private function registerClassNameAlias(classQualifiedName:String):void {
		//trace("Registering new class...", classQualifiedName);

		use namespace pureLegsCore;

		// check if alias is not already created.
		try {
			var mapClass:Class = getClassByAlias(classQualifiedName);
		} catch (error:Error) {
			// do noting
		}
		//trace("Alias clas exists?", mapClass)
		if (!mapClass) {
			// try to get it by definition...
			mapClass = getDefinitionByName(classQualifiedName) as Class;
			if (mapClass) {
				registerClassAlias(classQualifiedName, mapClass);
			} else {
				throw Error("Failed to find class with definition:" + classQualifiedName + " in " + moduleName + " add this class to project or use registerClassAlias(" + classQualifiedName + ", YourClass); to register alternative class. ");
			}
		}
		//trace("Class got by definition?", mapClass)
		//
		$classAliasRegistry.classes[mapClass] = classQualifiedName;
	}


	static pureLegsCore function startClassRegistration(classFullName:String):void {
//		trace(" !! startClassRegistration", classFullName);
		for (var i:int = 0; i < $sendMessageChannels.length; i++) {
			$sendMessageChannels[i].send(REGISTER_CLASS_ALIAS);
			$sendMessageChannels[i].send(classFullName);
		}
	}


	//---------------------------------
	// Debug functions.
	//---------------------------------

	private function debug_workerStateHandler(event:Event):void {
		var childWorker:Object = event.target;
		trace("------[" + moduleName + "]" + "ModuleWorkerBase: workerStateHandler- " + childWorker.state
				+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");
	}

	public function debug_getModuleName():String {
		if (_isWorkersSupported) {
			var retVal:String = WorkerClass.current.getSharedProperty(MODULE_NAME_KEY);
			WorkerClass.current.setSharedProperty(MODULE_NAME_KEY, retVal);
			return retVal;
		} else {
//			throw  Error("TODO");
			return moduleName;
		}
	}

	static pureLegsCore function debug_sendMessage(type:String, params:Object = null):void {
//		trace(" !! demo_sendMessage", type, params);
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


	//----------------------------------
	//    Extension checking: INTERNAL, DEBUG ONLY.
	//----------------------------------

	/** @private */
	CONFIG::debug
	static pureLegsCore const EXTENSION_WORKER_ID:int = ExtensionManager.getExtensionIdByName(pureLegsCore::EXTENSION_WORKER_NAME);

	/** @private */
	CONFIG::debug
	static pureLegsCore const EXTENSION_WORKER_NAME:String = "workers";

}
}
