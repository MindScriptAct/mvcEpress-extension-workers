package mvcexpress.extensions.workers.core {
import flash.events.Event;
import flash.net.getClassByAlias;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mvcexpress.core.messenger.HandlerVO;
import mvcexpress.core.messenger.Messenger;
import mvcexpress.core.namespace.pureLegsCore;
import mvcexpress.extensions.workers.core.messenger.WorkerMessenger;
import mvcexpress.extensions.workers.data.ClassAliasRegistry;
import mvcexpress.modules.ModuleCore;

/**
 * Manages workers.
 * @private
 */
public class WorkerManager {

	/**
	 * If set to true, class aliases will be registered before sending between modules. (untyped objects will be sent otherwise)
	 */
	static public var doAutoRegisterClasses:Boolean = true;


	// true if workers are supported.
	private static var _isSupported:Boolean;

	// stores worker classes dynamically.
	public static var WorkerClass:Class;
	public static var WorkerDomainClass:Class;

	// root class bytes.
	static private var $primordialSwfBytes:ByteArray;


	///// keys for worker shared data.
	// name of worker module,  every worker have only one worker Module.
	private static const WORKER_MODULE_NAME_KEY:String = "$_wmn_$";
	// class name of remote module. (used by remote worker to instantiate remote module)
	pureLegsCore static const REMOTE_MODULE_CLASS_NAME_KEY:String = "$_rmcn_$";
	// all class alias names to register.
	private static const CLASS_ALIAS_NAMES_KEY:String = "$_can_$";

	///// worker communication types.
	// init remote worker.
	private static const INIT_REMOTE_WORKER_TYPE:String = "$_irw_t_$";
	// sends message to all worker.
	private static const SEND_WORKER_MESSAGE_TYPE:String = "$_sm_t_$";
	// register class alias, from another worker.
	private static const REGISTER_CLASS_ALIAS_TYPE:String = "$_rca_t_$";

	// list of worker names with ready communication channels.
	static private var $channelReadyWorkerNames:Vector.<String> = new <String>[];

	// channels to all remote workers.
	static private var $sendMessageChannels:Vector.<Object> = new <Object>[];
	static private var $sendMessageChannelsRegistry:Dictionary = new Dictionary();

	// channels from all remote workers.
	static private var $receiveMessageChannels:Vector.<Object> = new <Object>[];

	// registry of all workers.
	static private var $workerRegistry:Dictionary = new Dictionary()

	/* all messengers by remote worker module name */
	static private var workerMessengers:Dictionary = new Dictionary(); //* of WorkerMessenger by String{moduleName} */

	//  messenger  waiting for remote worker to be initialized. (All messages send while waiting will be stacked, and send then remote module is ready.)
	static private var $pendingWorkerMessengers:Dictionary = new Dictionary();

	// store messageChannels so they don't get garbage collected while they are waiting for remote worker to be ready.
	static private var $tempChannelStorage:Vector.<Object> = new <Object>[];


	// TEMP...
	// debug ids, for tracing.
	//debug:worker**/static public const debug_coreId:int = Math.random() * 100000000;


	/**
	 * True if workers are supported.
	 */
	public static function get isSupported():Boolean {
		return _isSupported;
	}


	/**
	 * Set root swf file Bytes. (used toe create workers from self, as alternative to leading it.)
	 * @param rootSwfBytes
	 */
	public static function setRootSwfBytes(rootSwfBytes:ByteArray):void {
		$primordialSwfBytes = rootSwfBytes;
	}


	static pureLegsCore function checkWorkerSupport():Boolean {
		use namespace pureLegsCore;

		try {
			// dynamically get worker classes.
			WorkerClass = getDefinitionByName("flash.system.Worker") as Class;
			WorkerDomainClass = getDefinitionByName("flash.system.WorkerDomain") as Class;
		} catch (error:Error) {
			// do nothing.
		}

		if (WorkerClass && WorkerDomainClass && WorkerClass.isSupported) {
			_isSupported = true;
		}

		return _isSupported;
	}

	/**
	 * Starts background worker.
	 *        If workerSwfBytes property is not provided - rootSwfBytes will be used.
	 * @param workerModuleClass
	 * @param remoweModuleName
	 * @param workerSwfBytes
	 *
	 * @private
	 */
	static pureLegsCore function startWorker(mainModuleName:String, workerModuleClass:Class, remoweModuleName:String, workerSwfBytes:ByteArray = null
											 //debug:worker**/, debug_objectID:int = 0 //
			):void {
		use namespace pureLegsCore;

		// TODO : check extended form workerModule class.

		if (_isSupported) {
			//
			//debug:worker**/trace("      [" + mainModuleName + "]" + "WorkerManager: startWorkerModule: " + workerModuleClass, "isPrimordial:" + WorkerClass.current.isPrimordial
			//debug:worker**/ + "[" + debug_coreId + "]" + "<" + debug_objectID + "> ");

			//trace("WorkerClass.isSupported:", WorkerClass.isSupported);

			if (WorkerClass.current.isPrimordial) {
				var remoteWorker:Object;
				if (workerSwfBytes) {
					remoteWorker = WorkerDomainClass.current.createWorker(workerSwfBytes);
				} else if ($primordialSwfBytes) {
					remoteWorker = WorkerDomainClass.current.createWorker($primordialSwfBytes);
				} else {
					throw Error("Worker needs swf bytes to be constructed. You can pass it as 'workerSwfBytes' or set it from Main class with: WorkerManager.setRootSwfBytes(this.loaderInfo.bytes);");
				}
				$workerRegistry[remoweModuleName] = remoteWorker;

				// TEMP :  debug
				//debug:worker**/remoteWorker.addEventListener(Event.WORKER_STATE, debug_workerStateHandler);

				remoteWorker.setSharedProperty(REMOTE_MODULE_CLASS_NAME_KEY, getQualifiedClassName(workerModuleClass));

				// custom class aliases that needs to be geristered by remote worker.
				var classAliasNames:String = ClassAliasRegistry.getCustomClasses();
				remoteWorker.setSharedProperty(CLASS_ALIAS_NAMES_KEY, classAliasNames);

				// init custom worker messenger
				var messengerWorker:WorkerMessenger = getWorkerMessenger(remoweModuleName);
				$pendingWorkerMessengers[remoweModuleName] = messengerWorker;

				//
				connectRemoteWorker(remoteWorker, mainModuleName
						//debug:worker**/, debug_objectID //
				);
				//
				remoteWorker.start();

			} else {
				throw Error("Starting other workers only possible from main(primordial) worker.)");
			}
		} else {
			throw  Error("TODO");
		}
	}

	/**
	 * Tries to initialize main worker module,
	 *        or if it is copy of main swf - creates remote worker module.
	 * @param moduleName
	 * @param debug_objectID
	 * @return
	 *
	 * @private
	 */
	static pureLegsCore function initWorker(moduleName:String
											//debug:worker**/, debug_objectID:int //
			):Boolean {
		use namespace pureLegsCore;

		//debug:worker**/trace("      [" + moduleName + "]" + "WorkerManager: CONSTRUCT, 'primordial:", WorkerClass.current.isPrimordial
		//debug:worker**/ + "[" + debug_coreId + "]" + "<" + debug_objectID + "> ");

		if (WorkerClass.current.isPrimordial) { // check if primordial.
			var rootModuleName:String = WorkerClass.current.getSharedProperty(WORKER_MODULE_NAME_KEY);
			if (rootModuleName != null) { // check if root module is already created.
				throw Error("Only first(main) ModuleWorker can be instantiated. Use startWorker(MyBackgroundWorkerModule) to create background workers. ");
			} else { // PRIMORDIAL, MAIN.

				CONFIG::debug {
					if (!moduleName) {
						throw Error("Worker must have not empty moduleName. (It is used for module to module communication.)");
					}
				}
				WorkerClass.current.setSharedProperty(WORKER_MODULE_NAME_KEY, moduleName);

			}
		} else {
			// not primordial workers.

			// check if child must be created.
			var childModuleClassDefinition:String = WorkerClass.current.getSharedProperty(REMOTE_MODULE_CLASS_NAME_KEY);

			//debug:worker**/trace("      [" + moduleName + "]" + "WorkerManager: should init child module?:", childModuleClassDefinition
			//debug:worker**/ + "[" + debug_coreId + "]" + "<" + debug_objectID + "> ");

			if (childModuleClassDefinition) {
				// NOT PRIMORDIAL, COPY OF THE MAIN.

				//debug:worker**/trace("      [" + moduleName + "]" + "WorkerManager: moduleClass:", childModuleClassDefinition
				//debug:worker**/ + "[" + debug_coreId + "]" + "<" + debug_objectID + "> ");

				WorkerClass.current.setSharedProperty(REMOTE_MODULE_CLASS_NAME_KEY, null);

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

				// return false, to end this module.
				return false;
			} else {
				// NOT PRIMORDIAL, CHILD MODULE.

				WorkerClass.current.setSharedProperty(WORKER_MODULE_NAME_KEY, moduleName);

				// register all already used class aliases.
				var classAliasNames:String = WorkerClass.current.getSharedProperty(CLASS_ALIAS_NAMES_KEY);
				if (classAliasNames != "") {
					var classAliasSplit:Array = classAliasNames.split(",");
					for (var i:int = 0; i < classAliasSplit.length; i++) {
						registerClassNameAlias(classAliasSplit[i])
					}
				}

				setUpRemoteWorkerCommunication(moduleName
						//debug:worker**/, moduleName, debug_objectID //
				);
			}
		}
		return true;
	}

	/**
	 * Stops background worker.s
	 * @param workerModuleName
	 */
	static pureLegsCore function terminateWorker(workerModuleName:String
												 //debug:worker**/, debug_mainModuleName:String = null, debug_objectID:int = 0 //
			):void {
		use namespace pureLegsCore;

		//debug:worker**/trace("STOP worker :", workerModuleName);

		// todo : decide what to do, if current module name is sent.
		// todo : decide what to do if current worker is not primordial. (remote worker tries to terminate itself.)

		if (_isSupported) {
			var worker:Object = $workerRegistry[workerModuleName];
			if (worker) {

				// TODO : send message to other modules to remove channels with terminated worker.

				// remove channels from this module.
				for (var i:int = 0; i < $channelReadyWorkerNames.length; i++) {
					if ($channelReadyWorkerNames[i] == workerModuleName) {
						var thisToWorker:Object = $sendMessageChannels.splice(i, 1)[0];
						thisToWorker.close();
						var workerToThis:Object = $receiveMessageChannels.splice(i, 1)[0];
						workerToThis.removeEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);
						workerToThis.close();

						$channelReadyWorkerNames.splice(i, 1);
						break;
					}
				}
				worker.terminate();
				delete $workerRegistry[workerModuleName];
				delete workerMessengers[workerModuleName];
				delete $sendMessageChannelsRegistry[workerModuleName];
				delete $tempChannelStorage[workerModuleName];
				delete $pendingWorkerMessengers[workerModuleName];
			}
		} else {
			if ($workerRegistry[workerModuleName]) {
				($workerRegistry[workerModuleName] as ModuleCore).disposeModule();
				delete $workerRegistry[workerModuleName]
			}
		}
	}


	static private function connectRemoteWorker(remoteWorker:Object, debug_mainModuleName:String = null, debug_objectID:int = 0):void {
		use namespace pureLegsCore;

		// get all running workers
		var workers:* = WorkerDomainClass.current.listWorkers();
		//debug:worker**/trace("      [" + debug_mainModuleName + "]" + "connectChildWorker " + remoteWorker, "with", workers
		//debug:worker**/ + "[" + debug_coreId + "]" + "<" + debug_objectID + "> ");
		//
		for (var i:int = 0; i < workers.length; i++) {
			var worker:Object = workers[i];
			//
			// get model name from worker.
			var workerModuleName:String = worker.getSharedProperty(WORKER_MODULE_NAME_KEY);
			//worker.setSharedProperty(WORKER_MODULE_NAME_KEY, workerModuleName);
			//
			if (!$sendMessageChannelsRegistry[workerModuleName]) {
				var workerToRemote:Object = worker.createMessageChannel(remoteWorker);
				var remoteToWorker:Object = remoteWorker.createMessageChannel(worker);

				// store so they don't get garabage collected.
				$tempChannelStorage.push(workerToRemote);
				$tempChannelStorage.push(remoteToWorker);

				//
				remoteWorker.setSharedProperty("workerToRemote_" + workerModuleName, workerToRemote);
				remoteWorker.setSharedProperty("remoteToWorker_" + workerModuleName, remoteToWorker);

				//Listen to the response from our worker
				remoteToWorker.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);

			}
		}
	}


	static private function setUpRemoteWorkerCommunication(remoteModuleName:String
														   //debug:worker**/, debug_mainModuleName:String = null, debug_objectID:int = 0 //
			):void {
		// get all workers
		var workers:* = WorkerDomainClass.current.listWorkers();
		//debug:worker**/trace("      [" + debug_mainModuleName + "]" + "setUpWorkerCommunication " + workers
		//debug:worker**/ + "[" + debug_coreId + "]" + "<" + debug_objectID + "> ");
		//
		var thisWorker:Object = WorkerClass.current;
		for (var i:int = 0; i < workers.length; i++) {
			var worker:Object = workers[i];
			// TODO : decide what to do with self send messages...
			if (worker != WorkerClass.current) {
				if (worker.isPrimordial) {

					var workerModuleName:String = worker.getSharedProperty(WORKER_MODULE_NAME_KEY);
					//worker.setSharedProperty(WORKER_MODULE_NAME_KEY, workerModuleName);
//					//debug:worker**/trace("...processisng..." + workerModuleName);
					// handle communication permissions
					use namespace pureLegsCore;

					// init custom worker messenger
					getWorkerMessenger(workerModuleName).ready();

					//
					if (!$sendMessageChannelsRegistry[workerModuleName]) {
						var workerToThis:Object = thisWorker.getSharedProperty("workerToRemote_" + workerModuleName);
						var thisToWorker:Object = thisWorker.getSharedProperty("remoteToWorker_" + workerModuleName);
						//
						$sendMessageChannelsRegistry[workerModuleName] = thisToWorker;

						$sendMessageChannels.push(thisToWorker);
						$receiveMessageChannels.push(workerToThis);
						$channelReadyWorkerNames.push(workerModuleName);

						workerToThis.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);

						worker.setSharedProperty("thisToWorker_" + remoteModuleName, thisToWorker);
						worker.setSharedProperty("workerToThis_" + remoteModuleName, workerToThis);


						//debug:worker**/trace("INIT_REMOTE_WORKER !!! ", remoteModuleName);
						thisToWorker.send(INIT_REMOTE_WORKER_TYPE);
						thisToWorker.send(remoteModuleName);
					} else {
						throw Error("2 workers with same name should not exist.");
					}
				} //else {
				//trace("TODO : handle not main module...");
				//}
			}
		}
	}


	//----------------------------
	// messages
	//----------------------------

	static pureLegsCore function sendWorkerMessageToAllChannels(destinationModule:String, type:String, params:Object = null):void {
		//debug:worker**/trace("........WorkerManager.sendWorkerMessage()", type, params);

		use namespace pureLegsCore;

		var msgChannel:Object = $sendMessageChannelsRegistry[destinationModule];

		//for (var i:int = 0; i < $sendMessageChannels.length; i++) {
		//var msgChannel:Object = $sendMessageChannels[i];
		//trace("   " + msgChannel);
		msgChannel.send(SEND_WORKER_MESSAGE_TYPE);
		msgChannel.send(type);
		if (params) {
			msgChannel.send(params);
		}
		//}
	}


	static private function handleChannelMessage(event:Event):void {
		use namespace pureLegsCore;

		var channel:Object = event.target;

		if (channel.messageAvailable) {
			var communicationType:Object = channel.receive();


			//debug:worker**/var thisModuleName:String = WorkerClass.current.getSharedProperty(WORKER_MODULE_NAME_KEY);
			//debug:worker**/trace("  [" + thisModuleName + "]" + "handleChannelMessage : ", communicationType
			//debug:worker**/ + "[" + WorkerManager.debug_coreId + "]" + "<" + "" + "> ");

			if (communicationType == INIT_REMOTE_WORKER_TYPE) {
				// handle special communication for initialization of new worker.
				var remoteModuleName:String = channel.receive(true);

				//debug:worker**/trace("      [" + thisModuleName + "]" + "handle child module init! ", remoteModuleName
				//debug:worker**/ + "[" + debug_coreId + "]" + "<" + "debug_objectID" + "> ");

				var thisWorker:Object = WorkerClass.current;

				var workerToThis:Object = thisWorker.getSharedProperty("thisToWorker_" + remoteModuleName);
				var thisToWorker:Object = thisWorker.getSharedProperty("workerToThis_" + remoteModuleName);

				$sendMessageChannelsRegistry[remoteModuleName] = thisToWorker;

				$sendMessageChannels.push(thisToWorker);
				$receiveMessageChannels.push(workerToThis);
				$channelReadyWorkerNames.push(remoteModuleName);

				// send pending messages.
				delete $pendingWorkerMessengers[remoteModuleName]
				// remove  channels from temporal storage.
				for (var i:int = 0; i < $tempChannelStorage.length; i++) {
					if ($tempChannelStorage[i] == thisToWorker) {
						$tempChannelStorage.splice(i, 1);
						i--;
					} else if ($tempChannelStorage[i] == workerToThis) {
						$tempChannelStorage.splice(i, 1);
						i--;
					}
				}

				// ready messenger.
				var workerMessenger:WorkerMessenger = workerMessengers[remoteModuleName];
				workerMessenger.ready();

			} else if (communicationType == REGISTER_CLASS_ALIAS_TYPE) {
				// handle special message for registering class alias.
				var classQualifiedName:String = channel.receive(true) as String;
				registerClassNameAlias(classQualifiedName);

			} else if (communicationType == SEND_WORKER_MESSAGE_TYPE) {
				// handle worker to worker communication.
				var messageType:String = channel.receive(true) as String;
				var params:Object = channel.receive(true);
				//trace("       HANDLE SIMPLE MESSAGE!", messageType, params);
				var messageTypeSplit:Array = messageType.split("_^~_");

				//debug:worker**/trace("................ hendle remote send message..:", messageType, params);
				// TODO : rething if getting moduleName from worker valid here.(error scenarios?)
				var moduleName:String = WorkerClass.current.getSharedProperty(WORKER_MODULE_NAME_KEY);
				//WorkerClass.current.setSharedProperty(WORKER_MODULE_NAME_KEY, moduleName);
				handleReceivedWorkerMessage(moduleName, messageTypeSplit[0], messageTypeSplit[1], params);

			} else {
				throw Error("WorkerManager can't handle communicationType:" + communicationType + " This channel designed to be used by framework only.");
			}
		}
	}

	private static function handleReceivedWorkerMessage(sourceModule:String, destinationModule:String, type:String, params:Object):void {
		//debug:worker**/trace("...WorkerManager.wip_handleReceivedWorkerMessage()", sourceModule, destinationModule, type, params);
		// from outside to this...

		use namespace pureLegsCore;

		// get worker messenger, and trigger send.
		var workerMessenger:Messenger = workerMessengers[destinationModule];
		//debug:worker**/trace("....WorkerManager. .vorkerMessenger:", workerMessenger);
		if (workerMessenger) {
			workerMessenger.send(destinationModule + "_^~_" + type, params);
		}
	}


	//----------------------------------
	//	worker messenger handling.
	//----------------------------------

	private static function getWorkerMessenger(remoteModuleName:String):WorkerMessenger {
		//debug:worker**/trace("  WorkerManager.getWorkerMessenger(" + remoteModuleName + ")");

		var workerMesanger:WorkerMessenger = workerMessengers[remoteModuleName];
		if (!workerMesanger) {
			use namespace pureLegsCore;

			Messenger.allowInstantiation = true;
			workerMesanger = new WorkerMessenger("$worker_" + remoteModuleName);
			Messenger.allowInstantiation = false;
			workerMessengers[remoteModuleName] = workerMesanger;
		}
		return workerMesanger;
	}


	static pureLegsCore function sendWorkerMessage(fromModule:String, toModule:String, type:String, params:Object):void {
		// from this to outside.

		var workerMessenger:WorkerMessenger = workerMessengers[toModule];
		if (workerMessenger) {
			workerMessenger.workerSend(toModule, fromModule + "_^~_" + type, params);
		}

	}

	static pureLegsCore function addWorkerHandler(moduleName:String, remoteModuleName:String, type:String, handler:Function):HandlerVO {


		var workerMessenger:WorkerMessenger = workerMessengers[remoteModuleName];
		if (!workerMessenger) {
			workerMessenger = getWorkerMessenger(remoteModuleName);
		}
		return workerMessenger.addHandler(remoteModuleName + "_^~_" + type, handler);

	}

	static pureLegsCore function removeWorkerHandler(remoteModuleName:String, type:String, handler:Function):void {
		var workerMessenger:WorkerMessenger = workerMessengers[remoteModuleName];
		if (workerMessenger) {
			workerMessenger.removeHandler(remoteModuleName + "_^~_" + type, handler);
		}
	}


	//------------------------------
	//	class alias handling.
	//------------------------------

	static private function registerClassNameAlias(classQualifiedName:String):void {
		use namespace pureLegsCore;

		//trace("Registering new class...", classQualifiedName);

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
				throw Error("Failed to find class with definition:" + classQualifiedName + " in " + "moduleName" + " add this class to project or use registerClassAlias(" + classQualifiedName + ", YourClass); to register alternative class. ");
			}
		}
		//trace("Class got by definition:", mapClass)
		ClassAliasRegistry.mapClassAlias(mapClass, classQualifiedName);
	}


	static pureLegsCore function startClassRegistration(classFullName:String):void {
		//trace(" !! startClassRegistration", classFullName);
		use namespace pureLegsCore;

		for (var i:int = 0; i < $sendMessageChannels.length; i++) {
			$sendMessageChannels[i].send(REGISTER_CLASS_ALIAS_TYPE);
			$sendMessageChannels[i].send(classFullName);
		}
	}


	//-----------------------------
	//	Command handling
	//-----------------------------

	public static function workerCommandMap(moduleName:String, handleCommandExecute:Function, remoteModuleName:String, type:String, commandClass:Class):HandlerVO {
		var workerMessenger:WorkerMessenger = workerMessengers[remoteModuleName];
		if (!workerMessenger) {
			workerMessenger = getWorkerMessenger(remoteModuleName);
		}
		return workerMessenger.addCommandHandler(remoteModuleName + "_^~_" + type, handleCommandExecute, commandClass);
	}

	public static function workerCommandUnmap(handleCommandExecute:Function, remoteModuleName:String, type:String):void {
		var scopeMessenger:Messenger = workerMessengers[remoteModuleName];
		if (scopeMessenger) {
			scopeMessenger.removeHandler(remoteModuleName + "_^~_" + type, handleCommandExecute);
		}
	}

	//---------------------------------
	// DEBUG functions.
	//---------------------------------

	//debug:worker**/static private function debug_workerStateHandler(event:Event):void {
	//debug:worker**/    var childWorker:Object = event.target;
	//debug:worker**/    var moduleName:String = WorkerClass.current.getSharedProperty(WORKER_MODULE_NAME_KEY);
	//debug:worker**/    trace("      [" + moduleName + "]" + "WorkerManager: workerStateHandler- " + childWorker.state
	//debug:worker**/ + "[" + debug_coreId + "]" + "<" + "debug_objectID" + "> ");
	//debug:worker**/}
}
}
