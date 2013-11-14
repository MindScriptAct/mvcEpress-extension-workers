package childTest {

import mvcexpress.extensions.workers.modules.ModuleWorker;

import constants.WorkerIds;

//public class ChildTestModule extends ModuleScoped {
public class ChildTestModule extends ModuleWorker {

	public function ChildTestModule() {
		super(WorkerIds.CHILD_WORKER);
	}


	override protected function onInit():void {

		commandMap.execute(CpuIntensiveCommand)
	}

}
}
