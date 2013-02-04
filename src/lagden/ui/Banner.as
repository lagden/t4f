package lagden.ui
{
	import app.events.Application;
	import app.events.Dispatcher;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Expo;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import lagden.ui.BtNavNumber;
	import lagden.utils.TxtBox;
	
	import org.casalib.display.CasaBitmap;
	import org.casalib.display.CasaSprite;
	import org.casalib.util.AlignUtil;
	import org.casalib.util.NavigateUtil;
	import org.casalib.util.StageReference;
	
	public class Banner extends CasaSprite
	{
		protected var _app:Application;
		protected var _dispatcher:Dispatcher;
		
		private var _barraVerde:MovieClip;
		private var _txtGrande:TxtBox;
		private var _txtPequeno:TxtBox;
		private var _bmp:CasaSprite;
		private var _nav:CasaSprite;
		private var _overlay:CasaSprite;
		private var _obj:Array;
		
		public var _anima:Boolean;
		
		public var st:Stage;
		
		public function Banner(dis:Dispatcher,obj:Array)
		{
			st = StageReference.getStage();
			
			this._app = Application.getInstance();
			this._dispatcher = dis;
			
			this._obj = obj;
			this._anima = true;
			
			this.addEventListener(Event.ADDED_TO_STAGE,begin);
		}
		
		private function begin(e:Event):void
		{
			_bmp = new CasaSprite();
			_nav = new CasaSprite();
			
			_barraVerde = new barraVerde();
			_barraVerde.y = 220;
			
			_txtGrande = new TxtBox(String("Texto Grande").toUpperCase(),"left",_app['vars']['branco'],55,_app['vars']['font']);
			AlignUtil.alignMiddleLeft(_txtGrande,new Rectangle(20,220,_barraVerde.width,_barraVerde.height));
			
			_txtPequeno = new TxtBox("Texto Pequeno","left",_app['vars']['branco'],11,_app['vars']['fontArial']);
			_txtPequeno.multiline = true;
			_txtPequeno.wordWrap = true;
			AlignUtil.alignMiddleLeft(_txtPequeno,new Rectangle(0,220,_barraVerde.width,_barraVerde.height));
			
			// Overlay para disparar o click do link
			_overlay = new CasaSprite();
			_overlay.graphics.lineStyle(6,0xFFFFFF,1);
			_overlay.graphics.beginFill(0xFF9900,0);
			_overlay.graphics.drawRect(0,0,this._app['vars']['w'],this._app['vars']['h']);
			_overlay.graphics.endFill();
			_overlay.addEventListener(MouseEvent.CLICK,goURL);
			
			addChild(_bmp);
			addChild(_barraVerde);
			addChild(_txtGrande);
			addChild(_txtPequeno);			
			addChild(_overlay);
			addChild(_nav);
			
			var bt:Array = [];
			var c:uint = 0;
			var cW:Number = 0;
			var cX:Number = 12;
			
			// Cria navegação com números
			for(var cc:String in _obj)
			{
				c = uint(cc);
				bt[c] = new BtNavNumber(_dispatcher,{pos:c,txt:(c+1)});
				if(bt[c-1] != undefined)
				{
					cW = bt[c-1].width;
					cX = bt[c-1].x;
				}
				bt[c].x = cW + cX;
				bt[c].addEventListener(MouseEvent.CLICK,clica);
				_nav.addChild(bt[c]);
			}
			
			// Esconde a navegacao se tiver apenas 1 item
			if(_nav.numChildren == 1) _nav.visible = false;
			AlignUtil.alignTopRight(_nav,new Rectangle(0,180,st.stageWidth,st.stageHeight));
		}
		
		private function clica(e:MouseEvent):void{
			_app['vars']['interval'].reset();
			_app['vars']['interval'].start();
			this._anima = false;
			this.show(uint(e.currentTarget._pos));
		}
		
		// Troca os dados 
		public function show(pos:uint=0):void
		{
			_app['vars']['positionBanner'] = pos;
			_dispatcher.navSelectBanner();
			//
			if(_anima)
			{
				_txtGrande.alpha = 0;
				_txtPequeno.alpha = 0;
				_barraVerde.alpha = 0;
				_nav.alpha = 0;
				_barraVerde.x = _barraVerde.width * -1;
			}
			//
			_bmp.removeAllChildren(true,true);
			var currBmp:Bitmap = _obj[pos]["img"].contentAsBitmap;
			currBmp.width = this._app['vars']['w'];
			currBmp.height = this._app['vars']['h'];
			_bmp.addChild(currBmp);
			_txtGrande.htmlText = String(_obj[pos]["title"]).toUpperCase();
			
			
			_txtPequeno.htmlText = _obj[pos]["txt"];
			_txtPequeno.width = this._app['vars']['w'] - (_txtGrande.x + _txtGrande.width) - 20;
			AlignUtil.alignMiddleLeft(_txtPequeno,new Rectangle(0,220,_barraVerde.width,_barraVerde.height));
			_txtPequeno.x = _txtGrande.x + _txtGrande.width + 5;
			
		}
		
		// Abre o link
		private function goURL(e:MouseEvent):void
		{
			NavigateUtil.openUrl(_obj[_app['vars']['positionBanner']]["link"],NavigateUtil.WINDOW_SELF);
		}
		
		public function anima():void
		{	
			TweenMax.to(_barraVerde, .5,{x:0,alpha:1, ease:Cubic.easeInOut, onComplete:onFinishTween});
		}
		
		public function onFinishTween():void
		{
			TweenMax.to(_txtGrande, .5,{alpha:1, ease:Cubic.easeInOut});
			TweenMax.to(_txtPequeno, .5,{alpha:1, ease:Cubic.easeInOut});
			TweenMax.to(_nav, .5,{alpha:1, ease:Cubic.easeInOut});
		}
	}
}