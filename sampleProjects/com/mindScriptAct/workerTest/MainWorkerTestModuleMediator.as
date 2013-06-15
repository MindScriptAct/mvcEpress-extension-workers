package com.mindScriptAct.workerTest {
import com.mindScriptAct.modules.childModule.data.ChildDataNestVO;
import com.mindScriptAct.modules.childModule.data.ChildDataSwapTestVO;
import com.mindScriptAct.modules.childModule.data.ChildDataVO;
import com.mindScriptAct.modules.testModule.data.TestDataNestVO;
import com.mindScriptAct.modules.testModule.data.TestDataSwapTestVO;
import com.mindScriptAct.modules.testModule.data.TestDataVO;
import com.mindScriptAct.workerTest.data.MainDataNestVO;
import com.mindScriptAct.workerTest.data.MainDataSwapVO;
import com.mindScriptAct.workerTest.data.MainDataVO;
import com.mindScriptAct.workerTest.messages.Messages;
import com.mindScriptAct.workerTest.model.TestBitProxy;

import flash.text.TextField;
import flash.utils.setTimeout;

import org.mvcexpress.extensions.workers.modules.ModuleWorker;
import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;
import org.mvcexpress.mvc.Mediator;

/**
 * TODO:CLASS COMMENT
 * @author Deril
 */
public class MainWorkerTestModuleMediator extends Mediator {

	[Inject]
	public var view:MainWorkerTestModule;

	private var debugTextField:TextField;

	[Inject]
	public var testBitProxy:TestBitProxy;



	override public function onRegister():void {


		testBitProxy.writeString("Some test data!!!");


		addScopeHandler(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.CHILD_MAIN, handleWorkerString);
		addScopeHandler(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.CHILD_MAIN_OBJECT, handleWorkerObject);
		addScopeHandler(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.CHILD_MAIN_OBJECT_SWAP, handleWorkerObjectSwap);
		addScopeHandler(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.CHILD_MAIN_OBJECT_NEST, handleWorkerObjectNest);


		setTimeout(sendString, 0);
		setTimeout(sendObject, 2000);
		if (ModuleWorker.isWorkersSupported) {
			setTimeout(sendObjectSwap, 4000);
		}
		setTimeout(sendObjectNest, 6000);


		/////////////////////////////////

		addScopeHandler(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.TEST2_MAIN, handleWorkerString2);
		addScopeHandler(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.TEST2_MAIN_OBJECT, handleWorkerObject2);
		addScopeHandler(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.TEST2_MAIN_OBJECT_SWAP, handleWorkerObjectSwap2);
		addScopeHandler(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.TEST2_MAIN_OBJECT_NEST, handleWorkerObjectNest2);


		setTimeout(sendString2, 0 + 8000);
		setTimeout(sendObject2, 2000 + 8000);
		if (ModuleWorker.isWorkersSupported) {
			setTimeout(sendObjectSwap2, 4000 + 8000);
		}
		setTimeout(sendObjectNest2, 6000 + 8000);


//		sendString();
//		sendObject();
//		setTimeout(sendObjectNest, 1000);


		debugTextField = new TextField();
		debugTextField.text = "...";
		view.addChild(debugTextField);

		addScopeHandler(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.CHILD_MAIN_CALC, handleChildCalc);
		addScopeHandler(WorkerIds.MAIN_WORKER_TEST_MODULE, Messages.TEST2_MAIN_CALC, handleTest2Calc);

		sendScopeMessage(WorkerIds.CHILD_WORKER_MODULE, Messages.MAIN_CHILD_CALC, 100);
		sendScopeMessage(WorkerIds.TEST2_WORKER_MODULE, Messages.MAIN_TEST2_CALC, 100);

	}

	private function handleTest2Calc(calcData:String):void {
		debugTextField.text += "\n" + calcData;
	}

	private function handleChildCalc(calcData:String):void {
		debugTextField.text += "\n" + calcData;
	}

	////////////////////////////////

	private function sendString():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendString();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.CHILD_WORKER_MODULE, Messages.MAIN_CHILD, "MAIN > CHILD");
		setTimeout(sendString, 16000);
	}

	private function sendObject():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObject();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");

		sendScopeMessage(WorkerIds.CHILD_WORKER_MODULE, Messages.MAIN_CHILD_OBJECT, new MainDataVO("MAIN >> CHILD"));
		setTimeout(sendObject, 16000);
	}

	private function sendObjectSwap():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObjectSwap();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.CHILD_WORKER_MODULE, Messages.MAIN_CHILD_OBJECT_SWAP, new MainDataSwapVO("MAIN >>> CHILD"));
		setTimeout(sendObjectSwap, 16000);
	}

	private function sendObjectNest():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObjectNest();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.CHILD_WORKER_MODULE, Messages.MAIN_CHILD_OBJECT_NEST, new MainDataNestVO("MAIN >>>> CHILD"));

		setTimeout(sendObjectNest, 16000);
	}


	////////////////////////////////


	private function handleWorkerString(params:Object):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("2: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received string:", "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObject(params:ChildDataVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("4: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received object:", "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}


	private function handleWorkerObjectSwap(params:ChildDataSwapTestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("6: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received swapped object:", "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObjectNest(params:ChildDataNestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("8: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received nested object:", "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}


	//////////////////////////////////////////////////////////////////////////////////////


	private function sendString2():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendString2();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.TEST2_WORKER_MODULE, Messages.MAIN_TEST2, "MAIN > TEST2");
		setTimeout(sendString2, 16000);
	}

	private function sendObject2():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObject2();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.TEST2_WORKER_MODULE, Messages.MAIN_TEST2_OBJECT, new MainDataVO("MAIN >> TEST2"));
		setTimeout(sendObject2, 16000);
	}

	private function sendObjectSwap2():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObjectSwap2();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.TEST2_WORKER_MODULE, Messages.MAIN_TEST2_OBJECT_SWAP, new MainDataSwapVO("MAIN >>> TEST2"));
		setTimeout(sendObjectSwap2, 16000);
	}

	private function sendObjectNest2():void {
		trace("	[" + view.moduleName + "]" + ">>MainWorkerTestModule:sendObjectNest2();", "Debug module name: " + view.debug_getModuleName()
				+ "	[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> ");
		//MonsterDebugger.log("[" + ModuleWorkerBase.coreId + "]" + "<" + objectID + "> " + "[" + moduleName + "]" + "MainWorkerTestModule:sendString();");


		sendScopeMessage(WorkerIds.TEST2_WORKER_MODULE, Messages.MAIN_TEST2_OBJECT_NEST, new MainDataNestVO("MAIN >>>> TEST2"));

		setTimeout(sendObjectNest2, 16000);
	}


	////////////////////////////////


	private function handleWorkerString2(params:Object):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("10: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received string:", "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObject2(params:TestDataVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("12: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received object:", "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}


	private function handleWorkerObjectSwap2(params:TestDataSwapTestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("14: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received swapped object:", "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}

	private function handleWorkerObjectNest2(params:TestDataNestVO):void {
//		trace("[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]", "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received message:", params);
		trace("16: " + params, "!!!!!!!!!!!!!!!! MainWorkerTestModuleMediator received nested object:", "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + view.debug_objectID + "> " + "[" + view.moduleName + "]");
	}


	//////////////////////////////////////////////////////////////////////////////////////

	override public function onRemove():void {
		trace("TODO - implement MainWorkerTestModuleMediator function: onRemove().");
	}
}
}