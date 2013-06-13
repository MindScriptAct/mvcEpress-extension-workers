package com.mindScriptAct.binaryTest {
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

import org.mvcexpress.mvc.Proxy;

public class DemoWorkerProxy extends Proxy /*implements IExternalizable*/ {

	public var publicVar:String = "BAD-publicVar";

	private var _getSetVar:String = "BAD-getSetVar";


	private var _customGetterSetterVar:String = "BAD-customGetterSetterVar";


	public function get getSetVar():String {
		return _getSetVar;
	}

	public function set getSetVar(value:String):void {
		_getSetVar = value;
	}


	public function getCustomGetterSetterVar():String {
		return _customGetterSetterVar;
	}

	public function setCustomGetterSetterVar(value:String):void {
		_customGetterSetterVar = value;
	}
/*
	public function writeExternal(output:IDataOutput):void {
		output.writeUTF(publicVar);
		output.writeUTF(_getSetVar);
		output.writeUTF(_customGetterSetterVar);
	}

	public function readExternal(input:IDataInput):void {
		publicVar = input.readUTF();
		_getSetVar = input.readUTF();
		_customGetterSetterVar = input.readUTF();
	}*/
}
}
