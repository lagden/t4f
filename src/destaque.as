package
{
	import app.events.Application;
	import app.events.Dispatcher;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Expo;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.system.Security;
	import flash.system.System;
	
	import lagden.ui.Banner;
	import lagden.ui.Nav;
	import lagden.utils.TxtBox;
	
	import org.casalib.display.CasaMovieClip;
	import org.casalib.display.CasaSprite;
	import org.casalib.events.LoadEvent;
	import org.casalib.load.DataLoad;
	import org.casalib.load.GroupLoad;
	import org.casalib.load.ImageLoad;
	import org.casalib.load.SwfLoad;
	import org.casalib.time.Interval;
	import org.casalib.util.AlignUtil;
	import org.casalib.util.FlashVarUtil;
	import org.casalib.util.StageReference;
	
	[SWF(width="650", height="350", backgroundColor="#000000", frameRate="31")]
	
	public class destaque extends CasaSprite
	{
		protected var _app:Application;
		protected var _dispatcher:Dispatcher;
		
		protected var _swfLoad:MovieClip;
		protected var _txtLoad:TxtBox;
		protected var _interval:Interval;
		protected var _dataLoad:DataLoad;
		protected var _groupLoadXML:GroupLoad;
		protected var _groupLoad:GroupLoad;
		protected var _xmlMain:String;
		protected var _XMLs:Array;
		protected var _valores:Array;
		
		private var masterContent:CasaSprite;
		private var navegacao:Nav;
		
		private var banners:Array;
		
		public function destaque()
		{
			// Adicionar asset do Carrgando...
			
			super();
			
			Security.allowDomain('*');
			
			StageReference.setStage(this.stage);
			this.stage.scaleMode=StageScaleMode.NO_SCALE;
			this.stage.align=StageAlign.TOP_LEFT;
			
			this._app = Application.getInstance();
			this._dispatcher = new Dispatcher();
			
			this._app['vars']={};
			this._app['vars']['w'] = 650;
			this._app['vars']['h'] = 350;
			this._app['vars']['branco'] = '0xFFFFFF';
			this._app['vars']['verde'] = '0x0f8d8a';
			this._app['vars']['fontSize'] = 15;
			this._app['vars']['font'] = new Futura();
			this._app['vars']['fontArial'] = new Arial();
			this._app['vars']['old']=null;
			this._app['vars']['position']=0;
			this._app['vars']['positionBanner']=0;
			this._app['vars']['clica']=true;
			
			trace('ulalalaaaaa')
			
			// Master
			masterContent = new CasaSprite();
			masterContent.graphics.lineStyle(6,0xFFFFFF,1);
			masterContent.graphics.beginFill(0x000000,.3);
			masterContent.graphics.drawRect(0,0,this._app['vars']['w'],this._app['vars']['h']);
			masterContent.graphics.endFill();
			this.addChild(masterContent);
			
			// XML
			_xmlMain = FlashVarUtil.getValue('xmlFilePath');
			_xmlMain = _xmlMain || "xml/destaques.xml";
			
			_swfLoad = new logoT4F();
			_swfLoad.alpha = 0;
			AlignUtil.alignMiddleCenter(_swfLoad,new Rectangle(0,0,_app['vars']['w'],_app['vars']['h']));
			
			_txtLoad = new TxtBox("Carregando...","left",_app['vars']['branco'],11,_app['vars']['fontArial']);
			_txtLoad.alpha = 0;
			AlignUtil.alignCenter(_txtLoad,new Rectangle(0,0,_app['vars']['w'],_app['vars']['h']));
			_txtLoad.y = _swfLoad.y + _swfLoad.height + 5; 
			
			
			addChild(_swfLoad);
			addChild(_txtLoad);
			TweenMax.to(_swfLoad, 1,{alpha:1, ease:Cubic.easeInOut});
			TweenMax.to(_txtLoad, 1,{alpha:1, ease:Cubic.easeInOut});
			
			this.carregaXML();
		}
		
		private function carregaXML():void
		{
			_dataLoad = new DataLoad(_xmlMain);
			_dataLoad.addEventListener(IOErrorEvent.IO_ERROR, this._onXMLMainError);
			_dataLoad.addEventListener(LoadEvent.COMPLETE, _onXMLMainComplete);
			_dataLoad.start();
		}
		
		protected function _onXMLMainError(e:IOErrorEvent):void {
			trace("There was an error - Main XML");
		}
		
		protected function _onXMLMainComplete(e:LoadEvent):void
		{
			var r:XMLList = _dataLoad.dataAsXml.item;
			var i:XML;
			var cc:uint = 0;
			_XMLs = [];
			
			this._groupLoadXML = new GroupLoad();
			
			for each(i in r)
			{
				_XMLs[cc] = new DataLoad(i.toString());
				this._groupLoadXML.addLoad(_XMLs[cc]);
				cc++;
			}
			
			_dataLoad.destroy();
			
			this._groupLoadXML.addEventListener(IOErrorEvent.IO_ERROR, this._onGroupXMLError);
			this._groupLoadXML.addEventListener(LoadEvent.PROGRESS, this._onGroupXMLProgress);
			this._groupLoadXML.addEventListener(LoadEvent.COMPLETE, this._onGroupXMLComplete);
			this._groupLoadXML.start();
		}
		
		protected function _onGroupXMLError(e:IOErrorEvent):void {
			trace("There was an error - Group XML");
			this._groupLoad.removeLoad(this._groupLoad.erroredLoads[0]);
		}
		
		protected function _onGroupXMLProgress(e:LoadEvent):void {
			trace("Group is " + e.progress.percentage + "% loaded at " + e.Bps + "Bps.");
			
			_txtLoad.htmlText = "Carregando dados... " + uint(e.progress.percentage);
			AlignUtil.alignCenter(_txtLoad,new Rectangle(0,0,_app['vars']['w'],_app['vars']['h']));
		}
		
		protected function _onGroupXMLComplete(e:LoadEvent):void {
			trace("Group has loaded.");
			
			this._groupLoadXML.destroyLoads(true);
			this._groupLoadXML.destroy();
			
			// Grupo load para as imagens
			_groupLoad = new GroupLoad();
			
			_valores=[];
			
			for each(var d:DataLoad in _XMLs)
			{
				var r:XMLList = d.dataAsXml.channel;
				var i:XML;
				var c:XML;
				
				for each(i in r)
				{
					var o:Object={};
					o["categoria"] = i.title.toString();
					o["itens"] = [];
					for each(c in i.item)
					{
						// Parse na Descrição
						var regexImg:RegExp = /<img.*?src\s*=\s*("|')(?P<source>.*?)\1.*?>/gism;
						var regexP:RegExp = /<p>(.*?)<\/p>/gism;
						var regexLnk:RegExp = /(?<=href\=")[^]+?(?=")/gism;
						var oo:Object={};
						oo["title"] = c.title.toString();
						
						oo["regexImg"] = regexImg.exec(c.description.toString());
						oo["regexP"] = regexP.exec(c.description.toString());
						oo["regexLnk"] = regexLnk.exec(c.description.toString());
						
						if(oo["regexImg"] != null){
							oo["img"] = new ImageLoad(oo["regexImg"][oo["regexImg"].length - 1]);
							_groupLoad.addLoad(oo["img"]);
						}
						else oo["img"] = null;
						// P
						if(oo["regexP"] != null) oo["txt"] = oo["regexP"][1];
						else oo["txt"] = null;
						
						// Link
						if(oo["regexLnk"] != null) oo["link"] = oo["regexLnk"][0];
						else  oo["link"] = "#";
						
						// Se não achar imagem ele não entra...
						if(oo["img"] != null) o["itens"].push(oo);
					}
					_valores.push(o);
				}
			}
			this.groupLoadImages();
		}
		
		protected function groupLoadImages():void
		{
			_groupLoad.addEventListener(IOErrorEvent.IO_ERROR, this._onError);
			_groupLoad.addEventListener(LoadEvent.PROGRESS, this._onProgress);
			_groupLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
			_groupLoad.start();
		}
		
		protected function _onError(e:IOErrorEvent):void
		{
			trace("There was an error - Group Images");
			this._groupLoad.removeLoad(this._groupLoad.erroredLoads[0]);
		}
		
		protected function _onProgress(e:LoadEvent):void
		{
			trace("Group is " + e.progress.percentage + "% loaded at " + e.Bps + "Bps.");
			_txtLoad.htmlText = "Carregando imagens... " + uint(e.progress.percentage);
			AlignUtil.alignCenter(_txtLoad,new Rectangle(0,0,_app['vars']['w'],_app['vars']['h']));
		}
		
		protected function _onComplete(e:LoadEvent):void
		{
			trace("Group has loaded.");
			this._groupLoad.destroyLoads(true);
			this._groupLoad.destroy();
			
			TweenMax.to(_swfLoad, 1,{alpha:0, ease:Cubic.easeInOut,onComplete:function():void{_swfLoad.visible=false;}});
			TweenMax.to(_txtLoad, 1,{alpha:0, ease:Cubic.easeInOut,onComplete:function():void{_txtLoad.visible=false;}});
			
			// Aqui começa a brincadeira
			this.doSome();
		}
		
		private function doSome():void{
			banners = [];
			var navegacaoCategoria:Array = [];
			var c:uint;
			var nc:uint = 0;
			for( var cc:String in _valores)
			{
				c = uint(cc);
				
				if(_valores[c]["itens"].length > 0)
				{
					// Categorias 
					navegacaoCategoria.push({pos:nc,txt:_valores[c]["categoria"]});
					// Banner das categorias
					banners[nc] = new Banner(_dispatcher,_valores[c]["itens"]);
					banners[nc].visible = false;
					masterContent.addChild(banners[nc]);
					nc++;
				}
			}
			
			// Navegacao entre as categorias
			navegacao = new Nav(_dispatcher,navegacaoCategoria);
			masterContent.addChild(navegacao);
			
			// Tempo de troca entre as categorias em segundos
			this._app['vars']['tempoTroca'] = 5;
			this._app['vars']['interval'] = Interval.setInterval(repeating, _app['vars']['tempoTroca'] * 1000);
			this._app['vars']['interval'].start();
			
			_dispatcher.addEventListener(_dispatcher.ON_SWAP_BANNER,this.onSwapBanner);
			_dispatcher.navSelect();
			_dispatcher.swapBanner();
		}
		
		protected function repeating():void
		{
			_app['vars']['old'] = _app['vars']['position'];
			if(_app['vars']['position']==(banners.length -1))
			{
				_app['vars']['position']=0;
			}
			else
			{
				_app['vars']['position'] = _app['vars']['position'] + 1;
			}
			_dispatcher.navSelect();
			_dispatcher.swapBanner();
		}
		
		protected function onSwapBanner(e:Event):void
		{
			_app['vars']['clica']=false;
			banners[_app['vars']['position']].show(0);
			banners[_app['vars']['position']].visible=true;
			banners[_app['vars']['position']].alpha=0;
			
			if(_app['vars']['old'] != null)
			{
				if(masterContent.getChildIndex(banners[_app['vars']['old']]) > masterContent.getChildIndex(banners[_app['vars']['position']]))
				{
					masterContent.swapChildren(banners[_app['vars']['old']],banners[_app['vars']['position']]);
				}
			}
			TweenMax.to(banners[_app['vars']['position']], 1,{alpha:1, ease:Cubic.easeInOut, onComplete:onFinishTween});
		}
		
		public function onFinishTween():void
		{
			banners[_app['vars']['position']]._anima = true;
			banners[_app['vars']['position']].anima();
			
			if(_app['vars']['old'] != null)
			{
				banners[_app['vars']['old']].visible=false;
				banners[_app['vars']['old']].alpha=0;
			}
			_app['vars']['old'] = _app['vars']['position'];
			_app['vars']['clica']=true;
		}
	}
}