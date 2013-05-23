package com.mindScriptAct.workerTest {
import com.mindScriptAct.workerTest.modules.ChildWorkerModule;

import org.mvcexpress.extensions.workers.modules.ModuleWorkerLive;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class MainWorkerTestModule extends ModuleWorkerLive {

	public function MainWorkerTestModule() {
		super("MainWorkerTestModule");
	}

	override protected function onInit():void {
		trace(this);
		var childModule:ChildWorkerModule = new ChildWorkerModule();
		this.addChild(childModule);
	}

	override protected function onDispose():void {

	}
}
}