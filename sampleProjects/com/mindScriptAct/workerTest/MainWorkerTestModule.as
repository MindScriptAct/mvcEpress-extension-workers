package com.mindScriptAct.workerTest {

import com.demonsters.debugger.MonsterDebugger;
import com.mindScriptAct.workerTest.modules.ChildWorkerModule;

import flash.utils.setTimeout;

import org.mvcexpress.extensions.workers.modules.ModuleWorker;
import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;

public class MainWorkerTestModule extends ModuleWorker {

	public function MainWorkerTestModule() {
		super("MainWorkerTestModule");
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		trace("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:onInit();");

		startWorkerModule(ChildWorkerModule);

		traceModule();
	}

	private function traceModule():void {
		trace("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:traceModule();");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:traceModule();");

		setTimeout(traceModule, 5000);
	}

}
}
