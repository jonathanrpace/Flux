/**
 * InputField.as
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

package flux.managers 
{
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	
	import flux.components.UIComponent;
	import flux.components.flux_internal;

	use namespace flux_internal;
	
	public class FocusManager extends EventDispatcher
	{
		private static var instance			:FocusManager;
		
		public static function getInstance():FocusManager
		{
			return instance;
		}
		
		private var focusedComponent		:UIComponent;
		
		public function FocusManager() 
		{
			if ( instance != null )
			{
				throw( new Error( "An instance of FocusManager already exists" ) );
				return;
			}
			instance = this;
		}
		
		public static function setFocus( value:UIComponent ):void
		{
			instance.setFocus( value );
		}
		
		public function setFocus( value:UIComponent ):void
		{
			if ( value == focusedComponent ) return;
			if ( value.focusEnabled == false ) return;
			
			var previouslyFocusedComponent:UIComponent = focusedComponent;
			if ( previouslyFocusedComponent )
			{
				previouslyFocusedComponent.isFocused = false;
				previouslyFocusedComponent.dispatchEvent( new FocusEvent( FocusEvent.FOCUS_OUT, false, false, value ) );
			}
			
			focusedComponent = value;
			
			if ( focusedComponent )
			{
				focusedComponent.isFocused = true;
				focusedComponent.dispatchEvent( new FocusEvent( FocusEvent.FOCUS_IN, false, false, previouslyFocusedComponent ) );
			}
		}
	}
}