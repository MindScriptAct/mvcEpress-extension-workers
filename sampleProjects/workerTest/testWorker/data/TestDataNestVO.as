package workerTest.testWorker.data {
public class TestDataNestVO {

	public var data:String = "?";

	public var nestData:TestDataVO = new TestDataVO("test nested data");

	public function TestDataNestVO(data:String = null) {
		this.data = data;
	}

}
}
