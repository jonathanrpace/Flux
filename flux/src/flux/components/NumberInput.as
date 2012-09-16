/**
 * NumberInputField.as
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
	import flash.events.TextEvent;
	import flash.ui.Keyboard;
	
	import flux.events.ItemEditorEvent;
	
	public class NumberInput extends TextInput
	{
		// Properties
		private var _value				:String = "0";
		private var _min				:Number = -Number.MAX_VALUE;
		private var _max				:Number = Number.MAX_VALUE;
		private var _numDecimalPlaces	:uint = 3;
		
		public function NumberInput() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			super.init();
			textField.restrict = "\-0-9.";
			textField.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			textField.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			value = 0;
		}
		
		override protected function commitValue():void
		{
			if ( textField.text == "" )
			{
				value = 0;
				return;
			}
			var oldValue:String = _value;
			value = Number( textField.text );
			textField.text = _value;
			if ( _value != oldValue )
			{
				dispatchEvent( new ItemEditorEvent( ItemEditorEvent.COMMIT_VALUE, _value, "value" ) );
			}
		}
		
		////////////////////////////////////////////////
		// Event Handlers
		////////////////////////////////////////////////
		
		override public function onLoseComponentFocus():void
		{
			commitValue();
		}
		
		private function onTextInput( event:TextEvent ):void
		{
			// Stop two '.' characters from entering the field.
			if ( event.text.indexOf(".") != -1 )
			{
				if ( textField.text.indexOf(".") != -1 )
				{
					event.preventDefault();
					event.stopImmediatePropagation();
					return;
				}
			}
			
			// Stop two '-' characters from entering the field, and ensure it can only appear at the start of the string
			if ( event.text.indexOf("-") != -1 )
			{
				if ( textField.text.indexOf("-") != -1 )
				{
					event.preventDefault();
					event.stopImmediatePropagation();
					return;
				}
				if ( textField.caretIndex != 0 )
				{
					event.preventDefault();
					event.stopImmediatePropagation();
					return;
				}
			}
		}
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			if ( event.keyCode == Keyboard.ENTER )
			{
				commitValue();
			}
		}
		
		public function set value( v:Number ):void
		{
			if ( isNaN(v) ) v = 0;
			v = v < _min ? _min : v > _max ? _max : v;
			
			var newValue:String = String(v);
			
			if ( _numDecimalPlaces > 0 && newValue.indexOf(".") != -1 )
			{
				var index:int = newValue.indexOf(".");
				var wholeNumber:String = newValue.substring( 0, index );
				var fraction:String = newValue.substr( index, _numDecimalPlaces+1 );
				newValue = wholeNumber + fraction;
			}
			else
			{
				newValue = String(int(v));
			}
			
			if ( newValue != _value )
			{
				_value = newValue;
				textField.text = _value;
				dispatchEvent( new Event( Event.CHANGE ) );
			}
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function get value():Number
		{
			return Number(_value);
		}
		
		public function set min( v:Number ):void
		{
			_min = v;
			value = v < _min ? _min : v;
		}
		
		public function get min():Number
		{
			return _min;
		}
		
		public function set max( v:Number ):void
		{
			_max = v;
			value = v > _max ? _max : v;
		}
		
		public function get max():Number
		{
			return _max;
		}
		
		public function set numDecimalPlaces( v:uint ):void
		{
			_numDecimalPlaces = v;
			value = value;
		}
		
		public function get numDecimalPlaces():uint
		{
			return _numDecimalPlaces;
		}
	}
}