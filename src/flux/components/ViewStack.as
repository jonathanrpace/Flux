package flux.components 
{
	import flash.display.DisplayObject;
	public class ViewStack extends Canvas 
	{
		protected var _visibleIndex		:int = -1;
		
		public function ViewStack() 
		{
			
		}
		
		public function set visibleIndex( value:int ):void
		{
			if ( value < -1 || value >= content.numChildren )
			{
				throw( new Error( "Index out of bounds" ) );
				return;
			}
			
			if ( _visibleIndex == value ) return;
			_visibleIndex = value
			invalidate();
		}
		
		override protected function onChildrenChanged( child:UIComponent, index:int, added:Boolean ):void
		{
			if ( added && content.numChildren == 1 && _visibleIndex == -1 )
			{
				visibleIndex = 0;
			}
			else if ( _visibleIndex >= index )
			{
				added ? visibleIndex++ : visibleIndex--;
			}
		}
		
		public function get visibleIndex():int
		{
			return _visibleIndex;
		}
		
		override protected function validate():void
		{
			for ( var i:int = 0; i < content.numChildren; i++ )
			{
				var child:UIComponent = UIComponent(content.getChildAt(i));
				child.visible = i == _visibleIndex;
				child.excludeFromLayout = !child.visible;
			}
			
			super.validate();
		}
	}
}