package org.mvcexpress.extensions.workers.modules {
import flash.display.Sprite;
import flash.events.Event;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.utils.ByteArray;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import org.mvcexpress.core.namespace.pureLegsCore;

public class ModuleWorkerBase extends Sprite {


	private static const MODULE_NAME_KEY:String = "$_moduleName_$";
	private static const MODULE_CLASS_NAME_KEY:String = "$_moduleClassName_$";

	public static const debug_coreId:int = Math.random() * 100000000;

	public var debug_objectID:int = Math.random() * 100000000;

	private static var $primordialBytes:ByteArray;

	private var moduleName:String;

	pureLegsCore static var canInitChildModule:Boolean = false;

	pureLegsCore function checkWorker(moduleName:String):Boolean {
		use namespace pureLegsCore;

		this.moduleName = moduleName;
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: CONSTRUCT, 'primordial:", Worker.current.isPrimordial);
		if (Worker.current.isPrimordial) {
			if ($primordialBytes) {
				throw Error("Only first(main) ModuleWorker can be instantiated. Use createWorker(MyBackgroundWorkerModule) to create background workers. ");
			} else {
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
			if (!ModuleWorkerBase.canInitChildModule) {
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
				Worker.current.setSharedProperty(MODULE_NAME_KEY, moduleName);
			}
		}
		return true;
	}

	private var worker:Worker;
	// TODO : consider creating it as static public funcion.
	protected function startWorkerModule(workerModuleClass:Class):void {
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: startWorkerModule: " + workerModuleClass, "isPrimordial:" + Worker.current.isPrimordial);
		if (Worker.current.isPrimordial) {
			worker = WorkerDomain.current.createWorker($primordialBytes);
			worker.addEventListener(Event.WORKER_STATE, workerStateHandler);
			worker.setSharedProperty(MODULE_CLASS_NAME_KEY, getQualifiedClassName(workerModuleClass));
			worker.start();
		} else {
			throw Error("Starting child workers from other child workers not supported yet.)");
		}
	}


	private function workerStateHandler(event:Event):void {
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: workerStateHandler- " + worker.state);
	}

	public function debug_getModuleName():String {
		var retVal:String = Worker.current.getSharedProperty(MODULE_NAME_KEY);
		Worker.current.setSharedProperty(MODULE_NAME_KEY, retVal)
		return retVal;
	}

}
}
