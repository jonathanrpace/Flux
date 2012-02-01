/**
 * ColorPickerItemEditor.as
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
	import flash.display.ColorCorrection;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flux.events.ItemEditorEvent;
	import flux.events.PropertyChangeEvent;
	import flux.managers.PopUpManager;
	import flux.skins.ColorPickerItemEditorSkin;
	public class ColorPickerItemEditor extends UIComponent 
	{
		// Properties
		private var _color			:uint = 0;
		
		// Child elements
		private var background		:Sprite;
		private var labelField		:TextField;
		private var swatch			:Sprite;
		private var panel			:Panel;
		private var colorPicker		:ColorPicker;
		
		public function ColorPickerItemEditor() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			background = new ColorPickerItemEditorSkin();
			addChild(background);
			
			labelField = TextStyles.createTextField();
			addChild(labelField);
			
			swatch = new Sprite();
			addChild(swatch);
			
			swatch.addEventListener(MouseEvent.CLICK, clickSwatchHandler);
		}
		
		override protected function validate():void
		{
			background.width = _width;
			background.height = _height;
			
			swatch.graphics.clear();
			swatch.graphics.beginFill(_color);
			swatch.graphics.drawRect(0, 0, _height - 4, _height - 4);
			swatch.x = _width - swatch.width - 2;
			swatch.y = 2;
			
			labelField.text = "#" + _color.toString(16).toUpperCase();
			labelField.x = 4;
			labelField.height = labelField.textHeight + 4;
			labelField.width = _width - labelField.x - swatch.width - 2;
			labelField.y = (_height - labelField.height) >> 1;
		}
		
		////////////////////////////////////////////////
		// Event Handlers
		////////////////////////////////////////////////
		
		private function clickSwatchHandler( event:MouseEvent ):void
		{
			openPanel();
		}
		
		private function clickCancelHandler( event:MouseEvent ):void
		{
			closePanel();
		}
		
		private function clickOkHandler( event:MouseEvent ):void
		{
			color = colorPicker.color;
			closePanel();
			dispatchEvent( new ItemEditorEvent( ItemEditorEvent.COMMIT_VALUE, _color, "color" ) );
		}
		
		////////////////////////////////////////////////
		// Private methods
		////////////////////////////////////////////////
		
		private function openPanel():void
		{
			if (panel && panel.stage) return;
			
			if ( !panel )
			{
				panel = new Panel();
				panel.width = 200;
				panel.height = 200;
				panel.label = "Color Picker";
				
				var cancelBtn:Button = new Button();
				cancelBtn.label = "Cancel";
				panel.controlBar.addChild(cancelBtn);
				cancelBtn.addEventListener(MouseEvent.CLICK, clickCancelHandler);
				
				var okBtn:Button = new Button();
				okBtn.label = "OK";
				panel.controlBar.addChild(okBtn);
				okBtn.addEventListener(MouseEvent.CLICK, clickOkHandler);
				
				colorPicker = new ColorPicker();
				colorPicker.percentWidth = colorPicker.percentHeight = 100;
				colorPicker.color = _color;
				colorPicker.padding = 0;
				colorPicker.showBorder = false;
				panel.addChild(colorPicker);
			}
			
			PopUpManager.addPopUp(panel, true, true);
		}
		
		private function closePanel():void
		{
			if ( panel.stage == null ) return;
			PopUpManager.removePopUp(panel);
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set color( v:uint ):void
		{
			if ( v == _color ) return;
			_color = v;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_value", null, _color ) );
		}
		
		public function get color():uint
		{
			return _color;
		}
	}
}