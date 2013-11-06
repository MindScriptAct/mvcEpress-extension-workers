package com.mindScriptAct.workerTest {

import com.mindScriptAct.modules.childModule.ChildWorkerModule;
import com.mindScriptAct.modules.childModule.data.ChildDataSwapTestVO;
import com.mindScriptAct.modules.testModule.TestWorkerModule;
import com.mindScriptAct.modules.testModule.data.TestDataSwapTestVO;

import flash.net.registerClassAlias;
import flash.text.TextField;
import flash.utils.setTimeout;

import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;

import workerTest.mainWorker.WorkerTestMain;

public class MainWorkerTestModule extends ModuleWorkerBase {

	public function MainWorkerTestModule() {
		super(WorkerIds.MAIN_WORKER_TEST_MODULE);
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		trace("---[" + moduleName + "]" + "MainWorkerTestModule:onInit();"
				+ "[" + ModuleWorkerBase.debug_coreId + "]" + "<" + debug_objectID + "> ");

		registerClassAlias("com.mindScriptAct.modules.childModule.data.ChildDataSwapVO", ChildDataSwapTestVO);
		registerClassAlias("com.mindScriptAct.modules.testModule.data.TestDataSwapVO", TestDataSwapTestVO);


		startWorkerModule(ChildWorkerModule, WorkerIds.CHILD_WORKER_MODULE);

		startWorkerModule(TestWorkerModule, WorkerIds.TEST2_WORKER_MODULE);

		mediatorMap.mediateWith(this, MainWorkerTestModuleMediator);


		setTimeout(doStopTestModule, 16000 + 100);
		setTimeout(doStartTestModule, 32000 + 100);
	}


	private function doStopTestModule():void {
		stopWorkerModule(WorkerIds.TEST2_WORKER_MODULE);
	}

	private function doStartTestModule():void {
		startWorkerModule(TestWorkerModule, WorkerIds.TEST2_WORKER_MODULE);
	}

	private var debugTextField:TextField;

	public function start(main:WorkerTestMain):void {

		debugTextField = new TextField();
		debugTextField.text = "...";
		main.addChild(debugTextField);
	}

	public function handleChildCalc(debugData:String):void {
		debugTextField.text += "\n" + debugData;
	}
}
}
