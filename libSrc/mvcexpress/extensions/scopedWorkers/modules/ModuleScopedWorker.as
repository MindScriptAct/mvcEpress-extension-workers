package mvcexpress.extensions.scopedWorkers.modules {
import flash.system.Worker;
import flash.utils.ByteArray;

import mvcexpress.core.ExtensionManager;
import mvcexpress.core.namespace.pureLegsCore;
import mvcexpress.extensions.scoped.modules.ModuleScoped;
import mvcexpress.extensions.scopedWorkers.core.WorkerManager;

public class ModuleScopedWorker extends ModuleScoped {

	// worker support
	private static var needWorkerSupportCheck:Boolean = true;

	// true if workers are supported.
	private static var _isWorkersSupported:Boolean;// = false;

	// TEMP... for Debug only..
	public var debug_objectID:int = Math.random() * 100000000;

	/**
	 * CONSTRUCTOR. ModuleName must be provided.
	 * @inheritDoc
	 */
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

		// stores if this module will be created. (then same swf file is used to create other modules - main module will not be created.)
		var canCreateModule:Boolean = true;

		if (_isWorkersSupported) {
			canCreateModule = WorkerManager.initWorker(moduleName, debug_objectID);
		} else {
			trace("TODO - implement scenario then workers are not supported.");
			//if (ModuleScopedWorker.canInitChildModule) {
			//
			//	// todo : get this name better.
			//	var workerModuleName:String = WorkerIds.MAIN_WORKER;
			//
			//	ScopeManager.registerScope(debug_moduleName, workerModuleName, true, true, false);
			//	ScopeManager.registerScope(debug_moduleName, debug_moduleName, true, true, false);
			//	ScopeManager.registerScope(workerModuleName, workerModuleName, true, true, false);
			//}
		}

		if (canCreateModule) {
			trace("-----[" + moduleName + "]" + "ModuleWorker: Create module!"
					+ "[" + WorkerManager.debug_coreId + "]" + "<" + debug_objectID + "> ");
			super(moduleName, mediatorMapClass, proxyMapClass, commandMapClass, messengerClass);
		}

	}

	/**
	 * Starts background worker.
	 *        If workerSwfBytes property is not provided - rootSwfBytes will be used.
	 * @param workerModuleClass
	 * @param workerModuleName
	 * @param workerSwfBytes    bytes of loaded swf file.
	 */
	public function startWorker(workerModuleClass:Class, workerModuleName:String, workerSwfBytes:ByteArray = null):void {

		// todo : implement optional module parameters for extendability.
		use namespace pureLegsCore;

		WorkerManager.startWorker(moduleName, workerModuleClass, workerModuleName, workerSwfBytes, debug_objectID);
	}

	/**
	 * terminates background worker and dispose worker module.
	 * @param workerModuleName
	 */
	public function terminateWorker(workerModuleName:String):void {
		use namespace pureLegsCore;

		WorkerManager.terminateWorker(workerModuleName, moduleName, debug_objectID);
	}


	//////////////////////////////
	//	DEBUG...S
	//////////////////////////////

	public function debug_getModuleName():String {
		use namespace pureLegsCore;

		if (_isWorkersSupported) {
			var retVal:String = Worker.current.getSharedProperty("$_wmn_$");
			Worker.current.setSharedProperty("$_wmn_$", retVal);
			return retVal;
		} else {
			return moduleName;
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
