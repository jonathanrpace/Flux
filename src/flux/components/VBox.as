package flux.components 
{
	import flux.layouts.VerticalLayout;
	public class VBox extends Canvas 
	{
		
		public function VBox() 
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			_layout = new VerticalLayout();
		}
		
		public function set spacing( value:int ):void
		{
			VerticalLayout(_layout).spacing = value;
		}
		
		public function get spacing():int
		{
			return VerticalLayout(_layout).spacing;
		}
		
		public function set align( value:String ):void
		{
			VerticalLayout(_layout).align = value;
		}
		
		public function get align():String
		{
			return VerticalLayout(_layout).align;
		}
	}

}