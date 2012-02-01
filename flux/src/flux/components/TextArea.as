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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flux.events.ItemEditorEvent;
	import flux.util.SelectionColor;
	
	import flux.skins.TextAreaSkin;
	import flux.managers.FocusManager;
	
	public class TextArea extends UIComponent
	{
		// Properties
		private var _padding		:int = 2;
		private var _editable		:Boolean = false;
		
		// Child elements
		protected var border		:Sprite;
		protected var textField		:TextField;
		
		public function TextArea()
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			border = new TextAreaSkin();
			addChild(border);
			
			_width = border.width;
			_height = border.height;
			
			textField = TextStyles.createTextField();
			textField.wordWrap = true;
			textField.addEventListener(FocusEvent.FOCUS_IN, textFieldFocusInHandler);
			textField.addEventListener(Event.CHANGE, textFieldChangeHandler);
			textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, textKeyFocusChangeHandler);

			
			multiline = true;
			
			SelectionColor.setFieldSelectionColor(textField, 0xCCCCCC);
			
			addChild(textField);
		}
		
		override protected function validate():void
		{
			textField.x = textField.y = _padding;
			textField.width = _width - _padding*2;
			
			if ( _resizeToContentHeight )
			{
				textField.autoSize = TextFieldAutoSize.LEFT;
				_height = textField.height + _padding*2
			}
			else
			{
				textField.autoSize = TextFieldAutoSize.NONE;
				textField.height = _height - _padding*2;
			}
			
			border.width = _width;
			border.height = _height;
		}
		
		protected function commitValue():void
		{
			dispatchEvent( new ItemEditorEvent( ItemEditorEvent.COMMIT_VALUE, text, "text" ) );
		}
		
		override public function onGainComponentFocus():void
		{
			if ( !_editable ) return;
			stage.focus = textField;
		}
		
		override public function onLoseComponentFocus():void
		{
			commitValue();
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function textKeyFocusChangeHandler(e:FocusEvent):void
		{
			e.preventDefault();
			textField.replaceText(textField.caretIndex, textField.caretIndex, "\t");
			textField.setSelection(textField.caretIndex + 1, textField.caretIndex + 1);
		}
		
		private function textFieldFocusInHandler( event:FocusEvent ):void
		{
			FocusManager.setFocus(this);
		}
		
		private function textFieldChangeHandler( event:Event ):void
		{
			event.stopImmediatePropagation();
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set text( value:String ):void
		{
			textField.text = String(value);
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		public function get text():String
		{
			return textField.text;
		}
		
		public function set textAlign( value:String ):void
		{
			if ( value == textField.defaultTextFormat.align ) return;
			var tf:TextFormat = textField.defaultTextFormat;
			tf.align = value;
			textField.defaultTextFormat = tf;
			textField.setTextFormat(tf);
		}
		
		public function get textAlign():String
		{
			return textField.defaultTextFormat.align;
		}
		
		public function get fontColor():uint
		{
			return uint(textField.defaultTextFormat.color);
		}
		
		public function set embedFonts( value:Boolean ):void
		{
			textField.embedFonts = value;
		}
		
		public function get embedFonts():Boolean
		{
			return textField.embedFonts;
		}
		
		public function set fontFamily(value:String):void
		{
			var tf:TextFormat = textField.defaultTextFormat;
			tf.font = value;
			textField.defaultTextFormat = tf;
			textField.setTextFormat(tf);
		}
		
		public function get fontFamily():String
		{
			return textField.defaultTextFormat.font;
		}
		
		public function set fontColor(value:uint):void
		{
			var tf:TextFormat = textField.defaultTextFormat;
			tf.color = value;
			textField.defaultTextFormat = tf;
			textField.setTextFormat(tf);
		}
		
		public function get fontSize():Number
		{
			return Number(textField.defaultTextFormat.size);
		}
		
		public function set fontSize(value:Number):void
		{
			var tf:TextFormat = textField.defaultTextFormat;
			tf.size = value;
			textField.defaultTextFormat = tf;
			textField.setTextFormat(tf);
		}
		
		public function get bold():Boolean
		{
			return textField.defaultTextFormat.bold;
		}
		
		public function set bold(value:Boolean):void
		{
			var tf:TextFormat = textField.defaultTextFormat;
			tf.bold = value;
			textField.defaultTextFormat = tf;
			textField.setTextFormat(tf);
		}
		
		public function set editable( value:Boolean ):void
		{
			if ( value == _editable ) return;
			_editable = value;
			textField.type = _editable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			textField.selectable = _editable;
			focusEnabled = _editable;
			textField.mouseEnabled = _editable;
		}
		
		public function get editable():Boolean
		{
			return _editable;
		}
		
		public function set multiline( value:Boolean ):void
		{
			if ( value == textField.multiline ) return;
			textField.multiline = value;
			textField.type = _editable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			textField.selectable = _editable;
		}
		
		public function get multiline():Boolean
		{
			return textField.multiline;
		}
		
		public function set showBorder( value:Boolean ):void
		{
			border.visible = value;
		}
		
		public function get showBorder():Boolean
		{
			return border.visible;
		}
		
		public function get padding():int
		{
			return _padding;
		}
		
		public function set padding(value:int):void
		{
			if ( value == _padding ) return;
			_padding = value;
			invalidate();
		}
		
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
	}
}