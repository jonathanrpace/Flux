/**
 * VBox.as
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
	import flux.layouts.HorizontalLayout;
	import flux.layouts.VerticalLayout;
	
	public class VBox extends Container 
	{
		
		public function VBox() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Properted methods
		////////////////////////////////////////////////
				
		override protected function init():void
		{
			super.init();
			_layout = new VerticalLayout();
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set spacing( value:int ):void
		{
			VerticalLayout(_layout).spacing = value;
		}
		
		public function get spacing():int
		{
			return VerticalLayout(_layout).spacing;
		}
		
		public function set verticalAlign( value:String ):void
		{
			VerticalLayout(_layout).verticalAlign = value;
		}
		
		public function get verticalAlign():String
		{
			return VerticalLayout(_layout).verticalAlign;
		}
		
		public function set horizontalAlign( value:String ):void
		{
			VerticalLayout(_layout).horizontalAlign = value;
		}
		
		public function get horizontalAlign():String
		{
			return VerticalLayout(_layout).horizontalAlign;
		}
	}

}