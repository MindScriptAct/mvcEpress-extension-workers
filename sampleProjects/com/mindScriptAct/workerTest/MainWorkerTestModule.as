package com.mindScriptAct.workerTest {

import com.mindScriptAct.workerTest.modules.ChildWorkerModule;

import org.mvcexpress.extensions.workers.modules.ModuleWorker;
import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;

public class MainWorkerTestModule extends ModuleWorker {

	public function MainWorkerTestModule() {
		super(WorkerIds.MAIN_WORKER_TEST_MODULE);
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:onInit();");

		startWorkerModule(ChildWorkerModule);

		mediatorMap.mediateWith(this, MainWorkerTestModuleMediator)

	}


}
}
