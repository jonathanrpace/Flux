package flux.events 
{
	import flash.events.Event;
	
	public class ArrayCollectionEvent extends Event 
	{
		public static var CHANGE		:String = "change";
		
		private var _changeKind	:int;
		private var _index		:int;
		private var _item		:*;
		
		public function ArrayCollectionEvent( type:String, changeKind:int, index:int = 0, item:* = null ) 
		{
			super(type, false, false);
			_changeKind = changeKind;
			_index = index;
			_item = item;
		}
		
		public function get changeKind():int
		{
			return _changeKind;
		}
		
		public function get index():int
		{
			return _index;
		}
		
		public function get item():*
		{
			return _item;
		}
	}
}