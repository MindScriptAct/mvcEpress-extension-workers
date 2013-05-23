package com.mindScriptAct.workerTest.modules {
import com.demonsters.debugger.MonsterDebugger;

import flash.utils.setTimeout;

import org.mvcexpress.extensions.workers.modules.ModuleWorker;
import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class ChildWorkerModule extends ModuleWorker {

	public function ChildWorkerModule() {
		super("ChildWorkerModule");
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		trace("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:onInit();");

		traceModule();
	}

	private function traceModule():void {
		trace("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");

		setTimeout(traceModule, 5000);
	}

}
}