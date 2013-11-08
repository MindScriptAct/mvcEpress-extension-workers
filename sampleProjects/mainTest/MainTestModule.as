package mainTest {
import childTest.ChildTestModule;

import flash.system.Worker;
import flash.utils.setTimeout;

import mvcexpress.extensions.scopedWorkers.modules.ModuleScopedWorker;

import workerTest.constants.WorkerIds;

//public class MainTestModule extends ModuleScoped {
public class MainTestModule extends ModuleScopedWorker {

	public function MainTestModule() {
		super(WorkerIds.MAIN_WORKER);
	}


	override protected function onInit():void {
		CONFIG::debug {
			if (Worker.current.isPrimordial) {
				//registerScope(WorkerIds.CHILD_WORKER, false, true);
				//registerScope(WorkerIds.MAIN_WORKER, false, true);
			}
		}
	}

	override protected function onDispose():void {

	}

	public function start(mainTest:MainTest):void {

		startWorker(ChildTestModule, WorkerIds.CHILD_WORKER);

		mediatorMap.mediateWith(mainTest, MainTestMediator);


		setTimeout(startModule, 500)


	}

	private function startModule():void {
		//var childModule:ChildTestModule = new ChildTestModule();

		// FIXME : does not work properly.. messenger is overwritten.
		//startWorker(ChildTestModule, WorkerIds.CHILD_WORKER);


	}
}
}
