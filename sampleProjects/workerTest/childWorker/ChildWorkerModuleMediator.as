package workerTest.childWorker {
import constants.TestConsts;

import flash.system.Worker;

import flash.utils.setTimeout;

import mvcexpress.extensions.workers.core.WorkerManager;
import mvcexpress.extensions.workers.mvc.MediatorWorker;

import workerTest.childWorker.data.ChildDataNestVO;
import workerTest.childWorker.data.ChildDataSwapVO;
import workerTest.childWorker.data.ChildDataVO;
import constants.Messages;
import constants.WorkerIds;
import workerTest.mainWorker.data.MainDataNestVO;
import workerTest.mainWorker.data.MainDataSwapTestVO;
import workerTest.mainWorker.data.MainDataVO;

/**
 * TODO:CLASS COMMENT
 * @author Deril
 */
public class ChildWorkerModuleMediator extends MediatorWorker {

	[Inject]
	public var view:ChildWorkerModule;

	override protected function onRegister():void {

		addWorkerHandler(WorkerIds.MAIN_WORKER, Messages.MAIN_CHILD, handleWorkerString);
		addWorkerHandler(WorkerIds.MAIN_WORKER, Messages.MAIN_CHILD_OBJECT, handleWorkerObject);
		addWorkerHandler(WorkerIds.MAIN_WORKER, Messages.MAIN_CHILD_OBJECT_SWAP, handleWorkerObjectSwap);
		addWorkerHandler(WorkerIds.MAIN_WORKER, Messages.MAIN_CHILD_OBJECT_NEST, handleWorkerObjectNest);

		setTimeout(sendString, TestConsts.START_DELAY + 1000);
		setTimeout(sendObject, TestConsts.START_DELAY + 3000);
		if (WorkerManager.isSupported) {
			setTimeout(sendObjectSwap, TestConsts.START_DELAY + 5000);
		}
		setTimeout(sendObjectNest, TestConsts.START_DELAY + 7000);

//		sendString();
//		sendObject();
//		sendObjectNest();


//		setTimeout(sendObjectNest, 2000);

		addWorkerHandler(WorkerIds.MAIN_WORKER, Messages.MAIN_CHILD_CALC, handleMainCalc);
	}

	private function handleMainCalc(testNumber:int):void {
		sendWorkerMessage(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_CALC, "child div2... " + (testNumber / 2));
	}

	////////////////////////////////

	private function sendString():void {

		trace("                                    .")
		/**debug:worker**/trace("[" + view.moduleName + "]" + ">>ChildWorkerModule:sendString();", "Debug module name: " + Worker.current.getSharedProperty("$_wmn_$")
		/**debug:worker**/ + "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");

		sendWorkerMessage(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN, "CHILD > MAIN");
		setTimeout(sendString, 16000);
	}

	private function sendObject():void {
		/**debug:worker**/trace("[" + view.moduleName + "]" + ">>ChildWorkerModule:sendObject();", "Debug module name: " + Worker.current.getSharedProperty("$_wmn_$")
		/**debug:worker**/ + "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");

		sendWorkerMessage(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_OBJECT, new ChildDataVO("CHILD >> MAIN"));
		setTimeout(sendObject, 16000);
	}

	private function sendObjectSwap():void {
		/**debug:worker**/trace("[" + view.moduleName + "]" + ">>ChildWorkerModule:sendObjectSwap();", "Debug module name: " + Worker.current.getSharedProperty("$_wmn_$")
		/**debug:worker**/ + "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");

		sendWorkerMessage(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_OBJECT_SWAP, new ChildDataSwapVO("CHILD >>> MAIN"));
		setTimeout(sendObjectSwap, 16000);
	}


	private function sendObjectNest():void {
		/**debug:worker**/trace("[" + view.moduleName + "]" + ">>ChildWorkerModule:sendObjectNest();", "Debug module name: " + Worker.current.getSharedProperty("$_wmn_$")
		/**debug:worker**/ + "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "ChildWorkerModule:traceModule();");

		sendWorkerMessage(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_OBJECT_NEST, new ChildDataNestVO("CHILD >>>> MAIN"));
		setTimeout(sendObjectNest, 16000);
	}

	////////////////////////////////

	private function handleWorkerString(params:Object):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received message:", params);
		/**debug:worker**/trace("1: " + params, "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received string:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObject(params:MainDataVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received message:", params);
		/**debug:worker**/trace("3: " + params, "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObjectSwap(params:MainDataSwapTestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received message:", params);
		/**debug:worker**/trace("5: " + params, "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received swapped object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObjectNest(params:MainDataNestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received message:", params);
		/**debug:worker**/trace("7: " + params, "!!!!!!!!!!!!!!!! ChildWorkerModuleMediator received nested object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	override protected function onRemove():void {
		trace("TODO - implement ChildWorkerModuleMediator function: onRemove().");
	}
}
}