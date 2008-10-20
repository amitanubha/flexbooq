package fr.model.vo
{
	[Bindable]
	public class BookPageVO
	{
		public var pageId: int = -1;
		public var isFrontCover: Boolean = false;
		public var isBackCover: Boolean = false;

		public var thumb: String = "";
		public var source: String = "";

		public var downloadLink: String = "";

		public function BookPageVO()
		{
		}

		public function toString(): String
		{
			var pageType: String = "Page"
			if (isFrontCover)
			{
				pageType = "Front Cover";
			} else if (isBackCover)
			{
				pageType = "Back Cover";
			}
			return "[" + pageType + ", pageId=" + pageId + " ]";
		}

	}
}