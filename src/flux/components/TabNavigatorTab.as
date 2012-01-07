/**
 * TabNavigatorTab.as
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
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flux.skins.TabNavigatorTabSkin;
	import flux.skins.TabNavigatorTabCloseBtnSkin;
	
	public class TabNavigatorTab extends PushButton
	{
		// Properties
		private var _showCloseBtn	:Boolean = true;
		
		// Child elements
		private var closeBtn		:PushButton;
		
		public function TabNavigatorTab() 
		{
			super( TabNavigatorTabSkin );
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			super.init();
			focusEnabled = false;
			_resizeToContent = true;
			closeBtn = new PushButton( TabNavigatorTabCloseBtnSkin );
			closeBtn.addEventListener(MouseEvent.CLICK, clickCloseHandler);
			addChild(closeBtn);
		}
		
		override protected function validate():void
		{
			super.validate();
			
			if ( closeBtn.visible )
			{
				closeBtn.x = labelField.x + labelField.width + 0;
				closeBtn.y = (_height - closeBtn.height) >> 1;
				_width = closeBtn.x + closeBtn.width + 4;
			}
			
			skin.width = _width;
			skin.height = _height;
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function clickCloseHandler( event:MouseEvent ):void
		{
			dispatchEvent( new Event( Event.CLOSE, true, true ) );
		}
		
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set showCloseButton( value:Boolean ):void
		{
			if ( closeBtn.visible == value ) return;
			closeBtn.visible = value;
			invalidate();
		}
		
		public function get showCloseButton():Boolean
		{
			return closeBtn.visible;
		}
	}
}