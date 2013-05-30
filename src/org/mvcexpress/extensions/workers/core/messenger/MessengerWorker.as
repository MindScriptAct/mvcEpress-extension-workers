package org.mvcexpress.extensions.workers.core.messenger {
import org.mvcexpress.core.messenger.Messenger;
import org.mvcexpress.core.namespace.pureLegsCore;
import org.mvcexpress.extensions.workers.modules.ModuleWorkerBase;

public class MessengerWorker extends Messenger {

	public function MessengerWorker($moduleName:String) {
		super($moduleName);
	}


	override public function send(type:String, params:Object = null):void {
		//super.send(type, params);
//		trace("    MessengerWorker     send", type, params);
		use namespace pureLegsCore;
		ModuleWorkerBase.demo_sendMessage(type, params);
	}
}
}
