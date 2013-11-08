package childTest {
import flash.display.Sprite;
import flash.events.Event;

public class ChildTest extends Sprite {

	public function ChildTest():void {
		if (stage) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}


	private function init(event:Event = null):void {
		trace("ChildTest");

		var module:ChildTestModule = new ChildTestModule();

	}


}
}
