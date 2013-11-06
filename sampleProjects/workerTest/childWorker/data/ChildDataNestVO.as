package workerTest.childWorker.data {
public class ChildDataNestVO {

	public var data:String = "?";

	public var nestData:ChildDataVO = new ChildDataVO("child nested data");

	public function ChildDataNestVO(data:String = null) {
		this.data = data;
	}

}
}
