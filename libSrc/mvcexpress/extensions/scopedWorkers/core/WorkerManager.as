package mvcexpress.extensions.scopedWorkers.core {
import flash.utils.getDefinitionByName;

public class WorkerManager {


	private static var _isSupported:Boolean;


	public static var WorkerClass:Class;
	public static var WorkerDomainClass:Class;

	public static function checkWorkerSupport():Boolean {
		try {
			// dynamically get worker classes.
			WorkerClass = getDefinitionByName("flash.system.Worker") as Class;
			WorkerDomainClass = getDefinitionByName("flash.system.WorkerDomain") as Class;
		} catch (error:Error) {
			// do nothing.
		}

		if (WorkerClass && WorkerDomainClass && WorkerClass.isSupported) {
			_isSupported = true;
		}

		return _isSupported;
	}

	public static function get isSupported():Boolean {
		return _isSupported;
	}
}
}
