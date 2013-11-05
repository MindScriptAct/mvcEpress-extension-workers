package com.mindScriptAct.modules.testModule {
import com.mindScriptAct.workerTest.WorkerIds;
import com.mindScriptAct.workerTest.data.MainDataSwapTestVO;

import flash.net.registerClassAlias;

import org.mvcexpress.extensions.workers.modules.ModuleWorker;
import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class TestWorkerModule extends ModuleWorker {

	public function TestWorkerModule() {
		super(WorkerIds.TEST2_WORKER_MODULE);
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		trace("---[" + moduleName + "]" + "TestWorkerModule:onInit();"
				+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");

		registerClassAlias("com.mindScriptAct.workerTest.data.MainDataSwapVO", MainDataSwapTestVO);


		mediatorMap.mediateWith(this, TestWorkerModuleMediator);

	}


}
}