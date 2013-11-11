package mainTest {
import childTest.ChildTestModule;
import childTest.CpuIntensiveCommand;

import constants.WorkerMessage;

import flash.system.Worker;
import flash.utils.setTimeout;

import mvcexpress.core.traceObjects.commandMap.TraceCommandMap_execute;

import mvcexpress.extensions.workers.modules.ModuleWorker;

import constants.WorkerIds;

//public class MainTestModule extends ModuleScoped {
public class MainTestModule extends ModuleWorker {

	public function MainTestModule() {
		super(WorkerIds.MAIN_WORKER);
	}


	override protected function onInit():void {
	}

	override protected function onDispose():void {

	}

	public function start(mainTest:MainTest):void {

		mediatorMap.mediateWith(mainTest, MainTestMediator);


		commandMapWorker.workerMap(WorkerIds.CHILD_WORKER, WorkerMessage.TEST2, HandlePrimeFoundCommand)

		setTimeout(startModule, 500)


	}

	private function startModule():void {
		//var childModule:ChildTestModule = new ChildTestModule();

		startWorker(ChildTestModule, WorkerIds.CHILD_WORKER);
		//commandMap.execute(CpuIntensiveCommand);

	}
}
}
