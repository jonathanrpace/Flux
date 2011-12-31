package flux.layouts 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.geom.Rectangle;
	import flux.components.UIComponent;
	
	public class HorizontalLayout implements ILayout 
	{
		public var spacing		:int;
		public var align		:String;
		
		public function HorizontalLayout( spacing:int = 4, align:String = "none" ) 
		{
			this.spacing = spacing;
			this.align = align;
		}
		
		public function layout(content:DisplayObjectContainer, visibleWidth:Number, visibleHeight:Number, allowProportional:Boolean = true):Rectangle 
		{
			var pos:int = 0;
			var proportionalSlotSize:Number = 0;
			var contentSize:Rectangle = new Rectangle();
						
			if ( allowProportional )
			{
				// Sum up the total height of all children with explicit widths.
				// We can then share the remainder amongst children with percentWidth defined.
				var totalExplicitSize:int = 0;
				var numProportionalChildren:int = 0;
				for ( var i:int = 0; i < content.numChildren; i++ )
				{
					var child:UIComponent = UIComponent(content.getChildAt(i));
					if ( child.excludeFromLayout ) continue;
					
					if ( isNaN(child.percentWidth) )
					{
						child.validateNow();
						totalExplicitSize += child.width;
					}
					else
					{
						numProportionalChildren++;
					}
				}
				var proportionalSpaceRemaining:int = (visibleWidth-(spacing*(content.numChildren-1))) - totalExplicitSize;
				proportionalSlotSize = proportionalSpaceRemaining / numProportionalChildren;
			}
			
			// Because components have integer x/y width/height properties, we need to track how much of the real
			// fractional value we're losing along the way. We then append this to the next item to ensure 
			// proportional values sum up to the correct value.
			var errorAccumulator:Number = 0; 
			for ( i = 0; i < content.numChildren; i++ )
			{
				child = UIComponent(content.getChildAt(i));
				if ( child.excludeFromLayout ) continue;
				
				var isProportionalWidth:Boolean = allowProportional && isNaN( child.percentWidth ) == false;
				var isProportionalHeight:Boolean = allowProportional && isNaN( child.percentHeight ) == false;
				
				switch ( align )
				{
					case LayoutAlign.TOP :
						child.x = 0;
						if ( isProportionalHeight )
						{
							child.height = (visibleHeight - child.y) * child.percentHeight * 0.01;
						}
						break;
					case LayoutAlign.BOTTOM :
						if ( isProportionalHeight )
						{
							child.height = visibleHeight * child.percentHeight * 0.01;
						}
						child.x = visibleWidth - child.height;
						
						break;
					case LayoutAlign.CENTRE :
						if ( isProportionalHeight )
						{
							child.height = visibleHeight * child.percentHeight * 0.01;
						}
						child.x = (visibleWidth - child.height) * 0.5;
						break;
					default :
						if ( isProportionalHeight )
						{
							child.height = (visibleHeight - child.y) * child.percentHeight * 0.01;
						}
						break;
				}
				
				if ( isProportionalWidth )
				{
					var fractionalValue:Number = proportionalSlotSize * child.percentWidth * 0.01 + errorAccumulator;
					var roundedValue:int = Math.round( fractionalValue );
					child.width = roundedValue;
					errorAccumulator = fractionalValue-roundedValue;
				}
				
				child.x = pos;
				child.validateNow();
				pos += child.width + spacing;
				
				contentSize.width = child.x + child.width > contentSize.width ? child.x + child.width : contentSize.width;
				contentSize.height = child.y + child.height > contentSize.height ? child.x + child.height : contentSize.height;
			}
			
			return contentSize;
		}
	}
}