/**
 * PropertyChangeEvent.as
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
	
	public class PropertyChangeEvent extends Event 
	{
		private var _propertyName	:String;
		private var _oldValue		:*;
		private var _newValue		:*;
		
		public function PropertyChangeEvent( type:String, oldValue:*, newValue:* ):void
		{
			super( type, false, false );
			
			if ( type.indexOf( "propertyChange_" ) == -1 )
			{
				throw( new Error( "Invalid event type for PropertyChangeEvent. Must be of the form 'propertyChange_<propertyName>' " ) );
				return;
			}
			
			_propertyName = type.substring( 15 );
			_oldValue = oldValue;
			_newValue = newValue;
		}
		
		override public function clone():Event
		{
			return new PropertyChangeEvent( type, _oldValue, _newValue );
		}
		
		public function get propertyName():String
		{
			return _propertyName;
		}
		
		public function get oldValue():*
		{
			return _oldValue;
		}
		
		public function get newValue():*
		{
			return _newValue;;
		}
	}
}