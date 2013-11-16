package mainTest {
import childTest.ChildTestModule;

import constants.WorkerIds;
import constants.WorkerMessage;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.net.URLRequest;
import flash.utils.setTimeout;

import mvcexpress.extensions.workers.modules.ModuleWorker;

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


		commandMapWorker.workerMap(WorkerIds.CHILD_WORKER, WorkerMessage.CHECKING_NUMBER, HandlePrimeFoundCommand)

		setTimeout(startModule, 500);

	}

	private function startModule():void {
		//var childModule:ChildTestModule = new ChildTestModule();

		//commandMap.execute(CpuIntensiveCommand);
		//startWorker(ChildTestModule, WorkerIds.CHILD_WORKER);

		var mLoader:Loader = new Loader();
		mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleChildLoadCompleate);
		mLoader.load(new URLRequest("ChildTest.swf"));

		/*



		 trace("is started?", isWorkerCreated(WorkerIds.CHILD_WORKER));

		 trace("list:", listWorkers());

		 terminateWorker(WorkerIds.CHILD_WORKER);

		 startWorker(ChildTestModule, WorkerIds.CHILD_WORKER);


		 //*/

	}

	private function handleChildLoadCompleate(event:Event):void {
		var loaderInfo:LoaderInfo = event.target as LoaderInfo;
		startWorker(ChildTestModule, WorkerIds.CHILD_WORKER, loaderInfo.bytes);
	}
}
}
