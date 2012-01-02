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
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flux.skins.InputFieldSkin;
	
	public class InputField extends UIComponent 
	{
		// Child elements
		protected var skin				:Sprite;
		protected var textField			:TextField;
		
		public function InputField() 
		{
			
		}
		
		override protected function init():void
		{
			skin = new InputFieldSkin();
			addChild(skin);
			
			_width = skin.width;
			_height = skin.height;
			
			textField = new TextField();
			textField.defaultTextFormat = new TextFormat( TextStyles.fontFace, TextStyles.fontSize, TextStyles.fontColor );
			textField.embedFonts = TextStyles.embedFonts;
			textField.selectable = true;
			textField.type = TextFieldType.INPUT;
			textField.multiline = false;
			
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
		
		public function set restrict( value:String ):void
		{
			textField.restrict = value;
		}
		
		public function get restrict():String
		{
			return textField.restrict;
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