package workerTest {
import workerTest.mainWorker.*;
import workerTest.mainWorker.MainWorkerModule;

import flash.display.Sprite;
import flash.events.Event;

import mvcexpress.extensions.scopedWorkers.modules.ModuleScopedWorker;

public class WorkerTestMain extends Sprite {

	private var module:MainWorkerModule;

	public function WorkerTestMain() {
		if (stage) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(event:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		///

		ModuleScopedWorker.setRootSwfBytes(this.loaderInfo.bytes);

		module = new MainWorkerModule();
		module.start(this);

	}
}
}