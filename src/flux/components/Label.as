/**
 * Label.as
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
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class Label extends UIComponent 
	{
		// Properties
		private var _fontColor		:uint;
		private var _fontSize		:Number;
		private var _bold			:Boolean;
		
		// Child elements
		private var textField		:TextField;
		
		public function Label() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			textField = TextStyles.createTextField();
			_fontColor = uint(textField.defaultTextFormat.color);
			_fontSize = Number(textField.defaultTextFormat.size);
			_bold = textField.defaultTextFormat.bold;
			textField.multiline = false;
			textField.autoSize = TextFieldAutoSize.LEFT;
			addChild(textField);
		}
		
		override protected function validate():void
		{
			_width = textField.width;
			_height = textField.height;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set text( value:String ):void
		{
			textField.text = value;
			invalidate();
		}
		
		public function get text():String
		{
			return textField.text;
		}

		public function get fontColor():uint
		{
			return _fontColor;
		}

		public function set fontColor(value:uint):void
		{
			_fontColor = value;
			var tf:TextFormat = textField.defaultTextFormat;
			tf.color = _fontColor;
			textField.defaultTextFormat = tf;
			textField.setTextFormat(tf);
		}

		public function get fontSize():Number
		{
			return _fontSize;
		}

		public function set fontSize(value:Number):void
		{
			_fontSize = value;
			var tf:TextFormat = textField.defaultTextFormat;
			tf.size = _fontSize;
			textField.defaultTextFormat = tf;
			textField.setTextFormat(tf);
		}

		public function get bold():Boolean
		{
			return _bold;
		}

		public function set bold(value:Boolean):void
		{
			_bold = value;
			var tf:TextFormat = textField.defaultTextFormat;
			tf.bold = _bold;
			textField.defaultTextFormat = tf;
			textField.setTextFormat(tf);
		}
	}
}