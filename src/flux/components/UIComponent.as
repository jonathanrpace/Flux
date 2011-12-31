package flux.components 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flux.events.PropertyChangeEvent;
	
	[Event( type="flash.events.Event", name="resize" )]
	public class UIComponent extends Sprite implements IUIComponent
	{
		// Properties
		protected var _width			:Number = 0;
		protected var _height			:Number = 0;
		protected var _percentWidth		:Number;
		protected var _percentHeight	:Number;
		protected var _label			:String = "";
		protected var _icon				:Class;
		protected var _excludeFromLayout:Boolean = false;
		protected var _resizeToContent	:Boolean = false;
		protected var _enabled			:Boolean = true;
		protected var _isInvalid		:Boolean = false;
			
		public function UIComponent() 
		{
			_init();
		}
		
		private function _init():void
		{
			init();
			invalidate();
		}
		
		// Override this method to perform one-time init logic, such as creating children.
		protected function init():void {}
		
		override public function set width( value:Number ):void
		{
			value = Math.round(value < 0 ? 0 : value);
			if ( value == _width ) return;
			_width = value;
			invalidate();
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		override public function get width():Number
		{ 
			return _width; 
		}
		
		override public function set height( value:Number ):void
		{
			value = Math.round(value < 0 ? 0 : value);
			if ( value == _height ) return;
			_height = value;
			invalidate();
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		public function set percentWidth( value:Number ):void
		{
			if ( isNaN( value ) )
			{
				_percentWidth = NaN;
			}
			else
			{
				_percentWidth = value < 0 ? 0 : value;
			}
			invalidate();
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		public function get percentWidth():Number
		{ 
			return _percentWidth; 
		}
		
		public function set percentHeight( value:Number ):void
		{
			if ( isNaN( value ) )
			{
				_percentHeight = NaN;
			}
			else
			{
				_percentHeight = value < 0 ? 0 : value;
			}
			invalidate();
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		public function get percentHeight():Number
		{ 
			return _percentHeight; 
		}
		
		override public function set x(value:Number):void
		{
			value = Math.round(value);
			if ( value == x ) return;
			super.x = value;
		}
		
		override public function set y(value:Number):void
		{
			value = Math.round(value);
			if ( value == y ) return;
			super.y = value;
		}
		
		public function set label( value:String ):void
		{
			if ( _label == value ) return;
			var oldValue:String = _label;
			_label = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_label", oldValue, value ) );
		}
		
		public function get label():String
		{
			return _label;
		}
		
		public function set icon( value:Class ):void
		{
			if ( _icon == value ) return;
			var oldValue:Class = _icon;
			_icon = value;
			invalidate();
			dispatchEvent( new PropertyChangeEvent( "propertyChange_icon", oldValue, value ) );
		}
		
		public function get icon():Class
		{
			return _icon;
		}
		
		public function set enabled( value:Boolean ):void
		{
			if ( value == _enabled ) return;
			_enabled = value;
			mouseEnabled = value;
			mouseChildren = value;
			alpha = value ? 1 : 0.5;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set resizeToContent( value:Boolean ):void
		{
			if ( value == _resizeToContent ) return;
			_resizeToContent = value;
			invalidate();
		}
		
		public function get resizeToContent():Boolean
		{
			return _resizeToContent;
		}
		
		public function set excludeFromLayout( value:Boolean ):void
		{
			if ( value == _excludeFromLayout ) return;
			_excludeFromLayout = value;
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		public function get excludeFromLayout():Boolean
		{
			return _excludeFromLayout;
		}
		
		public function invalidate():void
		{
			if ( _isInvalid ) return;
			_isInvalid = true;
			addEventListener( Event.ENTER_FRAME, onInvalidateHandler );
		}
		
		public function isInvalid():Boolean
		{
			return _isInvalid;
		}
		
		private function onInvalidateHandler( event:Event ):void
		{
			validateNow();
		}
		
		public function validateNow():void
		{
			if ( _isInvalid == false ) return;
			validate();
			_isInvalid = false;
			removeEventListener( Event.ENTER_FRAME, onInvalidateHandler );
		}
		
		protected function validate():void {}
	}
}