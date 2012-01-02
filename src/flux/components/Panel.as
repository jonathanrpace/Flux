/**
 * Panel.as
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
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flux.layouts.HorizontalLayout;
	import flux.layouts.LayoutAlign;
	import flux.skins.PanelSkin;
	
	public class Panel extends Container 
	{
		// Styles
		public static var styleTitleBarHeight	:int = 22;
		
		// Child elements
		private var background		:Sprite;
		private var _controlBar		:Container;
		private var titleField		:TextField;
		
		// Properties
		private var _titleBarHeight	:int = Panel.styleTitleBarHeight;
		
		public function Panel() 
		{
			
		}
		
		override protected function init():void
		{
			background = new PanelSkin();
			addRawChild(background);
			
			super.init();
			
			_controlBar = new Container();
			
			_controlBar.layout = new HorizontalLayout( 4, LayoutAlign.RIGHT );
			_controlBar.padding = 4;
			addRawChild(_controlBar)
			
			titleField = new TextField();
			titleField.defaultTextFormat = new TextFormat( TextStyles.fontFace, TextStyles.fontSize, TextStyles.fontColor, true );
			titleField.embedFonts = TextStyles.embedFonts;
			titleField.selectable = false;
			addRawChild(titleField);
			
			_width = background.width;
			_height = background.height;
			
			padding = 4;
		}
		
		override protected function validate():void
		{
			_controlBar.resizeToContent = true;
			super.validate();
			
			_controlBar.resizeToContent = false;
			_controlBar.width = _width;
			_controlBar.validateNow();
			_controlBar.y = _height - _controlBar.height;
			
			background.width = _width;
			background.height = _height;
			
			titleField.x = _paddingLeft;
			titleField.width = _width - (_paddingLeft + _paddingRight);
			titleField.height = Math.min(titleField.textHeight + 4, _height);
			titleField.y = (_titleBarHeight - (titleField.height)) >> 1;
		}
		
		override protected function getChildrenLayoutArea():Rectangle
		{
			var rect:Rectangle = new Rectangle( _paddingLeft, _paddingTop, _width - (_paddingRight+_paddingLeft), _height - (_paddingBottom+_paddingTop) );
			_controlBar.validateNow();
			rect.top += titleBarHeight;
			rect.bottom -= _controlBar.height;
			return rect;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function get controlBar():Container
		{
			return _controlBar;
		}
		
		public function set titleBarHeight( value:int ):void
		{
			_titleBarHeight = value;
			invalidate();
		}
		
		public function get titleBarHeight():int
		{
			return _titleBarHeight;
		}
		
		public function set title( value:String ):void
		{
			titleField.text = value;
		}
		
		public function get title():String
		{
			return titleField.text;
		}
	}
}