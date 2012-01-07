/**
 * UIComponent.as
 * 
 * Base class for all components
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
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flux.events.PropertyChangeEvent;
	import flux.managers.FocusManager;
	import flux.skins.FocusRectSkin;
	
	[Event( type="flash.events.Event", name="resize" )]
	public class UIComponent extends Sprite
	{
		static private var focusRectSkin	:Sprite;
		static protected var focusManager	:FocusManager;
		
		// Properties
		protected var _width			:Number = 0;
		protected var _height			:Number = 0;
		protected var _percentWidth		:Number;
		protected var _percentHeight	:Number;
		protected var _label			:String = "";
		protected var _icon				:Class;
		protected var _excludeFromLayout:Boolean = false;
		protected var _resizeToContent	:Boolean = false;
		protected var _enabled			:Boolean = true;
		protected var _isInvalid		:Boolean = false;
		protected var _focusEnabled		:Boolean = false;
		protected var _isFocused		:Boolean = false;
		
		public function UIComponent() 
		{
			_init();
		}
		
		private function _init():void
		{
			if ( !focusManager )
			{
				focusRectSkin = new FocusRectSkin();
				focusManager = new FocusManager();
			}
			
			init();
			invalidate();
		}
		
		////////////////////////////////////////////////
		// Public methods
		////////////////////////////////////////////////
		
		public function invalidate():void
		{
			if ( _isInvalid ) return;
			_isInvalid = true;
			addEventListener( Event.ENTER_FRAME, onInvalidateHandler );
		}
		
		public function isInvalid():Boolean
		{
			return _isInvalid;
		}
		
		public function validateNow():void
		{
			if ( _isInvalid == false ) return;
			validate();
			
			if ( _isFocused )
			{
				focusRectSkin.width = _width;
				focusRectSkin.height = _height;
			}
			_isInvalid = false;
			removeEventListener( Event.ENTER_FRAME, onInvalidateHandler );
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		/**
		 * Override this method to perform one-time init logic, such as creating children.
		 */
		protected function init():void { }
		
		/**
		 * Override this method to do any work required to validate the component.
		 */
		protected function validate():void { }
		
		////////////////////////////////////////////////
		// Event Handlers
		////////////////////////////////////////////////
		
		private function onInvalidateHandler( event:Event ):void
		{
			validateNow();
		}
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		override public function set width( value:Number ):void
		{
			value = Math.round(value < 0 ? 0 : value);
			if ( value == _width ) return;
			_width = value;
			invalidate();
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		override public function get width():Number
		{ 
			return _width; 
		}
		
		override public function set height( value:Number ):void
		{
			value = Math.round(value < 0 ? 0 : value);
			if ( value == _height ) return;
			_height = value;
			invalidate();
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		public function set percentWidth( value:Number ):void
		{
			if ( isNaN( value ) )
			{
				_percentWidth = NaN;
			}
			else
			{
				_percentWidth = value < 0 ? 0 : value;
			}
			invalidate();
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		public function get percentWidth():Number
		{ 
			return _percentWidth; 
		}
		
		public function set percentHeight( value:Number ):void
		{
			if ( isNaN( value ) )
			{
				_percentHeight = NaN;
			}
			else
			{
				_percentHeight = value < 0 ? 0 : value;
			}
			invalidate();
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		public function get percentHeight():Number
		{ 
			return _percentHeight; 
		}
		
		override public function set x(value:Number):void
		{
			value = Math.round(value);
			if ( value == x ) return;
			super.x = value;
		}
		
		override public function set y(value:Number):void
		{
			value = Math.round(value);
			if ( value == y ) return;
			super.y = value;
		}
		
		public function set label( value:String ):void
		{
			if ( _label == value ) return;
			var oldValue:String = _label;
			_label = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_label", oldValue, value ) );
		}
		
		public function get label():String
		{
			return _label;
		}
		
		public function set icon( value:Class ):void
		{
			if ( _icon == value ) return;
			var oldValue:Class = _icon;
			_icon = value;
			invalidate();
			dispatchEvent( new PropertyChangeEvent( "propertyChange_icon", oldValue, value ) );
		}
		
		public function get icon():Class
		{
			return _icon;
		}
		
		public function set enabled( value:Boolean ):void
		{
			if ( value == _enabled ) return;
			_enabled = value;
			mouseEnabled = value;
			mouseChildren = value;
			alpha = value ? 1 : 0.5;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set resizeToContent( value:Boolean ):void
		{
			if ( value == _resizeToContent ) return;
			_resizeToContent = value;
			invalidate();
		}
		
		public function get resizeToContent():Boolean
		{
			return _resizeToContent;
		}
		
		public function set excludeFromLayout( value:Boolean ):void
		{
			if ( value == _excludeFromLayout ) return;
			_excludeFromLayout = value;
			dispatchEvent( new Event( Event.RESIZE, true ) );
		}
		
		public function get excludeFromLayout():Boolean
		{
			return _excludeFromLayout;
		}
		
		public function set focusEnabled(value:Boolean):void 
		{
			if ( _focusEnabled == value ) return;
			_focusEnabled = value;
		}
		
		public function get focusEnabled():Boolean 
		{
			return _focusEnabled;
		}
		
		
		flux_internal function set isFocused( value:Boolean ):void
		{
			_isFocused = value;
			if ( _isFocused )
			{
				super.addChild(focusRectSkin);
			}
			invalidate();
		}
		
		flux_internal function get isFocused():Boolean
		{
			return _isFocused;
		}
	}
}