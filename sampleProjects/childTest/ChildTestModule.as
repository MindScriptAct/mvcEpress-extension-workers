package childTest {
import flash.system.Worker;

import mvcexpress.extensions.scoped.modules.ModuleScoped;
import mvcexpress.extensions.scopedWorkers.modules.ModuleScopedWorker;

import workerTest.constants.WorkerIds;

//public class ChildTestModule extends ModuleScoped {
public class ChildTestModule extends ModuleScopedWorker {

	public function ChildTestModule() {
		super(WorkerIds.CHILD_WORKER);
	}


	override protected function onInit():void {

		CONFIG::debug {
			if (Worker.current.isPrimordial) {
				//registerScope(WorkerIds.CHILD_WORKER, true);
			}
		}

		commandMap.execute(CpuIntensiveCommand)
	}

}
}
