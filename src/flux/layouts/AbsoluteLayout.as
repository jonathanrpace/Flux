package flux.layouts 
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flux.components.UIComponent;
	
	public class AbsoluteLayout implements ILayout 
	{
		public function AbsoluteLayout() 
		{
			
		}
		
		public function layout( content:DisplayObjectContainer, visibleWidth:Number, visibleHeight:Number, allowProportional:Boolean = true ):Rectangle
		{
			var contentSize:Rectangle = new Rectangle();
			
			for ( var i:int = 0; i < content.numChildren; i++ )
			{
				var child:UIComponent = UIComponent(content.getChildAt(i));
				
				if ( child.excludeFromLayout ) continue;
				
				if ( allowProportional )
				{
					if ( isNaN(child.percentWidth) == false )
					{
						child.width = visibleWidth - child.x;
					}
					
					if ( isNaN(child.percentHeight) == false )
					{
						child.height = visibleHeight - child.y;
					}
				}
				
				child.validateNow();
				
				contentSize.width = child.x + child.width > contentSize.width ? child.x + child.width : contentSize.width;
				contentSize.height = child.y + child.height > contentSize.height ? child.x + child.height : contentSize.height;
			}
			
			return contentSize;
		}
	}

}