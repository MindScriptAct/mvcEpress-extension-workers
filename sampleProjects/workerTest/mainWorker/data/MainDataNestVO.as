package workerTest.mainWorker.data {
public class MainDataNestVO {

	public var data:String = "?";

	public var nestData:MainDataVO = new MainDataVO("main nested data");

	private var _nestData_set:MainDataVO = new MainDataVO("main nested data set");

	private var _nestData_get:MainDataVO = new MainDataVO("main nested data get");

	private var _nestData_setget:MainDataVO = new MainDataVO("main nested data set and gets");


	public function MainDataNestVO(data:String = null) {
		this.data = data;
	}

	public function set nestData_set(value:MainDataVO):void {
		_nestData_set = value;
	}

	public function get nestData_get():MainDataVO {
		return _nestData_get;
	}

	public function set nestData_setget(value:MainDataVO):void {
		_nestData_setget = value;
	}

	public function get nestData_setget():MainDataVO {
		return _nestData_setget;
	}


}
}
