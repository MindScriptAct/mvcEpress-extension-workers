package workerTest.mainWorker {
import flash.system.Worker;

import workerTest.testWorker.*;

import flash.net.registerClassAlias;
import flash.text.TextField;
import flash.utils.setTimeout;

import mvcexpress.extensions.scopedWorkers.modules.ModuleScopedWorker;

import workerTest.constants.WorkerIds;
import workerTest.childWorker.ChildWorkerModule;
import workerTest.childWorker.data.ChildDataSwapTestVO;
import workerTest.WorkerTestMain;
import workerTest.testWorker.data.TestDataSwapTestVO;

public class MainWorkerModule extends ModuleScopedWorker {

	public function MainWorkerModule() {
		super(WorkerIds.MAIN_WORKER);
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		trace("---[" + moduleName + "]" + "MainWorkerTestModule:onInit();"
				+ "[" + ModuleScopedWorker.debug_coreId + "]" + "<" + debug_objectID + "> ");

		registerClassAlias("workerTest.childWorker.data.ChildDataSwapVO", ChildDataSwapTestVO);
		registerClassAlias("workerTest.testWorker.data.TestDataSwapVO", TestDataSwapTestVO);

		CONFIG::debug {
			if (Worker.current.isPrimordial) {
				registerScope(WorkerIds.MAIN_WORKER, true, true);
				registerScope(WorkerIds.TEST_WORKER, true, true);
			}
		}


		createBackgroundWorker(ChildWorkerModule, WorkerIds.CHILD_WORKER);

		createBackgroundWorker(TestWorkerModule, WorkerIds.TEST_WORKER);

		mediatorMap.mediateWith(this, MainWorkerModuleMediator);


		setTimeout(doStopTestModule, 16000 + 100);
		setTimeout(doStartTestModule, 32000 + 100);
	}


	private function doStopTestModule():void {
		terminateBackgroundWorker(WorkerIds.TEST_WORKER);
	}

	private function doStartTestModule():void {
		createBackgroundWorker(TestWorkerModule, WorkerIds.TEST_WORKER);
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
