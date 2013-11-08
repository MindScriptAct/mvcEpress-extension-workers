package childTest {
import flash.utils.getTimer;
import flash.utils.setTimeout;

import mvcexpress.extensions.scoped.mvc.CommandScoped;

import workerTest.constants.WorkerIds;
import workerTest.constants.WorkerMessage;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class CpuIntensiveCommand extends CommandScoped {

	private var startingVal:int = 1000;

	private var lastPrime:int;

	public function execute(blank:Object = null):void {

		var startTime:int = getTimer();

		var prime:int = 0;

		for (var i:int = startingVal; i < startingVal + 5000; i++) { // 3 sec

			sendScopeMessage(WorkerIds.MAIN_WORKER, WorkerMessage.TEST2, i);

			var isPrime:Boolean = true;
			for (var j:int = i - 1; j > 1; j--) {
				if (i % j == 0) {
					isPrime = false;
					break;
				}
			}
			if (isPrime) {
				prime = i;
				break;
			}
		}
		//}

		trace("Highest prime:" + prime + "  [" + Math.floor((getTimer() - startTime)) + " sec spent.]");

		if (prime) {
			sendScopeMessage(WorkerIds.MAIN_WORKER, WorkerMessage.TEST1, prime);
		}

		startingVal = prime + lastPrime + 1;
		lastPrime = prime;

		setTimeout(execute, 1);
	}

}
}
