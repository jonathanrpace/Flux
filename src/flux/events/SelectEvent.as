package flux.events 
{
	import flash.events.Event;
	
	public class SelectEvent extends Event 
	{
		public static var SELECT		:String = "select";
		
		private var _selectedItem		:Object;
		
		public function SelectEvent( type:String, selectedItem:Object, bubbles:Boolean = false, cancelable:Boolean = false ):void
		{
			super( type, bubbles, cancelable );
			_selectedItem = selectedItem;
		}
		
		public function get selectedItem():Object
		{
			return _selectedItem;
		}
		
	}

}