package com.mindScriptAct.modules.childModule {
import com.mindScriptAct.workerTest.WorkerIds;
import com.mindScriptAct.workerTest.data.MainDataSwapTestVO;

import flash.net.registerClassAlias;

import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class ChildWorkerModule extends ModuleWorkerBase {

	public function ChildWorkerModule() {
		super(WorkerIds.CHILD_WORKER_MODULE);
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		trace("---[" + moduleName + "]" + "ChildWorkerModule:onInit();"
				+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");

		registerClassAlias("com.mindScriptAct.workerTest.data.MainDataSwapVO", MainDataSwapTestVO);


		mediatorMap.mediateWith(this, ChildWorkerModuleMediator);

	}


}
}