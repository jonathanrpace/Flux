/**
 * Panel.as
 * 
 * Container component with a title bar and control bar.
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
	import flash.events.Event;
	import flash.events.MouseEvent;
	public class CollapsiblePanel extends Panel 
	{
		// Properties
		private var _collapsed			:Boolean = false;
		
		// Internal vars
		private var openedHeight		:int = 0;
		
		
		public function CollapsiblePanel() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			super.init();
			openedHeight = _height;
			addEventListener(MouseEvent.CLICK, mouseClickHandler);
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function mouseClickHandler( event:MouseEvent ):void
		{
			if ( mouseY < _titleBarHeight )
			{
				collapsed = !_collapsed;
			}
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set collapsed( value:Boolean ):void
		{
			if ( value == _collapsed ) return;
			_collapsed = value;
			_height = _collapsed ? _titleBarHeight : openedHeight;
			dispatchEvent( new Event( Event.RESIZE, true ) );
			invalidate();
		}
		
		public function get collapsed():Boolean
		{
			return _collapsed;
		}
		
		override public function set height( value:Number ):void
		{
			super.height = value;
			openedHeight = value;
			_collapsed = false;
		}
	}
}