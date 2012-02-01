/**
 * VDividedBox.as
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

package flux.components
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flux.cursors.VerticalResizeCursor;
	import flux.layouts.VerticalLayout;
	import flux.managers.CursorManager;
	import flux.skins.HDividerThumbSkin;
	public class VDividedBox extends VBox
	{
		// Child elements
		private var dividers	:Sprite;
		
		// Internal vars
		private var mouseDownPos		:int;
		private var storedChildSize		:int;
		private var storedPercentSize	:int;
		private var draggedChild		:DisplayObject;
		private var isProportionalDrag	:Boolean;
		private var _over				:Boolean = false;
		
		public function VDividedBox()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			VerticalLayout(_layout).spacing = 10;
			
			dividers = new Sprite();
			addRawChild(dividers);
			
			dividers.addEventListener(MouseEvent.ROLL_OVER, rollOverDividersHandler);
			dividers.addEventListener(MouseEvent.ROLL_OUT, rollOutDividersHandler);
			dividers.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownDividersHandler);
		}
		
		override protected function validate():void
		{
			super.validate();
			
			dividers.x = content.x;
			dividers.y = content.y;
			
			for ( var i:int = 0; i < numChildren; i++ )
			{
				var child:DisplayObject = getChildAt(i);
				
				var divider:Sprite;
				var thumb:Sprite;
				if ( i >= dividers.numChildren )
				{
					divider = Sprite(dividers.addChild(new Sprite()));
					thumb = new HDividerThumbSkin();
					thumb.mouseEnabled = false;
					divider.addChild(thumb);
					
				}
				else
				{
					divider = Sprite(dividers.getChildAt(i));
					thumb = Sprite( divider.getChildAt(0) );
				}
				
				var dividerHeight:int = VerticalLayout(_layout).spacing;
				divider.y = child.y + child.height;
				divider.graphics.clear();
				divider.graphics.beginFill(0xFF0000,0);
				divider.graphics.drawRect(0, 0, _width, dividerHeight);
				
				thumb.x = (_width - thumb.width) >> 1;
				thumb.y = (dividerHeight - thumb.height) >> 1;
			}
			
			while ( dividers.numChildren > numChildren )
			{
				dividers.removeChildAt(dividers.numChildren - 1);
			}
			
			_height += numChildren > 0 ? VerticalLayout(_layout).spacing : 0;
		}
		
		private function rollOverDividersHandler( event:MouseEvent ):void
		{
			_over = true;
			CursorManager.setCursor( VerticalResizeCursor );
		}
		
		private function rollOutDividersHandler( event:MouseEvent ):void
		{
			_over = false;
			if ( draggedChild == null )
			{
				draggedChild = null;
				CursorManager.setCursor( null );
			}
		}
		
		private function mouseDownDividersHandler( event:MouseEvent ):void
		{
			var draggedDividerIndex:int = dividers.getChildIndex(Sprite(event.target));
			draggedChild = getChildAt(draggedDividerIndex);
			if ( draggedChild is UIComponent && isNaN(UIComponent(draggedChild).percentHeight) == false)
			{
				isProportionalDrag = true;
				storedPercentSize = UIComponent(draggedChild).percentHeight;
			}
			else
			{
				isProportionalDrag = false;
			}
			storedChildSize = draggedChild.height;
			mouseDownPos = stage.mouseY;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
		}
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			var delta:Number = (stage.mouseY - mouseDownPos);
			if ( isProportionalDrag )
			{
				var newHeight:Number = storedChildSize + delta;
				var ratio:Number = newHeight / storedChildSize;
				UIComponent(draggedChild).percentHeight = storedPercentSize * ratio;
			}
			else
			{
				draggedChild.height = storedChildSize + delta;
			}
			invalidate();
			validateNow();
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		private function mouseUpStageHandler( event:MouseEvent ):void
		{
			if ( !_over )
			{
				CursorManager.setCursor( null );
			}
			draggedChild = null;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
		}
	}
}