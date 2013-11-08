package workerTest.childWorker {
import flash.display.Sprite;
import flash.events.Event;

public class ChildWorker extends Sprite {
	public function ChildWorker() {
		if (stage) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(event:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		var module:ChildWorkerModule = new ChildWorkerModule();

	}
}
}
