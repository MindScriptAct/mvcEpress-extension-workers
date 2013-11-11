package workerTest.childWorker {
import flash.net.registerClassAlias;
import flash.system.Worker;

import mvcexpress.extensions.workers.core.WorkerManager;
import mvcexpress.extensions.workers.modules.ModuleWorker;

import constants.WorkerIds;
import workerTest.mainWorker.data.MainDataSwapTestVO;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class ChildWorkerModule extends ModuleWorker {

	public function ChildWorkerModule() {
		super(WorkerIds.CHILD_WORKER);
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		//debug:worker**/trace("  -[" + moduleName + "]" + "ChildWorkerModule:onInit();"
		//debug:worker**/ + "[" + WorkerManager.debug_coreId + "]" + "<" + debug_objectID + "> ");

		// ??? why this is needed?
		registerClassAlias("workerTest.mainWorker.data.MainDataSwapVO", MainDataSwapTestVO);


		mediatorMap.mediateWith(this, ChildWorkerModuleMediator);

	}

}
}