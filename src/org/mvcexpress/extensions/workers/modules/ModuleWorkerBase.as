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

	public static const coreId:int = Math.random() * 100000000;

	protected var objectID:int = Math.random() * 100000000;

	private static var $primordialBytes:ByteArray;

	private var moduleName:String;

	pureLegsCore static var canInitChildModule:Boolean = false;

	pureLegsCore function checkWorker(moduleName:String = null):Boolean {
		use namespace pureLegsCore;
		this.moduleName = moduleName;
		trace("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: CONSTRUCT, 'primordial:", Worker.current.isPrimordial);
		if (Worker.current.isPrimordial) {
			if ($primordialBytes) {
				throw Error("Only first(main) ModuleWorker can be instantiated. Use createWorker(MyBackgroundWorkerModule) to create background workers. ");
			} else {
				$primordialBytes = this.loaderInfo.bytes
			}
		} else {
			trace("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: can init child module?:", ModuleWorkerBase.canInitChildModule);
			if (!ModuleWorkerBase.canInitChildModule) {
				var childModuleClassDefinition:String = Worker.current.getSharedProperty("_$moduleClass");
				trace("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: moduleClass:", childModuleClassDefinition);
				if (childModuleClassDefinition) {
					Worker.current.setSharedProperty("_$moduleClass", null);
					var childModuleClass:Class = getDefinitionByName(childModuleClassDefinition) as Class;



					ModuleWorkerBase.canInitChildModule = true;
					var childModule:ModuleWorker = new childModuleClass();

					ModuleWorkerBase.canInitChildModule = true;
				}
				return false;
			}
		}
		return true;
	}

	private var worker:Worker;
	// TODO : consider creating it as static public funcion.
	protected function startWorkerModule(workerModuleClass:Class):void {
		trace("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: startWorkerModule: " + workerModuleClass, "isPrimordial:" + Worker.current.isPrimordial);
		if (Worker.current.isPrimordial) {
			worker = WorkerDomain.current.createWorker($primordialBytes);
			worker.addEventListener(Event.WORKER_STATE, workerStateHandler);
			worker.setSharedProperty("_$moduleClass", getQualifiedClassName(workerModuleClass));
			worker.start();
		} else {
			throw Error("Starting child workers from other child workers not supported yet.)");
		}
	}


	private function workerStateHandler(event:Event):void {
		trace("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ModuleWorkerBase: workerStateHandler- " + worker.state);
	}

}
}
