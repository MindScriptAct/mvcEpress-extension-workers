package workerTest.mainWorker {
import mvcexpress.extensions.scopedWorkers.core.WorkerManager;

import workerTest.constants.WorkerIds;
import workerTest.childWorker.data.ChildDataNestVO;
import workerTest.childWorker.data.ChildDataSwapTestVO;
import workerTest.childWorker.data.ChildDataVO;
import workerTest.testWorker.data.TestDataNestVO;
import workerTest.testWorker.data.TestDataSwapTestVO;
import workerTest.testWorker.data.TestDataVO;
import workerTest.mainWorker.data.MainDataNestVO;
import workerTest.mainWorker.data.MainDataSwapVO;
import workerTest.mainWorker.data.MainDataVO;
import workerTest.constants.Messages;

import flash.utils.setTimeout;

import mvcexpress.extensions.scoped.mvc.MediatorScoped;

import mvcexpress.extensions.scopedWorkers.modules.ModuleScopedWorker;

/**
 * TODO:CLASS COMMENT
 * @author Deril
 */
public class MainWorkerModuleMediator extends MediatorScoped {

	[Inject]
	public var view:MainWorkerModule;


	override protected function onRegister():void {

		addScopeHandler(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN, handleWorkerString);
		addScopeHandler(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_OBJECT, handleWorkerObject);
		addScopeHandler(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_OBJECT_SWAP, handleWorkerObjectSwap);
		addScopeHandler(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_OBJECT_NEST, handleWorkerObjectNest);


		setTimeout(sendString, 0);
		setTimeout(sendObject, 2000);
		if (ModuleScopedWorker.isWorkersSupported) {
			setTimeout(sendObjectSwap, 4000);
		}
		setTimeout(sendObjectNest, 6000);


		/////////////////////////////////

		addScopeHandler(WorkerIds.MAIN_WORKER, Messages.TEST2_MAIN, handleWorkerString2);
		addScopeHandler(WorkerIds.MAIN_WORKER, Messages.TEST2_MAIN_OBJECT, handleWorkerObject2);
		addScopeHandler(WorkerIds.MAIN_WORKER, Messages.TEST2_MAIN_OBJECT_SWAP, handleWorkerObjectSwap2);
		addScopeHandler(WorkerIds.MAIN_WORKER, Messages.TEST2_MAIN_OBJECT_NEST, handleWorkerObjectNest2);


		setTimeout(sendString2, 0 + 8000);
		setTimeout(sendObject2, 2000 + 8000);
		if (ModuleScopedWorker.isWorkersSupported) {
			setTimeout(sendObjectSwap2, 4000 + 8000);
		}
		setTimeout(sendObjectNest2, 6000 + 8000);


//		sendString();
//		sendObject();
//		setTimeout(sendObjectNest, 1000);


		//view.addChild(debugTextField);

		addScopeHandler(WorkerIds.MAIN_WORKER, Messages.CHILD_MAIN_CALC, view.handleChildCalc);
		addScopeHandler(WorkerIds.MAIN_WORKER, Messages.TEST2_MAIN_CALC, view.handleChildCalc);

		sendScopeMessage(WorkerIds.CHILD_WORKER, Messages.MAIN_CHILD_CALC, 100);
		sendScopeMessage(WorkerIds.TEST_WORKER, Messages.MAIN_TEST2_CALC, 100);

	}


	////////////////////////////////

	private function sendString():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendString();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.CHILD_WORKER, Messages.MAIN_CHILD, "MAIN > CHILD");
		setTimeout(sendString, 16000);
	}

	private function sendObject():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObject();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");

		sendScopeMessage(WorkerIds.CHILD_WORKER, Messages.MAIN_CHILD_OBJECT, new MainDataVO("MAIN >> CHILD"));
		setTimeout(sendObject, 16000);
	}

	private function sendObjectSwap():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObjectSwap();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.CHILD_WORKER, Messages.MAIN_CHILD_OBJECT_SWAP, new MainDataSwapVO("MAIN >>> CHILD"));
		setTimeout(sendObjectSwap, 16000);
	}

	private function sendObjectNest():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObjectNest();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.CHILD_WORKER, Messages.MAIN_CHILD_OBJECT_NEST, new MainDataNestVO("MAIN >>>> CHILD"));

		setTimeout(sendObjectNest, 16000);
	}


	////////////////////////////////


	private function handleWorkerString(params:Object):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("2: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received string:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObject(params:ChildDataVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("4: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}


	private function handleWorkerObjectSwap(params:ChildDataSwapTestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("6: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received swapped object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObjectNest(params:ChildDataNestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("8: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received nested object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}


	//////////////////////////////////////////////////////////////////////////////////////


	private function sendString2():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendString2();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.TEST_WORKER, Messages.MAIN_TEST2, "MAIN > TEST2");
		setTimeout(sendString2, 16000);
	}

	private function sendObject2():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObject2();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.TEST_WORKER, Messages.MAIN_TEST2_OBJECT, new MainDataVO("MAIN >> TEST2"));
		setTimeout(sendObject2, 16000);
	}

	private function sendObjectSwap2():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObjectSwap2();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.TEST_WORKER, Messages.MAIN_TEST2_OBJECT_SWAP, new MainDataSwapVO("MAIN >>> TEST2"));
		setTimeout(sendObjectSwap2, 16000);
	}

	private function sendObjectNest2():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObjectNest2();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.TEST_WORKER, Messages.MAIN_TEST2_OBJECT_NEST, new MainDataNestVO("MAIN >>>> TEST2"));

		setTimeout(sendObjectNest2, 16000);
	}


	////////////////////////////////


	private function handleWorkerString2(params:Object):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("10: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received string:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObject2(params:TestDataVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("12: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}


	private function handleWorkerObjectSwap2(params:TestDataSwapTestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("14: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received swapped object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObjectNest2(params:TestDataNestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("16: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received nested object:", "[" + WorkerManager.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}


	//////////////////////////////////////////////////////////////////////////////////////

	override protected function onRemove():void {
		trace("TODO - implement MainWorkerTestModuleMediator function: onRemove().");
	}
}
}