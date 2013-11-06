package workerTest.testWorker {
import flash.system.Worker;

import workerTest.constants.WorkerIds;
import workerTest.mainWorker.data.MainDataSwapTestVO;

import flash.net.registerClassAlias;

import mvcexpress.extensions.scopedWorkers.modules.ModuleScopedWorker;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class TestWorkerModule extends ModuleScopedWorker {

	public function TestWorkerModule() {
		super(WorkerIds.TEST_WORKER);
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		trace("---[" + moduleName + "]" + "TestWorkerModule:onInit();"
				+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");

		CONFIG::debug {
			if (Worker.current.isPrimordial) {
				registerScope(WorkerIds.MAIN_WORKER, true, true);
				registerScope(WorkerIds.TEST_WORKER, true, true);
			}
		}

		registerClassAlias("workerTest.mainWorker.data.MainDataSwapVO", MainDataSwapTestVO);


		mediatorMap.mediateWith(this, TestWorkerModuleMediator);

	}


}
}