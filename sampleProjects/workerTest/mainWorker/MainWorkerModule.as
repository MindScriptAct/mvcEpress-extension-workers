package workerTest.mainWorker {
import constants.TestConsts;
import constants.WorkerIds;

import flash.net.registerClassAlias;
import flash.text.TextField;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import mvcexpress.core.namespace.pureLegsCore;
import mvcexpress.extensions.workers.core.WorkerManager;
import mvcexpress.extensions.workers.modules.ModuleWorker;

import workerTest.WorkerTestMain;
import workerTest.childWorker.ChildWorkerModule;
import workerTest.childWorker.data.ChildDataSwapTestVO;
import workerTest.testWorker.*;
import workerTest.testWorker.data.TestDataSwapTestVO;

public class MainWorkerModule extends ModuleWorker {

	public function MainWorkerModule() {
		super(WorkerIds.MAIN_WORKER);
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		/**debug:worker**/trace("  -[" + moduleName + "]" + "MainWorkerTestModule:onInit();");

		registerClassAlias("workerTest.childWorker.data.ChildDataSwapVO", ChildDataSwapTestVO);
		registerClassAlias("workerTest.testWorker.data.TestDataSwapVO", TestDataSwapTestVO);

	}


	private function doStopTestModule():void {
		terminateWorker(WorkerIds.TEST_WORKER);
	}

	private function doStartTestModule():void {
		startWorker(TestWorkerModule, WorkerIds.TEST_WORKER);
	}

	private var debugTextField:TextField;

	public function start(main:WorkerTestMain):void {

		debugTextField = new TextField();
		debugTextField.text = "...";
		main.addChild(debugTextField);


		startWorker(ChildWorkerModule, WorkerIds.CHILD_WORKER);

		startWorker(TestWorkerModule, WorkerIds.TEST_WORKER);

		mediatorMap.mediateWith(this, MainWorkerModuleMediator);

		setTimeout(doStopTestModule, TestConsts.START_DELAY + 16000 + 200);
		setTimeout(doStartTestModule, TestConsts.START_DELAY + 32000 + 200);

	}

	public function handleChildCalc(debugData:String):void {
		debugTextField.text += "\n" + debugData;
	}

	public function setRootSwfBytes(rootSwfBytes:ByteArray):void {
		use namespace pureLegsCore;

		WorkerManager.setRootSwfBytes(rootSwfBytes);
	}
}
}
