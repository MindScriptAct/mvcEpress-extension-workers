package com.mindScriptAct.workerTest.model {
import com.mindScriptAct.workerTest.messages.Messages;

import flash.utils.ByteArray;

import org.mvcexpress.mvc.Proxy;

/**
 * TODO:CLASS COMMENT
 * @author Deril
 */
public class TestBitProxy extends Proxy {


	var bites:ByteArray = new ByteArray();


	public function TestBitProxy() {
	}

	override protected function onRegister():void {

	}

	override protected function onRemove():void {
	}

	public function writeString(data:String):void {
		bites.clear();
		bites.writeUTF(data);
		sendMessage(Messages.TEST_DATA_CHANGE)
	}

	public function readString():String {
		bites.position = 0;
		return bites.readUTF();
	}
}
}