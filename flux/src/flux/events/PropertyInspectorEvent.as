/**
 * PropertyInspectorEvent.as
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
	
	public class PropertyInspectorEvent extends Event 
	{
		public static var COMMIT_VALUE		:String = "commitValue";
		
		
		private var _hosts		:Array;
		private var _property	:String;
		private var _value		:*;
		
		public function PropertyInspectorEvent( type:String, hosts:Array, property:String, value:*, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super(type, bubbles, cancelable);
			
			_hosts = hosts;
			_property = property;
			_value = value;
		}
		
		override public function clone():Event
		{
			return new PropertyInspectorEvent( type, _hosts, _property, _value, bubbles, cancelable );
		}
		
		public function get hosts():Array
		{
			return _hosts.slice();
		}
		
		public function get property():String
		{
			return _property;
		}
		
		public function get value():*
		{
			return _value;
		}
	}
}