/**
 * VerticalLayout.as
 * 
 * Copyright (c) 2011 Jonathan Pace
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package flux.layouts 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.geom.Rectangle;
	
	import flux.components.UIComponent;
	
	public class VerticalLayout implements ILayout 
	{
		public var spacing				:int;
		public var verticalAlign		:String;
		public var horizontalAlign		:String;
		
		public function VerticalLayout( spacing:int = 0, verticalAlign:String = "none", horizontalAlign:String = "none" ) 
		{
			this.spacing = spacing;
			this.verticalAlign = verticalAlign;
			this.horizontalAlign = horizontalAlign;
		}
		
		public function layout(content:DisplayObjectContainer, visibleWidth:Number, visibleHeight:Number, allowProportional:Boolean = true):Rectangle 
		{
			var pos:int = 0;
			var proportionalSlotSize:Number = 0;
			var contentSize:Rectangle = new Rectangle();
			
			if ( allowProportional )
			{
				// Sum up the total height of all children with explicit heights.
				// We can then share the remainder amongst children with percentHeight defined.
				var totalExplicitSize:int = 0;
				var numProportionalChildren:int = 0;
				for ( var i:int = 0; i < content.numChildren; i++ )
				{
					var child:DisplayObject = content.getChildAt(i);
					var component:UIComponent = child as UIComponent;
					if ( component )
					{
						if ( component.excludeFromLayout ) continue;
						if ( isNaN(component.percentHeight) )
						{
							component.validateNow();
							totalExplicitSize += child.height;
						}
						else
						{
							numProportionalChildren++;
						}
					}
					
				}
				var proportionalSpaceRemaining:int = (visibleHeight-(spacing*(content.numChildren-1))) - totalExplicitSize;
				proportionalSlotSize = proportionalSpaceRemaining / numProportionalChildren;
			}
			
			// Because components have integer x/y width/height properties, we need to track how much of the real
			// fractional value we're losing along the way. We then append this to the next item to ensure 
			// proportional values sum up to the correct value.
			var errorAccumulator:Number = 0; 
			for ( i = 0; i < content.numChildren; i++ )
			{
				child = content.getChildAt(i);
				component = child as UIComponent;
				
				var isProportionalWidth:Boolean = false;
				var isProportionalHeight:Boolean = false;
				if ( component )
				{
					if ( component.excludeFromLayout ) continue;
					isProportionalWidth = allowProportional && isNaN( component.percentWidth ) == false;
					isProportionalHeight = allowProportional && isNaN( component.percentHeight ) == false;
				}
				
				switch ( horizontalAlign )
				{
					case LayoutAlign.LEFT :
						child.x = 0;
						if ( isProportionalWidth )
						{
							child.width = (visibleWidth - child.x) * component.percentWidth * 0.01;
						}
						break;
					case LayoutAlign.RIGHT :
						if ( isProportionalWidth )
						{
							child.width = visibleWidth * component.percentWidth * 0.01;
						}
						child.x = visibleWidth - child.width;
						
						break;
					case LayoutAlign.CENTRE :
						if ( isProportionalWidth )
						{
							child.width = visibleWidth * component.percentWidth * 0.01;
						}
						child.x = (visibleWidth - child.width) * 0.5;
						break;
					default :
						if ( isProportionalWidth )
						{
							child.width = (visibleWidth - child.x) * component.percentWidth * 0.01;
						}
						break;
				}
				
				if ( isProportionalHeight )
				{
					var fractionalValue:Number = proportionalSlotSize * component.percentHeight * 0.01 + errorAccumulator;
					var roundedValue:int = Math.round( fractionalValue );
					child.height = roundedValue;
					errorAccumulator = fractionalValue-roundedValue;
				}
				
				child.y = pos;
				if ( component )
				{
					component.validateNow();
				}
				pos += child.height + spacing;
				
				contentSize.width = child.x + child.width > contentSize.width ? child.x + child.width : contentSize.width;
				contentSize.height = child.y + child.height > contentSize.height ? child.y + child.height : contentSize.height;
			}
			
			if ( verticalAlign != LayoutAlign.NONE )
			{
				var shift:int = 0;
				switch ( verticalAlign )
				{
					case LayoutAlign.BOTTOM :
						shift = visibleHeight - contentSize.height;
						break
					case LayoutAlign.CENTRE :
						shift = (visibleHeight - contentSize.width) >> 1;
						break;
				}
				for ( i = 0; i < content.numChildren; i++ )
				{
					child = content.getChildAt(i);
					child.y += shift;
				}
			}
			
			return contentSize;
		}
	}
}