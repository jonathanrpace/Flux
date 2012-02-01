/**
 * HSlider.as
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
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flux.events.ItemEditorEvent;
	import flux.events.PropertyChangeEvent;
	import flux.skins.SliderTrackSkin;
	import flux.skins.SliderThumbSkin;
	import flux.skins.SliderMarkerSkin;
	
	public class HSlider extends UIComponent
	{
		// Properties
		private var _value			:Number = 0;
		private var _min			:Number = 0;
		private var _max			:Number = 10;
		private var _snapInterval	:Number = 1;
		private var _showMarkers	:Boolean = true;
		
		// Child elements
		private var track		:Sprite;
		private var thumb		:Sprite;
		private var markerContainer:Sprite;
		private var markers		:Array;
		private var toolTipComp	:ToolTip;
		
		public function HSlider()
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			focusEnabled = true;
			
			track = new SliderTrackSkin();
			addChild(track);
			
			_width = track.width;
			_height = track.height;
			
			markerContainer = new Sprite();
			addChild(markerContainer);
			
			thumb = new SliderThumbSkin();
			addChild(thumb);
			
			toolTipComp = new ToolTip();
			
			markers = [];
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		override protected function validate():void
		{
			track.width = _width;
			track.height = _height;
			
			var range:Number = (_max - _min);
			thumb.x = int(_width * ((_value-_min) / range));
			
			var numMarkers:int = showMarkers ? range / _snapInterval : 0;
			var stepWidth:Number = (_snapInterval / range) * _width;
			var leftOver:Number = (range % _snapInterval) * stepWidth;
			for ( var i:int = 0; i < numMarkers; i++ )
			{
				var marker:Sprite;
				if ( i >= markers.length )
				{
					marker = markers[i] = new SliderMarkerSkin();
					markerContainer.addChild(marker);
				}
				else
				{
					marker = markers[i];
				}
				marker.x = int(leftOver + i * stepWidth);
			}
			
			while ( markers.length > numMarkers )
			{
				markerContainer.removeChild(markers.pop());
			}
			
			toolTipComp.text = String(int(_value*1000)/1000);
			toolTipComp.validateNow();
			var pt:Point = new Point(thumb.x, thumb.y);
			pt = localToGlobal(pt);
			pt = Application.getInstance().globalToLocal(pt);
			toolTipComp.x = pt.x - (toolTipComp.width>>1);
			toolTipComp.y = pt.y - toolTipComp.height;
		}
		
		private function beginDrag():void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Application.getInstance().toolTipContainer.addChild(toolTipComp);
			invalidate();
		}
		
		protected function endDrag():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			toolTipComp.parent.removeChild(toolTipComp);
		}
		
		protected function updateDrag():void
		{
			var ratio:Number = mouseX / _width;
			value = _min + ratio * (_max - _min);
		}
		
		protected function commitValue():void
		{
			dispatchEvent( new ItemEditorEvent( ItemEditorEvent.COMMIT_VALUE, _value, "value" ) );
		}
		
		override public function onLoseComponentFocus():void
		{
			commitValue();
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function mouseDownHandler( event:MouseEvent ):void
		{
			beginDrag();
			updateDrag();
		}
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			updateDrag();
		}
		
		private function stageMouseUpHandler( event:MouseEvent ):void
		{
			endDrag();
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function get value():Number
		{
			return _value;
		}
		
		public function set value(v:Number):void
		{
			// Snap the value to the interval
			if ( _snapInterval > 0 )
			{
				var a:Number = 1 / _snapInterval;
				v = int(v * a) / a;
				v = v < _min ? _min : v > _max ? _max : v;
			}
			if ( _value == v ) return;
			var oldValue:Number = _value;
			_value = v;
			invalidate();
			dispatchEvent( new Event( Event.CHANGE ) );
			dispatchEvent( new PropertyChangeEvent( "propertyChange_value", oldValue, _value) );
		}
		
		public function get min():Number
		{
			return _min;
		}
		
		public function set min(v:Number):void
		{
			v = v > _max ? _max : v;
			if ( _min == v ) return;
			_min = v;
			value = _value;
		}
		
		public function get max():Number
		{
			return _max;
		}
		
		public function set max(v:Number):void
		{
			v = v < _min ? _min : v;
			if ( _max == v ) return;
			_max = v;
			value = _value;
		}
		
		public function get snapInterval():Number
		{
			return _snapInterval;
		}
		
		public function set snapInterval(v:Number):void
		{
			v = v < 0 ? 0 : v;
			if ( _snapInterval == v ) return;
			_snapInterval = v;
			value = _value;
		}
		
		public function get showMarkers():Boolean
		{
			return _showMarkers;
		}
		
		public function set showMarkers(v:Boolean):void
		{
			if ( _showMarkers == v ) return;
			_showMarkers = v;
			invalidate();
		}
	}
}