package fcat
{
	import fcat.model.Parameters;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getTimer;

	import mx.core.Application;
	import mx.utils.URLUtil;

	public class ApplicationControl extends EventDispatcher
	{
		public var parameters: Parameters;
		private var app: Application;

		private static var instance: ApplicationControl;

		public function ApplicationControl(target:IEventDispatcher=null)
		{
			super(target);
		}

		public function initApp(app: Application): void
		{
			trace( "init app: " + app );

			this.app = app;

			parameters = new Parameters( app );
		}

		public function get url(): String
		{
			return app.systemManager.loaderInfo.url.replace( /\w+.swf/gi, '' );
		}

		public function get urlRandomizer(): String
		{
			return "?rand=" + String(Math.round((Math.random() * 1000 + getTimer())));
		}

		public function get serverUrl(): String
		{
//			trace("APP URL : " + URLUtil.getFullURL( app.systemManager.loaderInfo.url ) );
//			return "http://" + URLUtil.getServerName( app.systemManager.loaderInfo.url ) + "/";
			return URLUtil.getServerName( app.systemManager.loaderInfo.url );
		}

		public static function get applicationControl(): ApplicationControl
		{
			if( instance == null )
			{
				instance = new ApplicationControl();
			}
			return instance;
		}
	}
}