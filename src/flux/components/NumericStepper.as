/**
 * NumericStepper.as
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
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flux.skins.NumericStepperDownBtnSkin;
	import flux.skins.NumericStepperUpBtnSkin;
	
	public class NumericStepper extends UIComponent 
	{
		private static const DELAY_TIME		:int = 500;
		private static const REPEAT_TIME	:int = 100;
		
		// Child elements
		private var inputField			:InputField;
		private var upBtn				:PushButton;
		private var downBtn				:PushButton;
		
		// Properties
		private var _value				:Number;
		private var _stepSize			:Number = 1;
		private var _min				:Number = -Number.MAX_VALUE;
		private var _max				:Number = Number.MAX_VALUE;
		private var _numDecimalPlaces	:uint = 2;
		
		// Internal vars
		private var delayTimer			:Timer;
		private var repeatTimer			:Timer;
		private var repeatDirection		:Number;
		
		public function NumericStepper() 
		{
			
		}
		
		override protected function init():void
		{
			inputField = new InputField();
			inputField.restrict = "0-9."
			inputField.addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
			inputField.addEventListener(FocusEvent.FOCUS_OUT, focusOutInputFieldHandler);
			inputField.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			addChild(inputField);
			
			_width = inputField.width;
			_height = inputField.height;
			
			upBtn = new PushButton(NumericStepperUpBtnSkin);
			upBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownButtonHandler);
			addChild(upBtn);
			
			downBtn = new PushButton(NumericStepperDownBtnSkin);
			downBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownButtonHandler);
			addChild(downBtn);
			
			delayTimer = new Timer( DELAY_TIME, 1 );
			delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, delayCompleteHandler);
			repeatTimer = new Timer( REPEAT_TIME, 0 );
			repeatTimer.addEventListener(TimerEvent.TIMER, repeatHandler);
			
			value = 0;
		}
		
		override protected function validate():void
		{
			inputField.width = _width - upBtn.width;
			inputField.height = _height;
			
			upBtn.height = _height >> 1;
			upBtn.x = inputField.width;
			
			downBtn.height = _height - upBtn.height;
			downBtn.x = inputField.width;
			downBtn.y = upBtn.height;
		}
		
		////////////////////////////////////////////////
		// Event Handlers
		////////////////////////////////////////////////
		
		/**
		 * Performs validation on input text.
		 * The field is already restricted to 0-9 and . characters, so we only
		 * need to dissallow a second '.' character.
		 */
		private function textInputHandler( event:TextEvent ):void
		{
			var textField:TextField = TextField(event.target);
			if ( event.text == "." && textField.text.indexOf(".") != -1 )
			{
				event.preventDefault();
			}
		}
		
		private function focusOutInputFieldHandler( event:FocusEvent ):void
		{
			if ( inputField.text == "" ) inputField.text = "0";
			value = Number( inputField.text );
		}
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			if ( event.keyCode == Keyboard.ENTER )
			{
				value = Number( inputField.text );
			}
		}
		
		private function mouseDownButtonHandler( event:MouseEvent ):void
		{
			repeatDirection = event.target == upBtn ? 1 : -1;
			value += repeatDirection * _stepSize;
			delayTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, endRepeatHandler);
			event.target.addEventListener(MouseEvent.ROLL_OUT, endRepeatHandler);
		}
		
		private function endRepeatHandler( event:MouseEvent ):void
		{
			upBtn.removeEventListener(MouseEvent.ROLL_OUT, endRepeatHandler);
			downBtn.removeEventListener(MouseEvent.ROLL_OUT, endRepeatHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endRepeatHandler);
			delayTimer.stop();
			repeatTimer.stop();
		}
		
		private function delayCompleteHandler( event:TimerEvent ):void
		{
			repeatTimer.start();
		}
		
		private function repeatHandler( event:TimerEvent ):void
		{
			value += repeatDirection * _stepSize;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set value( v:Number ):void
		{
			v = v < _min ? _min : v > _max ? _max : v;
			if ( _value == v ) return;
			
			_value = v;
			
			var str:String = String(_value);
			
			if ( _numDecimalPlaces > 0 && str.indexOf(".") != -1 )
			{
				var index:int = str.indexOf(".");
				var wholeNumber:String = str.substring( 0, index );
				var fraction:String = str.substr( index, _numDecimalPlaces+1 );
				str = wholeNumber + fraction;
			}
			else
			{
				str = String(int(_value));
			}
			
			inputField.text = str;
			
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		public function get value():Number
		{
			return _value;
		}
		
		public function set min( v:Number ):void
		{
			_min = v;
			value = _value;
		}
		
		public function get min():Number
		{
			return _min;
		}
		
		public function set max( v:Number ):void
		{
			_max = v;
			value = _value;
		}
		
		public function get max():Number
		{
			return _max;
		}
		
		public function set stepSize( v:Number ):void
		{
			_stepSize = v;
		}
		
		public function get stepSize():Number
		{
			return _stepSize;
		}
		
		public function set numDecimalPlaces( v:uint ):void
		{
			_numDecimalPlaces = v;
			value = _value;
		}
		
		public function get numDecimalPlaces():uint
		{
			return _numDecimalPlaces;
		}
	}
}