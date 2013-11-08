package mvcexpress.extensions.scopedWorkers.modules {
import flash.utils.ByteArray;

import mvcexpress.core.ExtensionManager;
import mvcexpress.core.namespace.pureLegsCore;
import mvcexpress.extensions.scoped.modules.ModuleScoped;
import mvcexpress.extensions.scopedWorkers.core.WorkerManager;

//import flash.system.MessageChannel;
//import flash.system.Worker;
//import flash.system.WorkerDomain;
public class ModuleScopedWorker extends ModuleScoped {




	//---------------------
	// internal properties
	//---------------------
	// worker support
	private static var needWorkerSupportCheck:Boolean = true;
	private static var _isWorkersSupported:Boolean;// = false;

	public var debug_objectID:int = Math.random() * 100000000;


	public function ModuleScopedWorker(moduleName:String, mediatorMapClass:Class = null, proxyMapClass:Class = null, commandMapClass:Class = null, messengerClass:Class = null) {

		trace("-----[" + moduleName + "]" + "ModuleWorker: try to create module."
				+ "[" + WorkerManager.debug_coreId + "]" + "<" + debug_objectID + "> ");

		use namespace pureLegsCore;

		CONFIG::debug {
			enableExtension(EXTENSION_WORKER_ID);
		}

		if (needWorkerSupportCheck) {
			needWorkerSupportCheck = false;
			_isWorkersSupported = WorkerManager.checkWorkerSupport();
		}

		var canCreateModule:Boolean = true;


		if (_isWorkersSupported) {
			canCreateModule = WorkerManager.initWorker(moduleName, debug_objectID);
		} else {
			trace("TODO - not supported worker scenario.");
//			if (ModuleScopedWorker.canInitChildModule) {
//
//				// todo : get this name better.
//				var workerModuleName:String = WorkerIds.MAIN_WORKER;
//
//				ScopeManager.registerScope(debug_moduleName, workerModuleName, true, true, false);
//				ScopeManager.registerScope(debug_moduleName, debug_moduleName, true, true, false);
//				ScopeManager.registerScope(workerModuleName, workerModuleName, true, true, false);
//			}
		}


		if (canCreateModule) {
			trace("-----[" + moduleName + "]" + "ModuleWorker: Create module!"
					+ "[" + WorkerManager.debug_coreId + "]" + "<" + debug_objectID + "> ");
			super(moduleName, mediatorMapClass, proxyMapClass, commandMapClass, messengerClass);
		}

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
		use namespace pureLegsCore;

		WorkerManager.createBackgroundWorker(workerModuleClass, workerModuleName, workerSwfBytes, moduleName, debug_objectID);
	}

	/**
	 * Stops background worker.s
	 * @param workerModuleName
	 */
	public function terminateBackgroundWorker(workerModuleName:String):void {
		use namespace pureLegsCore;

		WorkerManager.terminateBackgroundWorker(workerModuleName, moduleName, debug_objectID);
	}


	//////////////////////////////
	//	INTERNALS
	//////////////////////////////

	public function debug_getModuleName():String {
		if (_isWorkersSupported) {
			var retVal:String = WorkerManager.WorkerClass.current.getSharedProperty("$_mn_$");
			WorkerManager.WorkerClass.current.setSharedProperty("$_mn_$", retVal);
			return retVal;
		} else {
//			throw  Error("TODO");
			return moduleName;
		}
	}

	static pureLegsCore function debug_sendMessage(type:String, params:Object = null):void {
//		trace(" !! demo_sendMessage", type, params);
		use namespace pureLegsCore;

		for (var i:int = 0; i < WorkerManager.$sendMessageChannels.length; i++) {
			var msgChannel:Object = WorkerManager.$sendMessageChannels[i];
//			trace("   " + msgChannel);
			msgChannel.send("$_sm_$");
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
