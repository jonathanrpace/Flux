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

package flux.components 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flux.skins.InputFieldSkin;
	import flux.util.SelectionColor;
	
	public class InputField extends UIComponent 
	{
		// Child elements
		protected var skin				:Sprite;
		protected var textField			:TextField;
		
		public function InputField() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			focusEnabled = true;
			
			skin = new InputFieldSkin();
			addChild(skin);
			
			_width = skin.width;
			_height = skin.height;
			
			textField = TextStyles.createTextField();
			textField.selectable = true;
			textField.type = TextFieldType.INPUT;
			textField.mouseEnabled = true;
			textField.addEventListener(Event.CHANGE, textFieldChangeHandler);
			textField.addEventListener(FocusEvent.FOCUS_IN, textFieldFocusInHandler);
			
			SelectionColor.setFieldSelectionColor(textField, 0xCCCCCC);
			
			addChild( textField );
		}
		
		override protected function validate():void
		{
			textField.x = 4;
			textField.width = _width - 4;
			textField.height = Math.min(textField.textHeight + 4, _height);
			textField.y = (_height - (textField.height)) >> 1;
			
			skin.width = _width;
			skin.height = _height;
		}
		
		////////////////////////////////////////////////
		// Event Handlers
		////////////////////////////////////////////////
		
		private function textFieldFocusInHandler( event:FocusEvent ):void
		{
			if ( _focusEnabled )
			{
				event.stopImmediatePropagation();
				focusManager.setFocus(this);
			}
		}
		
		private function textFieldChangeHandler( event:Event ):void
		{
			event.stopImmediatePropagation();
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set restrict( value:String ):void
		{
			textField.restrict = value;
		}
		
		public function get restrict():String
		{
			return textField.restrict;
		}
		
		public function set maxChars( value:int ):void
		{
			textField.maxChars = value;
		}
		
		public function get maxChars():int
		{
			return textField.maxChars;
		}
		
		public function set text( value:String ):void
		{
			textField.text = value;
		}
		
		public function get text():String
		{
			return textField.text;
		}
	}
}