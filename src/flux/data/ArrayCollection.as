/**
 * ArrayCollection.as
 * 
 * Wraps an array and provides detailed change events. Must be used to wrap data
 * passed to list Components.
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

package flux.data 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flux.events.ArrayCollectionChangeKind;
	import flux.events.ArrayCollectionEvent;
	
	[Event( type="flux.events.ArrayCollectionEvent", name="change" )]
	public dynamic class ArrayCollection extends Proxy implements IEventDispatcher
	{
		private var array		:Array;
		private var dispatcher	:EventDispatcher;
		
		public function ArrayCollection( source:Array = null ) 
		{
			array = source == null ? [] : source;
			dispatcher = new EventDispatcher(this);
		}
		
		////////////////////////////////////////////////
		// Public methods
		////////////////////////////////////////////////
		
		public function addItemAt( item:*, index:int ):void
		{
			if ( index < 0 || index > array.length ) throw( new Error( "Index out of bounds : " + index) );
			
			array.splice( index, 0, item );
			dispatcher.dispatchEvent( new ArrayCollectionEvent( ArrayCollectionEvent.CHANGE, ArrayCollectionChangeKind.ADD, index, item ) );
		}
		
		public function removeItemAt( index:int ):void
		{
			if ( index < 0 || index > array.length ) throw( new Error( "Index out of bounds : " + index) );
			
			var item:* = array[index];
			array.splice( index, 1 );
			dispatcher.dispatchEvent( new ArrayCollectionEvent( ArrayCollectionEvent.CHANGE, ArrayCollectionChangeKind.REMOVE, index, item ) );
		}
		
		public function getItemIndex( item:* ):int
		{
			return array.indexOf(item);
		}
		
		public function removeItem( item:* ):void
		{
			var index:int = array.indexOf(item);
			if ( index == -1 )
			{
				throw( new Error( "Item does not exist." ) );
				return;
			}
			removeItemAt(index);
		}
		
		public function push( value:* ):void
		{
			this[array.length] = value;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set source( value:Array ):void
		{
			array = value;
			dispatcher.dispatchEvent( new ArrayCollectionEvent( ArrayCollectionEvent.CHANGE, ArrayCollectionChangeKind.REFRESH ) );
		}
		
		public function get source():Array
		{
			return array;
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			return array[name];
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			var index:int = int(name);
			if ( isNaN(index) ) throw( new Error( "Invalid index : " + name) );
			if ( index < 0 || index > array.length ) throw( new Error( "Index out of bounds : " + index) );
			
			var changeKind:int;
			if ( index == array.length )
			{
				if ( value == null )
				{
					array.length--;
					changeKind = ArrayCollectionChangeKind.REMOVE;
				}
				else
				{
					changeKind = ArrayCollectionChangeKind.ADD;
					array[array.length] = value;
				}
			}
			else
			{
				changeKind = ArrayCollectionChangeKind.REPLACE;
				array[index] = value;
			}
			
			dispatcher.dispatchEvent( new ArrayCollectionEvent( ArrayCollectionEvent.CHANGE, changeKind, index, value ) );
		}
		
		public function get length():int
		{
			return array.length;
		}
		
		////////////////////////////////////////////////
		// Implement IEventDispatcher
		////////////////////////////////////////////////
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function dispatchEvent(event:Event):Boolean
		{
			return dispatcher.dispatchEvent( event );
		}

		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			dispatcher.removeEventListener( type, listener, useCapture );
		}

		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}
	}
}