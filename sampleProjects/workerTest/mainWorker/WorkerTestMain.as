package workerTest.mainWorker {
import com.mindScriptAct.workerTest.MainWorkerTestModule;

import flash.display.Sprite;
import flash.events.Event;

import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;

public class WorkerTestMain extends Sprite {

	private var module:MainWorkerTestModule;

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

		ModuleWorkerBase.setRootSwfBytes(this.loaderInfo.bytes);

		module = new MainWorkerTestModule();

	}
}
}
