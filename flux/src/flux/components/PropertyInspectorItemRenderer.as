/**
 * PropertyInspectorItemRenderer.as
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
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flux.data.PropertyInspectorField;
	import flux.events.PropertyChangeEvent;
	import flux.skins.PropertyInspectorItemRendererSkin;
	import flux.skins.PropertyInspectorItemRendererHeaderSkin;
	
	public class PropertyInspectorItemRenderer extends UIComponent implements IItemRenderer
	{
		// Properties
		private var _data				:Object;
		private var _over				:Boolean = false;
		private var _down				:Boolean = false;
		private var _selected			:Boolean = false;
		
		// Child elements
		protected var skin				:MovieClip;
		protected var headerSkin		:Sprite;
		protected var propertyLabelField:TextField;
		protected var valueLabelField	:TextField;
		
		// Internal vars
		private var _list				:List;
		
		public function PropertyInspectorItemRenderer( )
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			skin = new PropertyInspectorItemRendererSkin();
			_width = skin.width;
			_height = skin.height;
			skin.mouseEnabled = false;
			addChild( skin );
			
			headerSkin = new PropertyInspectorItemRendererHeaderSkin();
			addChild( headerSkin );
			
			propertyLabelField = TextStyles.createTextField();
			addChild( propertyLabelField );
			
			valueLabelField = TextStyles.createTextField();
			addChild( valueLabelField );
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		override protected function validate():void
		{
			var tf:TextFormat = propertyLabelField.defaultTextFormat;
			if ( _data is PropertyInspectorField )
			{
				var field:PropertyInspectorField = PropertyInspectorField(_data);
				
				propertyLabelField.text = field.property;
				
				propertyLabelField.width = (_width * 0.4) - (propertyLabelField.x + 4);
				tf.bold = false;
				propertyLabelField.setTextFormat(tf);
				
				valueLabelField.text = field.valueLabel;
				valueLabelField.x = int(propertyLabelField.x + propertyLabelField.width + 4);
				valueLabelField.y = propertyLabelField.y;
				valueLabelField.height = propertyLabelField.height;
				valueLabelField.width = _width - (valueLabelField.x + 4);
				
				headerSkin.visible = false;
			}
			else if ( _data != null )
			{
				propertyLabelField.width = _width - 8;
				propertyLabelField.text = _data.label;
				tf.bold = true;
				propertyLabelField.setTextFormat(tf);
				
				valueLabelField.text = "";
				
				headerSkin.visible = true;
			}
			
			propertyLabelField.x = 4;
			propertyLabelField.height = Math.min(propertyLabelField.textHeight + 4, _height);
			propertyLabelField.y = (_height - (propertyLabelField.height)) >> 1;
			
			
			skin.width = headerSkin.width = _width;
			skin.height = headerSkin.height = _height;
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
			
			if ( _data )
			{
				unbindHosts();
			}
		}
		
		protected function addedToStageHandler( event:Event ):void
		{
			if ( _data )
			{
				bindHosts();
			}
		}
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			if ( event.target != this ) return;
			_over = true;
			
			_selected ?
			(_down ? skin.gotoAndPlay( "SelectedDown" ) 	: skin.gotoAndPlay("SelectedOver")) :
			(_down ? skin.gotoAndPlay( "Down" ) 			: skin.gotoAndPlay("Over"))
				
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		protected function rollOutHandler(event:MouseEvent):void
		{
			if ( event.target != this ) return;
			_over = false;
			_selected ? skin.gotoAndPlay( "SelectedUp" ) : skin.gotoAndPlay( "Up" );
			removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		protected function mouseDownHandler(event:MouseEvent):void
		{
			if ( event.target != this ) return;
			_down = true;
			_selected ? skin.gotoAndPlay( "SelectedDown" ) : skin.gotoAndPlay( "Down" );
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}

		protected function mouseUpHandler(event:MouseEvent):void
		{
			_down = false;
			
			_selected ?
			(_over ? skin.gotoAndPlay( "SelectedOver" ) 	: skin.gotoAndPlay("SelectedUp")) :
			(_over ? skin.gotoAndPlay( "Over" ) 			: skin.gotoAndPlay("Up"))
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function hostPropertyChangeHandler( event:PropertyChangeEvent ):void
		{
			invalidate();
		}
		
		////////////////////////////////////////////////
		// Private methods
		////////////////////////////////////////////////
		
		private function bindHosts():void
		{
			if ( _data == null ) return;
			if ( _data is PropertyInspectorField == false ) return;
			var field:PropertyInspectorField = PropertyInspectorField(_data);
			if ( field.host is IEventDispatcher == false ) return;
			IEventDispatcher(field.host).addEventListener( "propertyChange_" + field.property, hostPropertyChangeHandler);
		}
		
		private function unbindHosts():void
		{
			if ( _data == null ) return;
			if ( _data is PropertyInspectorField == false ) return;
			var field:PropertyInspectorField = PropertyInspectorField(_data);
			if ( field.host is IEventDispatcher == false ) return;
			IEventDispatcher(field.host).removeEventListener( "propertyChange_" + field.property, hostPropertyChangeHandler);
		}
		
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set data( value:Object ):void
		{
			unbindHosts();
			_data = value;
			bindHosts();
			invalidate();
		}
		
		public function get data():Object
		{
			return _data;
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
			
		}
		public function get selected():Boolean
		{
			return _selected;
		}

		public function get over():Boolean
		{
			return _over;
		}
		
		public function get down():Boolean
		{
			return _down;
		}
		
		public function get list():List
		{
			return _list;
		}
		
		public function set list(value:List):void
		{
			_list = value;
		}
		
		public function get editorRect():Rectangle
		{
			validateNow();
			return new Rectangle( valueLabelField.x, 0, valueLabelField.width+4, _height);
		}
	}
}