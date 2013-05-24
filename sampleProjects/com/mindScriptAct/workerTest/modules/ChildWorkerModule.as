package com.mindScriptAct.workerTest.modules {
import com.mindScriptAct.workerTest.WorkerIds;

import org.mvcexpress.extensions.workers.modules.ModuleWorker;
import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class ChildWorkerModule extends ModuleWorker {

	public function ChildWorkerModule() {
		super(WorkerIds.CHILD_WORKER_MODULE);
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:onInit();");


		mediatorMap.mediateWith(this, ChildWorkerModuleMediator);

	}


}
}