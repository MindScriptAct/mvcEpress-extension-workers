package com.mindScriptAct.workerTest.modules {
import org.mvcexpress.extensions.workers.modules.ModuleWorkerLive;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class ChildWorkerModule extends ModuleWorkerLive {

	public function ChildWorkerModule() {
		super("ChildWorkerModule");
	}

	override protected function onInit():void {
		trace(this);
	}


	override protected function onDispose():void {

	}
}
}