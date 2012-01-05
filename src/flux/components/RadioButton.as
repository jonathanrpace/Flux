/**
 * RadioButton.as
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
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flux.skins.RadioButtonSkin;
	
	public class RadioButton extends PushButton 
	{
		public function RadioButton() 
		{
			super( RadioButtonSkin );
		}
		
		override protected function init():void
		{
			super.init();
			toggle = true;
			
			var textFormat:TextFormat = labelField.defaultTextFormat;
			textFormat.align = TextFormatAlign.LEFT;
			labelField.defaultTextFormat = textFormat;
			labelField.autoSize = TextFieldAutoSize.LEFT;
			
			iconContainer.visible = false;
		}
		
		override protected function validate():void
		{
			_height = labelField.height;
			skin.y = (_height - skin.height) >> 1;
			labelField.x = skin.x + skin.width + 4;
			labelField.height = Math.min(labelField.textHeight + 4, _height);
			labelField.y = (_height - (labelField.height)) >> 1;
			_width = labelField.x + labelField.width;
		}
	}
}