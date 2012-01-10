/**
 * Icon.as
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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	public class Image extends UIComponent 
	{
		// Properties
		private var _source		:Class;
		
		// Child elements
		private var bitmap		:Bitmap;
		
		public function Image() 
		{
			
		}
		
		override protected function init():void
		{
			bitmap = new Bitmap();
			addChild(bitmap);
		}
		
		override protected function validate():void
		{
			if ( _source == null )
			{
				if ( bitmap.bitmapData )
				{
					bitmap.bitmapData.dispose();
				}
				bitmap.bitmapData = null;
			}
			else
			{
				var instance:Object = new _source();
				bitmap.bitmapData = instance is Bitmap ? Bitmap(instance).bitmapData : BitmapData(instance);
				_width = bitmap.bitmapData.width;
				_height = bitmap.bitmapData.height;
				dispatchEvent( new Event( Event.RESIZE ) );
			}
		}
		
		public function set source( value:Class ):void
		{
			if ( value == _source ) return;
			_source = value
			invalidate();
		}
		
		public function get source():Class
		{
			return _source;
		}
	}
}