/**
 * ComponentFocusEvent.as
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

package flux.events 
{
	import flash.events.Event;
	import flux.components.UIComponent;
	
	
	public class ComponentFocusEvent extends Event 
	{
		public static const COMPONENT_FOCUS_IN	:String = "componentFocusIn";
		public static const COMPONENT_FOCUS_OUT	:String = "componentFocusOut";
		
		private var _relatedComponent	:UIComponent
		
		public function ComponentFocusEvent( type:String, relatedComponent:UIComponent, bubbles:Boolean = false, cancelable:Boolean = false ) 
		{
			super(type, bubbles, cancelable);
			_relatedComponent = relatedComponent;
		}
		
		override public function clone():Event
		{
			return new ComponentFocusEvent( type, _relatedComponent, bubbles, cancelable );
		}
		
		public function get relatedComponent():UIComponent
		{
			return _relatedComponent;
		}
	}
}