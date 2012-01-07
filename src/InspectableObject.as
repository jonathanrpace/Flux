package  
{
	import flash.events.EventDispatcher;
	import flux.events.PropertyChangeEvent;
	public class InspectableObject extends EventDispatcher
	{
		
		private var _string		:String = "I'm a string!";
		private var _integer	:int;
		private var _number		:Number;
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
		
		[Inspectable]
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
	}
}