/**
 * Checkbox.as
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
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flux.managers.FocusManager;
	import flux.skins.CheckBoxSkin;
	
	public class CheckBox extends Button 
	{
		// Properties
		protected var _indeterminate		:Boolean = false;
		
		public function CheckBox() 
		{
			super( CheckBoxSkin );
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			super.init()
			
			_toggle = true;
			
			var textFormat:TextFormat = labelField.defaultTextFormat;
			textFormat.align = TextFormatAlign.LEFT;
			labelField.defaultTextFormat = textFormat;
			labelField.autoSize = TextFieldAutoSize.LEFT;
			
			iconImage.visible = false;
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
		
		protected function updateSkinState():void
		{
			if ( !_selected && !_indeterminate )
			{
				_down ? skin.gotoAndPlay("Down") : _over ? skin.gotoAndPlay("Over") : skin.gotoAndPlay("Up");
			}
			else if ( _selected && !_indeterminate )
			{
				_down ? skin.gotoAndPlay("SelectedDown") : _over ? skin.gotoAndPlay("SelectedOver") : skin.gotoAndPlay("SelectedUp");
			}
			else
			{
				_down ? skin.gotoAndPlay("IndeterminateDown") : _over ? skin.gotoAndPlay("IndeterminateOver") : skin.gotoAndPlay("IndeterminateUp");
			}
		}
		
		////////////////////////////////////////////////
		// Event Handlers
		////////////////////////////////////////////////
		
		override protected function rollOverHandler(event:MouseEvent):void
		{
			_over = true;
			updateSkinState();
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		override protected function rollOutHandler(event:MouseEvent):void
		{
			_over = false;
			_indeterminate ? skin.gotoAndPlay("IndeterminateOut") : _selected ? skin.gotoAndPlay( "SelectedOut" ) : skin.gotoAndPlay( "Out" );
			removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		override protected function mouseDownHandler(event:MouseEvent):void
		{
			_down = true;
			updateSkinState();
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}

		override protected function mouseUpHandler(event:MouseEvent):void
		{
			if(_over)
			{
				_selected = !_selected;
				_indeterminate = false;
				dispatchEvent( new Event( Event.CHANGE ) );
			}
			_down = false;
			
			updateSkinState();
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set indeterminate( value:Boolean ):void
		{
			_indeterminate = value;
			updateSkinState();
		}
		
		public function get indeterminate():Boolean
		{
			return _indeterminate;
		}
	}
}