package com.mindScriptAct.binaryTest {
import flash.display.Sprite;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.describeType;
import flash.utils.setTimeout;

public class BinaryTest extends Sprite {

	private var bytes:ByteArray;

	public function BinaryTest() {


		registerClassAlias("com.mindScriptAct.binaryTest.DemoWorkerProxy", DemoWorkerProxy);

		var test:DemoWorkerProxy = new DemoWorkerProxy();

		var def:XML = describeType(DemoWorkerProxy);

		test.publicVar = "data1";

		test.getSetVar = "data2";

		test.setCustomGetterSetterVar("data3");

		bytes = new ByteArray();
		bytes.writeObject(test);

		setTimeout(decodeTest, 1000);

	}

	private function decodeTest():void {
		bytes.position = 0;

		var obj:DemoWorkerProxy = bytes.readObject() as DemoWorkerProxy;

		trace(obj.publicVar);
		trace(obj.getSetVar);
		trace(obj.getCustomGetterSetterVar());

	}
}
}
