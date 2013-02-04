package lagden.ui
{
	import app.events.Application;
	import app.events.Dispatcher;
	
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import lagden.ui.BtNav;
	
	import org.casalib.display.CasaSprite;
	import org.casalib.util.AlignUtil;
	import org.casalib.util.StageReference;
	
	public class Nav extends CasaSprite
	{
		protected var _app:Application;
		protected var _dispatcher:Dispatcher;
		
		private var _setinha:MovieClip;
		private var bt:Array;
		private var o:Array;
		
		public var st:Stage;
		
		public function Nav(dis:Dispatcher,arr:Array)
		{
			st = StageReference.getStage();
			
			this._app = Application.getInstance();
			this._dispatcher = dis;
			
			this._setinha = new setinha();
			this._setinha.visible = false;
			
			this.o = arr;
			
			this.addEventListener(Event.ADDED_TO_STAGE,begin);
		}
		
		private function begin(e:Event):void
		{			
			var padding:uint = 10;
			var cP:uint = 0;
			var c:uint = uint(cc);
			var cW:Number = 0;
			var cX:Number = 12;
			var cY:Number = 12;
			
			bt = [];
			
			for( var cc:String in o)
			{
				c = uint(cc);
				cP = (c != 0 ) ? padding : 0;
				bt[c] = new BtNav(_dispatcher,o[c]);
				if(bt[c-1] != undefined)
				{
					cW = bt[c-1].width;
					cX = bt[c-1].x;
				}
				bt[c].x = cW + cX + cP;
				bt[c].y = cY;
				this.addChild(bt[c]);
			}
			
			_dispatcher.addEventListener(_dispatcher.ON_SELECTED,vaiSetinha);
			
			this.addChild(this._setinha);
		}
		
		private function vaiSetinha(e:Event):void
		{
			var posX:Number = bt[_app['vars']['position']].x + (bt[_app['vars']['position']].width / 2) - 10;
			_setinha.visible = true;
			TweenMax.to(_setinha,.5,{x:posX});
		}
		
	}
}