package fcat.events
{
	import flash.events.Event;

	public class BookEvent extends Event
	{
		public static const PAGE_SELECT: String = "pageSelect";

		public var pageId: int;

		public function BookEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}