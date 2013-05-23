package org.mvcexpress.extensions.workers.modules {
import com.demonsters.debugger.MonsterDebugger;

import flash.display.Sprite;
import flash.events.Event;

import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.utils.ByteArray;
import flash.utils.setTimeout;


dynamic public class ModuleWorker2 extends Sprite {

	/////////////////
	protected var testModuleName:String = "not set";
	private var worker:Worker;
	public static var primordialBytes:ByteArray;
	public var randNr:int = Math.random() * 100000000;

	public static const debugNr:int = Math.random() * 100000000;
	/////////////////

	public function ModuleWorker2(moduleName:String = null, autoInit:Boolean = true, initOnStage:Boolean = true) {
		trace("CONSTRUCT:" + moduleName, Worker.current.isPrimordial, randNr);
		/////////////////
		testModuleName = moduleName;
		if (Worker.current.isPrimordial) {
			if (primordialBytes) { // child worker module
				worker = WorkerDomain.current.createWorker(primordialBytes);
				worker.addEventListener(Event.WORKER_STATE, workerStateHandler);
				worker.start();
				trace("Child!!", randNr);
			} else { // first worker module
				primordialBytes = this.loaderInfo.bytes;
				trace("MAIN!!", randNr);
			}


		} else {
		}
		setTimeout(doTrace, 2000);
		/////////////////
		teskFunct();
	}

	private function workerStateHandler(event:Event):void {
		trace("worker state: " + worker.state, testModuleName, randNr, debugNr);
	}

	private function doTrace():void {
		MonsterDebugger.log("doTrace: " + testModuleName);
		trace("doTrace: " + testModuleName, randNr);


		setTimeout(doTrace, 2000);
	}


	protected function teskFunct():void {
		trace("doTrace!!!!!!!!!!!: " + testModuleName);
	}


	protected function startWorkerModule(moduleworkerClass:Class):void {


		var worker:Worker = WorkerDomain.current.createWorker(primordialBytes);
		worker.addEventListener(Event.WORKER_STATE, workerStateHandler);
		worker.start();
	}

}
}