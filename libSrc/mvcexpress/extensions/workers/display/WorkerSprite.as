package mvcexpress.extensions.workers.display {
import flash.display.Sprite;
import flash.events.Event;
import flash.system.Worker;
import flash.utils.getDefinitionByName;

import mvcexpress.core.namespace.pureLegsCore;
import mvcexpress.extensions.workers.core.WorkerManager;

use namespace pureLegsCore;

public class WorkerSprite extends Sprite {

	// worker support
	private static var needWorkerSupportCheck:Boolean = true;

	// true if workers are supported.
	private static var _isWorkersSupported:Boolean;// = false;

	public function WorkerSprite() {

		if (needWorkerSupportCheck) {
			needWorkerSupportCheck = false;
			_isWorkersSupported = WorkerManager.checkWorkerSupport();
		}

		if (stage) {
			doInit();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, doInit);
		}
	}


	private function doInit(event:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		if (Worker.current.isPrimordial) {
			WorkerManager.setRootSwfBytes(this.loaderInfo.bytes);
			init();
		} else {
			// get module class.

			var childModuleClassDefinition:String = WorkerManager.WorkerClass.current.getSharedProperty(WorkerManager.pureLegsCore::REMOTE_MODULE_CLASS_NAME_KEY);
			if (childModuleClassDefinition) {

				try {
					var childModuleClass:Class = getDefinitionByName(childModuleClassDefinition) as Class;
				} catch (error:Error) {
					trace("Failed to get class definition for " + childModuleClassDefinition);
				}

				// create module.
				if (childModuleClass) {
					try {
						var childModule:Object = new childModuleClass();
					} catch (error:Error) {
						trace("Failed to construct module class :" + error);
					}
				}

			} else {
				throw Error("Module class name must be stored in worker shared properties, for it to be constructed.");
			}
		}
	}

	protected function init():void {
		throw Error("Override init() to start your application. (avoid using constructor - it will be executed in worker too.)");
	}

}
}
