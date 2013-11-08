package mainTest {


import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import mvcexpress.extensions.scoped.mvc.MediatorScoped;

import mx.core.FlexTextField;

import workerTest.constants.WorkerIds;
import workerTest.constants.WorkerMessage;

/**
 * TODO:CLASS COMMENT
 * @author rbanevicius
 */
public class MainTestMediator extends MediatorScoped {

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
		addScopeHandler(WorkerIds.CHILD_WORKER, WorkerMessage.TEST2, handlePrimeDataTest);
		addScopeHandler(WorkerIds.MAIN_WORKER, WorkerMessage.TEST2, handlePrimeDataTest);

		primeFound = new FlexTextField();
		primeFound.text = "waiting for data...";
		primeFound.y = 130;
		view.addChild(primeFound);
		addScopeHandler(WorkerIds.CHILD_WORKER, WorkerMessage.TEST1, handlePrimeData);
		addScopeHandler(WorkerIds.MAIN_WORKER, WorkerMessage.TEST1, handlePrimeData);


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