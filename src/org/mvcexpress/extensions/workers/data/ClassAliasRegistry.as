package org.mvcexpress.extensions.workers.data {
import flash.utils.Dictionary;

import org.mvcexpress.core.namespace.pureLegsCore;

public class ClassAliasRegistry {

	pureLegsCore const classes:Dictionary = new Dictionary();


	public function ClassAliasRegistry() {
		use namespace pureLegsCore;

		classes[null] = "null";
		classes[Boolean] = "Boolean";
		classes[int] = "int";
		classes[uint] = "uint";
		classes[Number] = "Number";
		classes[String] = "String";

		classes[Object] = "Object";
		classes[Array] = "Array";
		classes[Date] = "Date";
		classes[Error] = "Error";
		classes[Function] = "Function";
		classes[RegExp] = "RegExp";
		classes[XML] = "XML";
		classes[XMLList] = "XMLList";

	}


	public function getCustomClasses():String {
		use namespace pureLegsCore;

		var retVal:String = "";

		for each (var className:String in classes) {
			switch (className) {
				case "null":
				case "Boolean":
				case "int":
				case "uint":
				case "Number":
				case "String":
				case "Object":
				case "Array":
				case "Date":
				case "Error":
				case "Function":
				case "RegExp":
				case "XML":
				case "XMLList":
					break;
				default :
					if (retVal != "") {
						retVal += ",";
					}
					retVal += className;
					break;

			}
		}

		return retVal;
	}
}
}
