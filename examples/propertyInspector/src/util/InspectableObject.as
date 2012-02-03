package util
{
	import flash.events.EventDispatcher;
	import flux.events.PropertyChangeEvent;
	public class InspectableObject extends EventDispatcher
	{
		
		private var _string		:String = "I'm a string!";
		private var _integer	:int;
		private var _number		:Number;
		private var _number2	:Number;
		private var _number3	:Number;
		private var _color		:uint;
		private var _boolean	:Boolean;
		
		public function InspectableObject()
		{
			
		}
		
		[Inspectable]
		public function get string():String
		{
			return _string;
		}
		
		public function set string(value:String):void
		{
			var oldValue:* = _string;
			_string = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_string", oldValue, _string ) );
		}
		
		[Inspectable( editor="NumericStepper" )]
		public function get integer():int
		{
			return _integer;
		}
		
		public function set integer(value:int):void
		{
			var oldValue:* = _integer;
			_integer = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_integer", oldValue, _integer ) );
		}
		
		[Inspectable]
		public function get number():Number
		{
			return _number;
		}
		
		public function set number(value:Number):void
		{
			var oldValue:* = _number;
			_number = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_number", oldValue, _number ) );
		}
		
		[Inspectable] [Inspectable( editor="Slider", min="-10", max="10", snapInterval="1" )]
		public function get number2():Number
		{
			return _number2;
		}
		
		public function set number2(value:Number):void
		{
			var oldValue:* = _number2;
			_number2 = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_number2", oldValue, _number2 ) );
		}
		
		[Inspectable( editor="Slider", min="-10", max="10", snapInterval="1" )]
		public function get number3():Number
		{
			return _number3;
		}
		
		public function set number3(value:Number):void
		{
			var oldValue:* = _number3;
			_number3 = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_number3", oldValue, _number3 ) );
		}
		
		[Inspectable]
		public function get boolean():Boolean
		{
			return _boolean;
		}
		
		public function set boolean(value:Boolean):void
		{
			var oldValue:* = _boolean;
			_boolean = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_boolean", oldValue, _boolean ) );
		}
		
		[Inspectable( editor="ColorPicker" )]
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			_color = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_color", null, _color ) );
		}
	}
}