package childTest {
import mvcexpress.extensions.workers.display.WorkerSprite;

public class ChildTest extends WorkerSprite {


	override protected function init():void {
		trace("ChildTest");

		var module:ChildTestModule = new ChildTestModule();

	}


}
}
