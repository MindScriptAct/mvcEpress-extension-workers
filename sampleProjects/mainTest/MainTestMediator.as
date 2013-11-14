package mainTest {


import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import mvcexpress.extensions.workers.mvc.MediatorWorker;

import mx.core.FlexTextField;

import constants.WorkerIds;
import constants.WorkerMessage;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class MainTestMediator extends MediatorWorker {

	[Inject]
	public var view:MainTest;

	private var primeTest:TextField;
	private var primeFound:TextField;

	private var animaton:Sprite;

	override protected function onRegister():void {

		primeTest = new FlexTextField();
		primeTest.text = "...";
		primeTest.y = 110;
		view.addChild(primeTest);
		addHandler(WorkerMessage.CHECKING_NUMBER, handlePrimeDataTest);
		addWorkerHandler(WorkerIds.CHILD_WORKER, WorkerMessage.CHECKING_NUMBER, handlePrimeDataTest);

		primeFound = new FlexTextField();
		primeFound.text = "waiting for data...";
		primeFound.y = 130;
		view.addChild(primeFound);
		addHandler(WorkerMessage.PRIME_FOUND, handlePrimeData);
		addWorkerHandler(WorkerIds.CHILD_WORKER, WorkerMessage.PRIME_FOUND, handlePrimeData);

		animaton = new Sprite();
		animaton.graphics.lineStyle(2, 0xFF0000);
		animaton.graphics.lineTo(0, 50);

		animaton.x = 200;
		animaton.y = 200;


		view.addChild(animaton);

		view.addEventListener(Event.ENTER_FRAME, handleAnimation)
	}

	private function handleAnimation(event:Event):void {
		animaton.rotation += 10;
	}

	private function handlePrimeData(prime:int):void {
		primeFound.autoSize = TextFieldAutoSize.LEFT;
		primeFound.text = "prime found :" + prime;
	}

	private function handlePrimeDataTest(prime:int):void {
		primeTest.autoSize = TextFieldAutoSize.LEFT;
		primeTest.text = "     (testing :" + prime + ")";
	}

	override protected function onRemove():void {

	}
}
}