package flux.components 
{
	import flux.layouts.HorizontalLayout;
	
	public class HBox extends Canvas 
	{
		
		public function HBox() 
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			_layout = new HorizontalLayout();
		}
		
		public function set spacing( value:int ):void
		{
			HorizontalLayout(_layout).spacing = value;
		}
		
		public function get spacing():int
		{
			return HorizontalLayout(_layout).spacing;
		}
		
		public function set align( value:String ):void
		{
			HorizontalLayout(_layout).align = value;
		}
		
		public function get align():String
		{
			return HorizontalLayout(_layout).align;
		}
	}

}