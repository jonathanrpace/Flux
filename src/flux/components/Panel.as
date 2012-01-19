/**
 * Panel.as
 *
 * Container component with a title bar and control bar.
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
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flux.events.ComponentFocusEvent;
	import flux.events.SelectEvent;
	import flux.layouts.HorizontalLayout;
	import flux.layouts.LayoutAlign;
	import flux.managers.FocusManager;
	import flux.skins.PanelSkin;
	import flux.skins.PanelCloseBtnSkin;
	
	[Event( type="flash.events.Event", name="close" )]
	public class Panel extends Container
	{
		// Properties
		public   var dragEnabled		:Boolean = false;
		protected var _titleBarHeight	:int;
		protected var _defaultButton	:Button;
		
		// Child elements
		protected var border		:MovieClip;
		protected var _controlBar	:Container;
		protected var titleField	:TextField;
		protected var closeBtn		:Button;
		protected var iconImage		:Image;
		
		public function Panel()
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			border = new PanelSkin();
			_titleBarHeight = border.scale9Grid.top;
			addRawChild(border);
			
			super.init();
			
			_controlBar = new Container();
			
			_controlBar.layout = new HorizontalLayout( 4, LayoutAlign.RIGHT );
			_controlBar.padding = 4;
			addRawChild(_controlBar)
			
			titleField = TextStyles.createTextField( true );
			addRawChild(titleField);
			
			closeBtn = new Button( PanelCloseBtnSkin );
			addRawChild(closeBtn);
			closeBtn.addEventListener(MouseEvent.CLICK, clickCloseBtnHandler);
			
			iconImage = new Image();
			addRawChild(iconImage);
			
			_width = border.width;
			_height = border.height;
			
			border.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownBackgroundHandler);
			
			showCloseButton = false;
			padding = 4;
			
			FocusManager.getInstance().addEventListener(ComponentFocusEvent.COMPONENT_FOCUS_IN, componentFocusInHandler);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		override protected function validate():void
		{
			_controlBar.resizeToContent = true;
			super.validate();
			
			iconImage.source = _icon;
			iconImage.validateNow();
			iconImage.y = (_titleBarHeight - iconImage.height) >> 1;
			iconImage.x = iconImage.y;
			
			_controlBar.resizeToContent = false;
			_controlBar.width = _width;
			_controlBar.validateNow();
			_controlBar.y = _height - _controlBar.height;
			
			border.width = _width;
			border.height = _height;
			
			titleField.text = _label;
			titleField.width = _width - (_paddingLeft + _paddingRight);
			titleField.height = Math.min(titleField.textHeight + 4, _height);
			titleField.y = (_titleBarHeight - (titleField.height)) >> 1;
			titleField.x = iconImage.width > 0 ? iconImage.x + iconImage.width + 6 : titleField.y;
			
			closeBtn.x = _width - closeBtn.width;
			closeBtn.y = (_titleBarHeight - closeBtn.height) >> 1;
		}
		
		override protected function getChildrenLayoutArea():Rectangle
		{
			var rect:Rectangle = new Rectangle( _paddingLeft, _paddingTop, _width - (_paddingRight+_paddingLeft), _height - (_paddingBottom+_paddingTop) );
			_controlBar.validateNow();
			rect.top += titleBarHeight;
			rect.bottom -= _controlBar.height;
			return rect;
		}
		
		public function componentFocusInHandler( event:ComponentFocusEvent ):void
		{
			if ( FocusManager.isFocusedItemAChildOf(this) )
			{
				border.gotoAndPlay("Active");
			}
			else
			{
				border.gotoAndPlay("Default");
			}
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function addedToStageHandler( event:Event ):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function removedFromStageHandler( event:Event ):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			if ( _defaultButton == null ) return;
			if ( FocusManager.isFocusedItemAChildOf(this) == false ) return;
			if ( event.keyCode == Keyboard.ENTER )
			{
				_defaultButton.dispatchEvent( new SelectEvent( SelectEvent.SELECT, null, true ) );
			}
		}
		
		private function mouseDownBackgroundHandler( event:MouseEvent ):void
		{
			if ( dragEnabled == false ) return;
			if ( mouseY > _titleBarHeight ) return;
			var ptA:Point = new Point(0, 0);
			ptA = parent.globalToLocal(ptA);
			startDrag(false, new Rectangle(ptA.x, ptA.y, stage.width-_width, stage.height-_height));
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpStageHandler );
		}
		
		private function mouseUpStageHandler( event:MouseEvent ):void
		{
			stopDrag();
		}
		
		private function clickCloseBtnHandler( event:MouseEvent ):void
		{
			event.stopImmediatePropagation();
			dispatchEvent( new Event( Event.CLOSE ) );
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set defaultButton( value:Button ):void
		{
			_defaultButton = value;
		}
		
		public function get defaultButton():Button
		{
			return _defaultButton;
		}
		
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
		
		public function set showCloseButton( value:Boolean ):void
		{
			closeBtn.visible = value;
		}
		
		public function get showCloseButton():Boolean
		{
			return closeBtn.visible;
		}
	}
}