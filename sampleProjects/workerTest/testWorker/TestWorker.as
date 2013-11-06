package workerTest.testWorker {
import flash.display.Sprite;
import flash.events.Event;

public class TestWorker extends Sprite {
	public function TestWorker() {
		if (stage) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(event:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		var module:TestWorkerModule = new TestWorkerModule();

	}
}
}
