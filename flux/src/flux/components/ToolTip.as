/**
 * Tree.as
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
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flux.skins.ToolTipSkin;
	
	public class ToolTip extends UIComponent 
	{
		// Styles
		public static var stylePaddingLeft	:int = 2;
		public static var stylePaddingRight	:int = 4;
		public static var stylePaddingTop	:int = 2;
		public static var stylePaddingBottom:int = 4;
		
		// Properties
		private var _paddingLeft	:int = stylePaddingLeft;
		private var _paddingRight	:int = stylePaddingRight;
		private var _paddingTop		:int = stylePaddingTop;
		private var _paddingBottom	:int = stylePaddingBottom;
		
		// Child elements
		private var skin		:Sprite;
		private var textField	:TextField;
		
		public function ToolTip() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			skin = new ToolTipSkin();
			skin.height = _height
			addChild(skin);
			
			textField = TextStyles.createTextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			addChild(textField);
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		override protected function validate():void
		{
			textField.x = _paddingLeft;
			textField.y = _paddingTop;
			
			_width = textField.x + textField.width + _paddingRight;
			_height = textField.y + textField.height + _paddingBottom;
			
			skin.width = _width;
			skin.height = _height;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set text( value:String ):void
		{
			textField.text = value;
			invalidate()
		}
		
		public function get text():String
		{
			return textField.text;
		}
	}
}