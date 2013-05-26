package com.mindScriptAct.workerTest.modules {
import com.mindScriptAct.workerTest.WorkerIds;
import com.mindScriptAct.workerTest.messages.Messages;

import flash.utils.setTimeout;

import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;
import org.mvcexpress.mvc.Mediator;

/**
 * TODO:CLASS COMMENT
 * @author Deril
 */
public class ChildWorkerModuleMediator extends Mediator {

	[Inject]
	public var view:ChildWorkerModule;

	override public function onRegister():void {

		// traceModule();

		setTimeout(traceModule, 2000);
		setTimeout(addHandlerTest, 5000);
	}

	private function addHandlerTest():void {
		addScopeHandler(WorkerIds.CHILD_WORKER_MODULE, Messages.MAIN_CHILD, handleWorkerMessage);
	}


	private function traceModule():void {
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]" + "ChildWorkerModule:traceModule();", "Debug module name: " + view.debug_getModuleName());
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");



		sendScopeMessage(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.CHILD_MAIN, "CHILD > MAIN");
		setTimeout(traceModule, 2000);
	}

	private function handleWorkerMessage(params:Object):void {
		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received message:", params);
	}



	override public function onRemove():void {
		trace("TODO - implement ChildWorkerModuleMediator function: onRemove().");
	}
}
}