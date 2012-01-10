/**
 * ArrayCollectionEvent.as
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
	
	public class ArrayCollectionEvent extends Event 
	{
		public static var CHANGE		:String = "change";
		
		private var _kind	:int;
		private var _index		:int;
		private var _item		:*;
		
		public function ArrayCollectionEvent( type:String, changeKind:int, index:int = 0, item:* = null ) 
		{
			super(type, false, false);
			_kind = changeKind;
			_index = index;
			_item = item;
		}
		
		override public function clone():Event
		{
			return new ArrayCollectionEvent( type, _kind, _index, _item );
		}
		
		public function get kind():int
		{
			return _kind;
		}
		
		public function get index():int
		{
			return _index;
		}
		
		public function get item():*
		{
			return _item;
		}
	}
}