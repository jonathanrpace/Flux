/**
 * ViewStack.as
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
	
	import flux.events.IndexChangeEvent;
	
	[Event( type="flash.events.Event", name="change" )]
	[Event( type="flux.events.IndexChangeEvent", name="indexChange" )]
	
	public class ViewStack extends Container 
	{
		// Properties
		protected var _visibleIndex		:int = -1;
		
		public function ViewStack() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
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
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		override protected function onChildrenChanged( child:DisplayObject, index:int, added:Boolean ):void
		{
			if ( added && content.numChildren == 1 && _visibleIndex == -1 )
			{
				visibleIndex = 0;
			}
			else if ( index <= _visibleIndex )
			{
				var temp:int = _visibleIndex;
				if ( numChildren == 0 )
				{
					visibleIndex = -1;
					return;
				}
				_visibleIndex = -1;
				visibleIndex = added ? temp+1: temp-1;
			}
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set visibleIndex( value:int ):void
		{
			if ( value < -1 || value >= content.numChildren )
			{
				throw( new Error( "Index out of bounds" ) );
				return;
			}
			
			if ( _visibleIndex == value ) return;
			var oldIndex:int = _visibleIndex;
			_visibleIndex = value
			invalidate();
			dispatchEvent( new IndexChangeEvent( IndexChangeEvent.INDEX_CHANGE, oldIndex, _visibleIndex, false, false ) );
			dispatchEvent( new Event(Event.CHANGE) );
		}
		
		public function get visibleIndex():int
		{
			return _visibleIndex;
		}
	}
}