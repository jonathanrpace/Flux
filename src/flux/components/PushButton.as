package flux.components 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	import flux.skins.PushButtonSkin;
	
	public class PushButton extends UIComponent 
	{
		// Child elements
		protected var skin				:MovieClip;
		protected var iconContainer		:Sprite;
		protected var labelField		:TextField;
		
		// State
		protected var _over				:Boolean = false;
		protected var _down				:Boolean = false;
		protected var _selected			:Boolean = false;
		protected var _toggle			:Boolean = false;
		protected var iconIsInvalid		:Boolean = false;
		protected var skinClass			:Class;
		
		public function PushButton( skinClass:Class = null ) 
		{
			this.skinClass = skinClass;
			super();
		}
		
		override protected function init():void
		{
			skin = skinClass == null ? new PushButtonSkin() : new skinClass();
			_width = skin.width;
			_height = skin.height;
			skin.mouseEnabled = false;
			addChild( skin );
			
			labelField = new TextField();
			labelField.defaultTextFormat = new TextFormat( Style.fontFace, Style.fontSize, Style.fontColor );
			labelField.selectable = false;
			labelField.multiline = false;
			labelField.mouseEnabled = false;
			addChild( labelField );
			
			iconContainer = new Sprite();
			iconContainer.mouseEnabled = false;
			iconContainer.mouseChildren = false;
			addChild(iconContainer);
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		protected function removedFromStageHandler( event:Event ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_over = false;
			_down = false;
			_selected ? skin.gotoAndPlay( "SelectedUp" ) : skin.gotoAndPlay( "Up" );
		}
		
		override public function set label(str:String):void
		{
			_label = str;
			labelField.text = _label;
			if ( _resizeToContent )
			{
				invalidate();
			}
		}
		
		override public function set icon( value:Class ):void
		{
			if ( _icon == value ) return;
			_icon = value;
			iconIsInvalid = true;
			invalidate();
		}

		public function set selected(value:Boolean):void
		{
			if ( _selected == value ) return;
			_selected = value;
			_selected ? skin.gotoAndPlay( "SelectedUp" ) : skin.gotoAndPlay( "Up" );
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		public function get selected():Boolean
		{
			return _selected;
		}

		public function set toggle(value:Boolean):void
		{
			_toggle = value;
		}
		public function get toggle():Boolean
		{
			return _toggle;
		}
		
		override protected function validate():void
		{
			if ( iconIsInvalid )
			{
				if ( iconContainer.numChildren > 0 )
				{
					iconContainer.removeChildAt(0);
				}
				
				if ( _icon )
				{
					var iconInstance:* = new _icon();
					if ( iconInstance is DisplayObject )
					{
						iconContainer.addChild( DisplayObject(iconInstance) );
					}
					else if ( iconInstance is BitmapData )
					{
						iconContainer.addChild( new Bitmap(BitmapData(iconInstance)) );
					}
				}
				
				iconIsInvalid = false;
			}
			
			iconContainer.x = 2;
			iconContainer.y = (_height - iconContainer.height) >> 1;
			
			labelField.x = iconContainer.x + iconContainer.width + 4;
			labelField.height = Math.min(labelField.textHeight + 4, _height);
			labelField.y = (_height - (labelField.height)) >> 1;
			
			var tf:TextFormat = labelField.defaultTextFormat;
			if ( _resizeToContent )
			{
				tf.align = TextFormatAlign.LEFT;
				labelField.autoSize = TextFieldAutoSize.LEFT;
				labelField.defaultTextFormat = tf;
				_width = labelField.x + labelField.width + 4;
			}
			else
			{
				tf.align = TextFormatAlign.CENTER;
				labelField.autoSize = TextFieldAutoSize.NONE;
				labelField.defaultTextFormat = tf;
				labelField.width = _width - labelField.x;
			}
			
			skin.width = _width;
			skin.height = _height;
		}
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			_over = true;
			
			_selected ? 
			(_down ? skin.gotoAndPlay( "SelectedDown" ) 	: skin.gotoAndPlay("SelectedOver")) : 
			(_down ? skin.gotoAndPlay( "Down" ) 			: skin.gotoAndPlay("Over"))
				
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		protected function rollOutHandler(event:MouseEvent):void
		{
			_over = false;
			_selected ? skin.gotoAndPlay( "SelectedOut" ) : skin.gotoAndPlay( "Out" );
			removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		protected function mouseDownHandler(event:MouseEvent):void
		{
			_down = true;
			_selected ? skin.gotoAndPlay( "SelectedDown" ) : skin.gotoAndPlay( "Down" );
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}

		protected function mouseUpHandler(event:MouseEvent):void
		{
			if(_toggle && over)
			{
				_selected = !_selected;
			}
			_down = false;
			
			_selected ? 
			(_over ? skin.gotoAndPlay( "SelectedOver" ) 	: skin.gotoAndPlay("SelectedUp")) : 
			(_over ? skin.gotoAndPlay( "Over" ) 			: skin.gotoAndPlay("Up"))
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		public function get over():Boolean { return _over; }
		public function get down():Boolean { return _down; }
	}
}