/**
 * RadioButtonGroup.as
 * 
 * Only capable of containing PushButtons. Enforces mutually exclusive selection behaviour.
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
	
	public class RadioButtonGroup extends Container 
	{
		public function RadioButtonGroup() 
		{
			
		}
		
		override protected function onChildrenChanged( child:UIComponent, index:int, added:Boolean ):void
		{
			if ( added && child is PushButton == false )
			{
				throw( new Error( "RadioButtonGroup only supports PushButton children" ) );
				return;
			}
			
			var btn:PushButton = PushButton(child);
			if ( added )
			{
				btn.addEventListener(Event.CHANGE, changeButtonHandler);
				btn.toggle = true;
			}
			else
			{
				btn.removeEventListener(Event.CHANGE, changeButtonHandler);
			}
		}
		
		private function changeButtonHandler( event:Event ):void
		{
			var changedChild:PushButton = PushButton(event.target);
			if ( changedChild.selected == false )
			{
				event.preventDefault();
				return;
			}
			for ( var i:int = 0; i < content.numChildren; i++ )
			{
				var child:PushButton = PushButton( content.getChildAt(i) );
				if ( child == changedChild ) continue;
				child.removeEventListener(Event.CHANGE, changeButtonHandler);
				child.selected = false;
				child.addEventListener(Event.CHANGE, changeButtonHandler);
			}
			dispatchEvent( new Event( Event.CHANGE ) );
		}
	}
}