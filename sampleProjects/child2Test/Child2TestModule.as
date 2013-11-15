package child2Test {
import constants.WorkerIds;

import mvcexpress.extensions.workers.modules.ModuleWorker;

//public class ChildTestModule extends ModuleScoped {
public class Child2TestModule extends ModuleWorker {

	public function Child2TestModule() {
		super(WorkerIds.CHILD_WORKER);
	}


	override protected function onInit():void {

		commandMap.execute(CpuIntensiveCommand2)
	}

}
}
