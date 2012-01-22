/**
 * ListItemRenderer.as
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
	import flash.events.IEventDispatcher;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flux.skins.ListItemRendererSkin;
	
	public class ListItemRenderer extends Button implements IItemRenderer
	{
		// Internal vars
		protected var _list			:List;
		protected var _data			:Object;
		
		protected var changeEventTypes	:Array;
		
		public function ListItemRenderer(skinClass:Class = null)
		{
			super(skinClass == null ? ListItemRendererSkin : skinClass );
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			super.init();
			doubleClickEnabled = true;
			focusEnabled = false;
			_labelAlign = TextFormatAlign.LEFT;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set data( value:Object ):void
		{
			if ( _data && _data is IEventDispatcher )
			{
				for each ( var changeEventType:String in changeEventTypes )
				{
					IEventDispatcher(_data).removeEventListener( changeEventType, dataChangeHandler );
				}
			}
			_data = value;
			if ( _data != null )
			{
				label = list.dataDescriptor.getLabel(_data);
				icon = list.dataDescriptor.getIcon(_data);
				enabled = list.dataDescriptor.getEnabled(_data);
				
				if ( _data is IEventDispatcher )
				{
					changeEventTypes = list.dataDescriptor.getChangeEventTypes(_data);
					for each ( changeEventType in changeEventTypes )
					{
						IEventDispatcher(_data).addEventListener( changeEventType, dataChangeHandler );
					}
				}
			}
			else
			{
				label = "";
				icon = null;
				enabled = true;
			}
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set list( value:List ):void
		{
			_list = value;
		}
		
		public function get list():List
		{
			return _list;
		}
		
		private function dataChangeHandler( event:Event ):void
		{
			data = _data;
		}
	}
}