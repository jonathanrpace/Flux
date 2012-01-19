/**
 * Alert.as
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
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flux.events.AlertEvent;
	import flux.events.SelectEvent;
	import flux.layouts.HorizontalLayout;
	import flux.layouts.LayoutAlign;
	import flux.managers.PopUpManager;
	
	[Event( type="flux.events.AlertEvent", name="alertClose" )]
	public class Alert extends Panel
	{
		////////////////////////////////////////////////
		// Static methods
		////////////////////////////////////////////////
		
		public static function show( title:String, text:String, buttons:Array, defaultButton:String = null, icon:Class = null, modal:Boolean = true, closeHandler:Function = null ):void
		{
			var alert:Alert = new Alert();
			alert.label = title;
			alert.text = text;
			alert.mainIcon = icon;
			if ( closeHandler != null )
			{
				alert.addEventListener( AlertEvent.ALERT_CLOSE, closeHandler);
			}
			
			HorizontalLayout(alert.controlBar.layout).horizontalAlign = LayoutAlign.CENTRE;
			
			for ( var i:int = 0; i < buttons.length; i++ )
			{
				var btn:Button = new Button();
				btn.label = buttons[i];
				alert.controlBar.addChild(btn);
				if ( btn.label == defaultButton )
				{
					alert.defaultButton = btn;
				}
			}
			alert.validateNow();
			PopUpManager.addPopUp(alert, modal, true);
		}
		
		// Child elements
		private var textField		:TextField;
		private var mainIconImage	:Image;
		
		public function Alert()
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			super.init();
			
			showCloseButton = false;
			dragEnabled = true;
			
			_controlBar.padding = 10;
			_controlBar.addEventListener(SelectEvent.SELECT, selectControlBarHandler);
			padding = 20;
			
			mainIconImage = new Image();
			addRawChild(mainIconImage);
			
			textField = TextStyles.createTextField();
			var tf:TextFormat = textField.defaultTextFormat;
			tf.align = TextFormatAlign.CENTER;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.defaultTextFormat = tf;
			addRawChild(textField);
			
			_width = 300;
			_height = 140;
		}
		
		override protected function validate():void
		{
			var layoutRect:Rectangle = getChildrenLayoutArea();
			mainIconImage.validateNow();
			mainIconImage.x = layoutRect.x;
			textField.x = mainIconImage.x + mainIconImage.width + 4;
			textField.width = layoutRect.width - textField.x;
			_height = _titleBarHeight + textField.height + 80;
			super.validate();
			layoutRect = getChildrenLayoutArea();
			textField.y = layoutRect.y + ((layoutRect.height - textField.height) >> 1);
			mainIconImage.y = layoutRect.y + ((layoutRect.height - mainIconImage.height) >> 1);
		}
		
		////////////////////////////////////////////////
		// Event Handlers
		////////////////////////////////////////////////
		
		private function selectControlBarHandler( event:SelectEvent ):void
		{
			var button:Button = event.target as Button;
			if ( button == null ) return;
			PopUpManager.removePopUp(this);
			dispatchEvent( new AlertEvent( AlertEvent.ALERT_CLOSE, button.label ) );
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set text( value:String ):void
		{
			textField.text = value;
		}
		
		public function get text():String
		{
			return textField.text;
		}
		
		public function set mainIcon( value:Class ):void
		{
			if ( value == mainIconImage.source ) return;
			mainIconImage.source = value;
			invalidate();
		}
		
		public function get mainIcon():Class
		{
			return mainIconImage.source;
		}
	}
}