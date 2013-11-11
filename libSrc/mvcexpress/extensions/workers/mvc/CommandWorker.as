// Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
package mvcexpress.extensions.workers.mvc {
import mvcexpress.MvcExpress;
import mvcexpress.core.namespace.pureLegsCore;
import mvcexpress.extensions.workers.core.WorkerManager;
import mvcexpress.extensions.workers.core.traceObjects.command.TraceCommand_sendWorkerMessage;
import mvcexpress.extensions.workers.modules.ModuleWorker;
import mvcexpress.mvc.Command;

/**
 * Command, handles business logic of your application.                                                                                                    </br>
 * You most likely need it then:                                                                                                                            </br>
 *    - if you need to change application state with one or more logical statement.                                                                            </br>
 *    - if you need more then one unrelated proxies injected to make a decision.                                                                            </br>
 * Commands can get proxies injected and can send constants                                                                                                    </br>
 * <b><p>
 * It MUST contain custom execute(params:Object) function. Parameter can be typed as you wish.                                                                </br>
 * It is best practice to use same type as you use in message, that triggers this command.                                                                    </br>
 * If message does not send any parameter object - you still must have singe parameter, for example: execute(blank:Object). This parameter will be null.    </br>
 * </p></b>
 * @author Raimundas Banevicius (http://mvcexpress.org/)
 *
 * @version workers.2.0.rc1
 */
dynamic public class CommandWorker extends Command {

	//----------------------------------
	//     MESSAGING
	//----------------------------------

	/**
	 * Sends message from this worker to remote worker specified by worker name.
	 * @param    remoteWorkerModuleName    name of remote worker module, to send message to.
	 * @param    type        type of the message for Commands or Mediator's handle function to react to.
	 * @param    params        Object that will be passed to Command execute() function and to handle functions.
	 */
	protected function sendWorkerMessage(remoteWorkerModuleName:String, type:String, params:Object = null):void {
		use namespace pureLegsCore;

		// log the action
		CONFIG::debug {
			MvcExpress.debug(new TraceCommand_sendWorkerMessage(messenger.moduleName, this, type, params, true));
		}
		//
		WorkerManager.wip_sendWorkerMessage(messenger.moduleName, remoteWorkerModuleName, type, params);
		//
		// clean up logging the action
		CONFIG::debug {
			MvcExpress.debug(new TraceCommand_sendWorkerMessage(messenger.moduleName, this, type, params, false));
		}
	}

	//----------------------------------
	//    Extension checking: INTERNAL, DEBUG ONLY.
	//----------------------------------

	/** @private */
	CONFIG::debug
	static pureLegsCore var extension_id:int = ModuleWorker.pureLegsCore::EXTENSION_WORKER_ID;

	/** @private */
	CONFIG::debug
	static pureLegsCore var extension_name:String = ModuleWorker.pureLegsCore::EXTENSION_WORKER_NAME;

}
}