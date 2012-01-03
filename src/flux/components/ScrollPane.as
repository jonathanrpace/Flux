/**
 * ScrollPane.as
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
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class ScrollPane extends Container 
	{
		// Properties
		protected var _autoHideVScrollBar	:Boolean = true;
		protected var _autoHideHScrollBar	:Boolean = true;
		
		// Child elements
		protected var vScrollBar		:ScrollBar;
		protected var hScrollBar		:ScrollBar;
		
		public function ScrollPane() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			super.init();
			
			vScrollBar = new ScrollBar();
			vScrollBar.scrollSpeed = 2;
			vScrollBar.pageScrollSpeed = 10;
			addRawChild(vScrollBar);
			
			hScrollBar = new ScrollBar();
			hScrollBar.rotation = -90;
			hScrollBar.scrollSpeed = 2;
			hScrollBar.pageScrollSpeed = 10;
			addRawChild(hScrollBar);
		}
		
		override protected function validate():void
		{
			var layoutArea:Rectangle = getChildrenLayoutArea();
			
			var extraPaddingForVScrollBar:Number = _autoHideVScrollBar ? 0 : vScrollBar.width - _paddingRight;
			var extraPaddingForHScrollBar:Number = _autoHideHScrollBar ? 0 : hScrollBar.width - _paddingBottom;
			layoutArea.width -= extraPaddingForVScrollBar;
			layoutArea.height -= extraPaddingForHScrollBar;
			
			var contentSize:Rectangle = _layout.layout( content, layoutArea.width, layoutArea.height );
			var needReLayout:Boolean = false;
			
			var requiresHScrollBar:Boolean = contentSize.width > layoutArea.width;
			if ( requiresHScrollBar && _autoHideHScrollBar )
			{
				layoutArea.height -= hScrollBar.width - _paddingBottom;
				contentSize = _layout.layout( content, layoutArea.width, layoutArea.height );
			}
			
			var requiresVScrollBar:Boolean = contentSize.height > layoutArea.height;
			if ( requiresVScrollBar && _autoHideVScrollBar )
			{
				layoutArea.width -= vScrollBar.width - _paddingRight;
				contentSize = _layout.layout( content, layoutArea.width, layoutArea.height );
			}
			
			requiresHScrollBar = contentSize.width > layoutArea.width;
			requiresVScrollBar = contentSize.height > layoutArea.height;
			
			vScrollBar.visible = _autoHideVScrollBar == false || requiresVScrollBar;
			hScrollBar.visible = _autoHideHScrollBar == false || requiresHScrollBar;
			
			vScrollBar.removeEventListener( Event.CHANGE, onChangeVScrollBar );
			vScrollBar.x = _width - vScrollBar.width;
			vScrollBar.height = _height;
			vScrollBar.max = contentSize.height - layoutArea.height;
			vScrollBar.thumbSizeRatio = (layoutArea.height / contentSize.height);
			vScrollBar.validateNow();
			vScrollBar.addEventListener( Event.CHANGE, onChangeVScrollBar );
			
			hScrollBar.removeEventListener( Event.CHANGE, onChangeHScrollBar );
			hScrollBar.y = _height;
			hScrollBar.height = _width;
			hScrollBar.max = Math.max(0, contentSize.width - layoutArea.width);
			hScrollBar.thumbSizeRatio = (layoutArea.width / contentSize.width);
			hScrollBar.validateNow();
			hScrollBar.addEventListener( Event.CHANGE, onChangeHScrollBar );
			
			content.x = layoutArea.x;
			content.y = layoutArea.y;
			
			var scrollRect:Rectangle = content.scrollRect;
			scrollRect.width = layoutArea.width;
			scrollRect.height = layoutArea.height;
			scrollRect.x = hScrollBar.value
			scrollRect.y = vScrollBar.value
			content.scrollRect = scrollRect;
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function onChangeVScrollBar( event:Event ):void
		{
			invalidate();
		}
		
		private function onChangeHScrollBar( event:Event ):void
		{
			invalidate();
		}
		
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function get maxScrollX():int
		{ 
			return hScrollBar.max; 
		}
		
		public function get maxScrollY():int 
		{ 
			return vScrollBar.max;
		}
		
		public function set scrollX( value:int ):void
		{
			hScrollBar.value = value;
		}
		
		public function get scrollX():int
		{ 
			return hScrollBar.value;
		}
		
		public function set scrollY( value:int ):void
		{
			vScrollBar.value = value;
		}
		
		public function get scrollY():int
		{ 
			return vScrollBar.value;
		}
	}
}