package fcat.model
{
	import fcat.ApplicationControl;

	import mx.core.UIComponent;

	public class Parameters
	{
		public function get configPath(): String
		{
			return "cxml.xml" + ApplicationControl.applicationControl.urlRandomizer;
		}

		public function Parameters( appReference: UIComponent )
		{
			trace("New paramteres: " + appReference);
		}
	}
}