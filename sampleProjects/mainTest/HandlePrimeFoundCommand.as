package mainTest {
import mvcexpress.mvc.Command;

/**
 * @author rbanevicius
 */
public class HandlePrimeFoundCommand extends Command {

	public function execute(prime:int):void {
		trace("Prime is indeed found!", prime);
	}

}
}
