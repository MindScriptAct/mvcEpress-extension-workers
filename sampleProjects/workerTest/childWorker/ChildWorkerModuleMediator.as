package workerTest.childWorker {
import flash.utils.setTimeout;

import mvcexpress.extensions.scoped.mvc.MediatorScoped;
import mvcexpress.extensions.scopedWorkers.core.WorkerManager;
import mvcexpress.extensions.scopedWorkers.modules.ModuleScopedWorker;

import workerTest.childWorker.data.ChildDataNestVO;
import workerTest.childWorker.data.ChildDataSwapVO;
import workerTest.childWorker.data.ChildDataVO;
import workerTest.constants.Messages;
import workerTest.constants.WorkerIds;
import workerTest.mainWorker.data.MainDataNestVO;
import workerTest.mainWorker.data.MainDataSwapTestVO;
import workerTest.mainWorker.data.MainDataVO;

/**
 * TODO:CLASS COMMENT
 * @author Deril
 */
public class ChildWorkerModuleMediator extends MediatorScoped {

	[Inject]
	public var view:ChildWorkerModule;

	override protected function onRegister():void {

		addScopeHandler(WorkerIds.CHILD_WORKER, Messages.MAIN_CHILD, handleWorkerString);
		addScopeHandler(WorkerIds.CHILD_WORKER, Messages.MAIN_CHILD_OBJECT, handleWorkerObject);
		addScopeHandler(WorkerIds.CHILD_WORKER, Messages.MAIN_CHILD_OBJECT_SWAP, handleWorkerObjectSwap);
		addScopeHandler(WorkerIds.CHILD_WORKER, Messages.MAIN_CHILD_OBJECT_NEST, handleWorkerObjectNest);

		setTimeout(sendString, 1000);
		setTimeout(sendObject, 3000);
		if (ModuleScopedWorker.isWorkersSupported) {
			setTimeout(sendObjectSwap, 5000);
		}
		setTimeout(sendObjectNest, 7000);

//		sendString();
//		sendObject();
//		sendObjectNest();


//		setTimeout(sendObjectNest, 2000);

		addScopeHandler(WorkerIds.CHILD_WORKER, Messages.MAIN_CHILD_CALC, handleMainCalc);
	}

	private function handleMainCalc(testNumber:int):void {
		sendScopeMessage(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_CALC, "child div2... " + (testNumber / 2));
	}

	////////////////////////////////

	private function sendString():void {
		trace("	[" + view.moduleName + "]" + ">>ChildWorkerModule:sendString();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");

		sendScopeMessage(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN, "CHILD > MAIN");
		setTimeout(sendString, 16000);
	}

	private function sendObject():void {
		trace("	[" + view.moduleName + "]" + ">>ChildWorkerModule:sendObject();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");

		sendScopeMessage(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_OBJECT, new ChildDataVO("CHILD >> MAIN"));
		setTimeout(sendObject, 16000);
	}

	private function sendObjectSwap():void {
		trace("	[" + view.moduleName + "]" + ">>ChildWorkerModule:sendObjectSwap();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");

		sendScopeMessage(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_OBJECT_SWAP, new ChildDataSwapVO("CHILD >>> MAIN"));
		setTimeout(sendObjectSwap, 16000);
	}


	private function sendObjectNest():void {
		trace("	[" + view.moduleName + "]" + ">>ChildWorkerModule:sendObjectNest();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");

		sendScopeMessage(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_OBJECT_NEST, new ChildDataNestVO("CHILD >>>> MAIN"));
		setTimeout(sendObjectNest, 16000);
	}

	////////////////////////////////

	private function handleWorkerString(params:Object):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received message:", params);
		trace("1: " + params, "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received string:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObject(params:MainDataVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received message:", params);
		trace("3: " + params, "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObjectSwap(params:MainDataSwapTestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received message:", params);
		trace("5: " + params, "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received swapped object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObjectNest(params:MainDataNestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received message:", params);
		trace("7: " + params, "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received nested object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	override protected function onRemove():void {
		trace("TODO - implement ChildWorkerModuleMediator function: onRemove().");
	}
}
}