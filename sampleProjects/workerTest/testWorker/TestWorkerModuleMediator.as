package workerTest.testWorker {
import constants.Messages;
import constants.TestConsts;
import constants.WorkerIds;

import flash.system.Worker;

import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mvcexpress.extensions.workers.core.WorkerManager;
import mvcexpress.extensions.workers.mvc.MediatorWorker;

import workerTest.mainWorker.data.MainDataNestVO;
import workerTest.mainWorker.data.MainDataSwapTestVO;
import workerTest.mainWorker.data.MainDataVO;
import workerTest.testWorker.data.TestDataNestVO;
import workerTest.testWorker.data.TestDataSwapVO;
import workerTest.testWorker.data.TestDataVO;

/**
 * TODO:CLASS COMMENT
 * @author Deril
 */
public class TestWorkerModuleMediator extends MediatorWorker {

	[Inject]
	public var view:TestWorkerModule;

	private var to1:int;
	private var to2:int;
	private var to3:int;
	private var to4:int;

	override protected function onRegister():void {

		addWorkerHandler(WorkerIds.MAIN_WORKER, Messages.MAIN_TEST, handleWorkerString);
		addWorkerHandler(WorkerIds.MAIN_WORKER, Messages.MAIN_TEST_OBJECT, handleWorkerObject);
		addWorkerHandler(WorkerIds.MAIN_WORKER, Messages.MAIN_TEST_OBJECT_SWAP, handleWorkerObjectSwap);
		addWorkerHandler(WorkerIds.MAIN_WORKER, Messages.MAIN_TEST_OBJECT_NEST, handleWorkerObjectNest);
//
		to1 = setTimeout(sendString, TestConsts.START_DELAY + 1000 + 8000);
		to2 = setTimeout(sendObject, TestConsts.START_DELAY + 3000 + 8000);
		if (WorkerManager.isWorkersSupported) {
			to3 = setTimeout(sendObjectSwap, TestConsts.START_DELAY + 5000 + 8000);
		}
		to4 = setTimeout(sendObjectNest, TestConsts.START_DELAY + 7000 + 8000);

//		sendString();
//		sendObject();
//		sendObjectNest();


//		setTimeout(sendObjectNest, 2000);

		addWorkerHandler(WorkerIds.MAIN_WORKER, Messages.MAIN_TEST_CALC, handleMainCalc);
	}

	private function handleMainCalc(testNumber:int):void {
		sendWorkerMessage(WorkerIds.MAIN_WORKER, Messages.TEST_MAIN_CALC, "Test2 mult2... " + (testNumber * 2));
	}

	////////////////////////////////

	private function sendString():void {
		///debug:worker**/trace("[" + view.moduleName + "]" + ">>TestWorkerModule:sendString();", "Debug module name: " + Worker.current.getSharedProperty("$_wmn_$")
		///debug:worker**/ + "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "TestWorkerModule:traceModule();");

		sendWorkerMessage(WorkerIds.MAIN_WORKER, Messages.TEST_MAIN, "TEST2 > MAIN");
		to1 = setTimeout(sendString, 16000);
	}

	//*

	private function sendObject():void {
		///debug:worker**/trace("[" + view.moduleName + "]" + ">>TestWorkerModule:sendObject();", "Debug module name: " + Worker.current.getSharedProperty("$_wmn_$")
		///debug:worker**/ + "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "TestWorkerModule:traceModule();");

		sendWorkerMessage(WorkerIds.MAIN_WORKER, Messages.TEST_MAIN_OBJECT, new TestDataVO("TEST2 >> MAIN"));
		to2 = setTimeout(sendObject, 16000);
	}

	private function sendObjectSwap():void {
		///debug:worker**/trace("[" + view.moduleName + "]" + ">>TestWorkerModule:sendObjectSwap();", "Debug module name: " + Worker.current.getSharedProperty("$_wmn_$")
		///debug:worker**/ + "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "TestWorkerModule:traceModule();");

		sendWorkerMessage(WorkerIds.MAIN_WORKER, Messages.TEST_MAIN_OBJECT_SWAP, new TestDataSwapVO("TEST2 >>> MAIN"));
		to3 = setTimeout(sendObjectSwap, 16000);
	}


	private function sendObjectNest():void {
		///debug:worker**/trace("[" + view.moduleName + "]" + ">>TestWorkerModule:sendObjectNest();", "Debug module name: " + Worker.current.getSharedProperty("$_wmn_$")
		///debug:worker**/ + "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "TestWorkerModule:traceModule();");

		sendWorkerMessage(WorkerIds.MAIN_WORKER, Messages.TEST_MAIN_OBJECT_NEST, new TestDataNestVO("TEST2 >>>> MAIN"));
		to4 = setTimeout(sendObjectNest, 16000);
	}

	// */

	////////////////////////////////

	//*
	private function handleWorkerString(params:Object):void {
		//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! TestWorkerModuleMediator received message:", params);
		///debug:worker**/trace("9: " + params, "!!!!!!!!!!!!!!!! TestWorkerModuleMediator received string:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObject(params:MainDataVO):void {
		//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! TestWorkerModuleMediator received message:", params);
		///debug:worker**/trace("11: " + params, "!!!!!!!!!!!!!!!! TestWorkerModuleMediator received object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObjectSwap(params:MainDataSwapTestVO):void {
		//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! TestWorkerModuleMediator received message:", params);
		///debug:worker**/trace("13: " + params, "!!!!!!!!!!!!!!!! TestWorkerModuleMediator received swapped object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObjectNest(params:MainDataNestVO):void {
		//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! TestWorkerModuleMediator received message:", params);
		///debug:worker**/trace("15: " + params, "!!!!!!!!!!!!!!!! TestWorkerModuleMediator received nested object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	override protected function onRemove():void {
//		trace("TODO - implement TestWorkerModuleMediator function: onRemove().");

		clearTimeout(to1);
		clearTimeout(to2);
		clearTimeout(to3);
		clearTimeout(to4);


	}

	//*/

}
}