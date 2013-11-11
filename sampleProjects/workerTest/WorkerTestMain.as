package workerTest {
import flash.display.Sprite;
import flash.events.Event;

import mvcexpress.extensions.workers.core.WorkerManager;

import workerTest.mainWorker.MainWorkerModule;

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

		WorkerManager.setRootSwfBytes(this.loaderInfo.bytes);

		module = new MainWorkerModule();
		module.start(this);

	}
}
}
