package childTest {
import flash.utils.getTimer;
import flash.utils.setTimeout;

import mvcexpress.extensions.workers.mvc.CommandWorker;

import constants.WorkerIds;
import constants.WorkerMessage;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class CpuIntensiveCommand extends CommandWorker {

	private var startingVal:int = 1000;

	private var lastPrime:int;

	public function execute(blank:Object = null):void {

		var startTime:int = getTimer();

		var prime:int = 0;

		for (var i:int = startingVal; i < startingVal + 5000; i++) { // 3 sec

			sendMessage(WorkerMessage.TEST2, i);
			sendWorkerMessage(WorkerIds.MAIN_WORKER, WorkerMessage.TEST2, i);

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

		trace("Highest prime:" + prime + "  [" + Math.floor((getTimer() - startTime)) + " ms spent.]");

		if (prime) {
			sendMessage(WorkerMessage.TEST1, prime);
			sendWorkerMessage(WorkerIds.MAIN_WORKER, WorkerMessage.TEST1, prime);
		}

		startingVal = prime + lastPrime + 1;
		lastPrime = prime;

		setTimeout(execute, 1);
	}

}
}
