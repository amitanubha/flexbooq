package fcat.events
{
	import flash.events.Event;

	public class BookEvent extends Event
	{
		public static const PAGE_SELECT: String = "pageSelect";
		public static const PAGE_ZOOM_COMPLETE: String = "pageZoomComplete";

		public var pageId: int;

		public var isZoomedIn: Boolean;

		public function BookEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}