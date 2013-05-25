package com.mindScriptAct.workerTest {
import flash.utils.setTimeout;

import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;
import org.mvcexpress.mvc.Mediator;

/**
 * TODO:CLASS COMMENT
 * @author Deril
 */
public class MainWorkerTestModuleMediator extends Mediator {

	[Inject]
	public var view:MainWorkerTestModule;

	override public function onRegister():void {
		traceModule();
	}


	private function traceModule():void {
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]" + "MainWorkerTestModule:traceModule();", "Debug module name: " + view.debug_getModuleName());
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:traceModule();");

		setTimeout(traceModule, 2000);
	}

	override public function onRemove():void {
		trace("TODO - implement MainWorkerTestModuleMediator function: onRemove().");
	}
}
}