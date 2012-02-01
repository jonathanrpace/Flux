/**
 * Button.as
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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	import flash.ui.Keyboard;
	import flux.events.PropertyChangeEvent;
	import flux.events.SelectEvent;
	import flux.managers.FocusManager;
	import flux.skins.ButtonSkin;
	
	[Event( type = "flash.events.Event", name = "change" )]
	[Event( type = "flux.events.SelectEvent", name = "select" )]
	public class Button extends UIComponent
	{
		// Properties
		protected var _over				:Boolean = false;
		protected var _down				:Boolean = false;
		protected var _selected			:Boolean = false;
		protected var _toggle			:Boolean = false;
		protected var _labelAlign		:String = TextFormatAlign.CENTER;
		public    var selectMode		:String = ButtonSelectMode.CLICK;
		public    var userData			:*;
		
		// Child elements
		protected var skin				:MovieClip;
		protected var iconImage			:Image;
		protected var labelField		:TextField;
		
		// Internal vars
		protected var skinClass			:Class;
		
		public function Button( skinClass:Class = null )
		{
			this.skinClass = skinClass;
			super();
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			focusEnabled = true;
			
			skin = skinClass == null ? new ButtonSkin() : new skinClass();
			_width = skin.width;
			_height = skin.height;
			skin.mouseEnabled = false;
			addChild( skin );
			
			labelField = TextStyles.createTextField();
			addChild( labelField );
			
			iconImage = new Image();
			iconImage.mouseEnabled = false;
			iconImage.mouseChildren = false;
			addChild(iconImage);
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		override protected function validate():void
		{
			iconImage.validateNow();
			if ( labelField.text == "" )
			{
				iconImage.x = (_width - iconImage.width) >> 1;
			}
			else
			{
				iconImage.x = 6;
			}
			iconImage.y = (_height - iconImage.height) >> 1;
			
			labelField.x = iconImage.source == null ? 4 : iconImage.x + iconImage.width + 4;
			labelField.height = Math.min(labelField.textHeight + 4, _height);
			labelField.y = (_height - (labelField.height)) >> 1;
			
			var tf:TextFormat = labelField.defaultTextFormat;
			tf.align = _labelAlign;
			if ( _resizeToContentWidth )
			{
				tf.align = TextFormatAlign.LEFT;
				labelField.autoSize = TextFieldAutoSize.LEFT;
				_width = labelField.x + labelField.width + 4;
			}
			else
			{
				labelField.autoSize = TextFieldAutoSize.NONE;
				labelField.width = _width - (labelField.x + 4);
				
				// Special case for CENTER alignment. Manually center textfield rather than using
				// TextFormat.align = CENTER to avoid text aliasing.
				if ( _labelAlign == TextFormatAlign.CENTER )
				{
					tf.align = TextFormatAlign.LEFT;
					var newX:int = ((_width - labelField.x) - labelField.textWidth) >> 1;
					labelField.x = newX > labelField.x ? newX : labelField.x;
				}
			}
			
			labelField.defaultTextFormat = tf;
			labelField.setTextFormat(tf);
			
			skin.width = _width;
			skin.height = _height;
			
			if ( (_down && _over) || _selected )
			{
				labelField.y += 1;
				iconImage.y += 1;
			}
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		protected function removedFromStageHandler( event:Event ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_over = false;
			_down = false;
			_selected ? skin.gotoAndPlay( "SelectedUp" ) : skin.gotoAndPlay( "Up" );
		}
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			if ( event.target != this ) return;
			_over = true;
			
			_selected ?
			(_down ? skin.gotoAndPlay( "SelectedDown" ) 	: skin.gotoAndPlay("SelectedOver")) :
			(_down ? skin.gotoAndPlay( "Down" ) 			: skin.gotoAndPlay("Over"))
				
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			invalidate();
		}

		protected function rollOutHandler(event:MouseEvent):void
		{
			if ( event.target != this ) return;
			_over = false;
			_selected ? skin.gotoAndPlay( "SelectedUp" ) : skin.gotoAndPlay( "Up" );
			removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			invalidate();
		}

		protected function mouseDownHandler(event:MouseEvent):void
		{
			if ( event.target != this ) return;
			_down = true;
			
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			if ( selectMode == ButtonSelectMode.MOUSE_DOWN )
			{
				if ( toggle )
				{
					selected = !_selected;
					if ( _selected )
					{
						dispatchEvent( new SelectEvent( SelectEvent.SELECT, null, true ) );
					}
				}
				else
				{
					dispatchEvent( new SelectEvent( SelectEvent.SELECT, null, true ) );
				}
				
			}
			
			_selected ? skin.gotoAndPlay( "SelectedDown" ) : skin.gotoAndPlay( "Down" );
			invalidate();
		}

		protected function mouseUpHandler(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			if ( selectMode == ButtonSelectMode.CLICK )
			{
				if ( toggle && _over )
				{
					selected = !_selected;
					if ( _selected )
					{
						dispatchEvent( new SelectEvent( SelectEvent.SELECT, null, true ) );
					}
				}
				else if (_over)
				{
					dispatchEvent( new SelectEvent( SelectEvent.SELECT, null, true ) );
				}
			}
			_down = false;
			
			_selected ?
			(_over ? skin.gotoAndPlay( "SelectedOver" ) 	: skin.gotoAndPlay("SelectedUp")) :
			(_over ? skin.gotoAndPlay( "Over" ) 			: skin.gotoAndPlay("Up"))
			invalidate();
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		override public function set label(str:String):void
		{
			_label = str;
			labelField.text = _label ? _label : "";
			if ( _resizeToContentWidth )
			{
				invalidate();
			}
		}
		
		override public function set icon( value:Class ):void
		{
			if ( _icon == value ) return;
			_icon = value;
			iconImage.source = value;
			invalidate();
		}

		public function set selected(value:Boolean):void
		{
			if ( _selected == value ) return;
			var oldValue:Boolean = _selected;
			_selected = value;
			
			var event:Event = new Event( Event.CHANGE, false, true );
			dispatchEvent( event );
			
			if ( event.isDefaultPrevented() )
			{
				_selected = oldValue;
				return;
			}
			
			_selected ? skin.gotoAndPlay( "SelectedUp" ) : skin.gotoAndPlay( "Up" );
			dispatchEvent( new PropertyChangeEvent( "propertyChange_selected", oldValue, _selected ) );
			invalidate();
		}
		public function get selected():Boolean
		{
			return _selected;
		}

		public function set toggle(value:Boolean):void
		{
			_toggle = value;
		}
		public function get toggle():Boolean
		{
			return _toggle;
		}
		
		public function get over():Boolean
		{
			return _over;
		}
		
		public function get down():Boolean
		{
			return _down;
		}
		
		public function set labelAlign( v:String ):void
		{
			if ( _labelAlign == v ) return;
			_labelAlign = v;
			invalidate();
		}
		
		public function get labelAlign():String
		{
			return _labelAlign;
		}
	}
}