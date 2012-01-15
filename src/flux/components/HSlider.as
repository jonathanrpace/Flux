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
	import flux.events.PropertyChangeEvent;
	import flux.skins.SliderTrackSkin;
	import flux.skins.SliderThumbSkin;
	import flux.skins.SliderMarkerSkin;
	
	public class HSlider extends UIComponent 
	{
		// Properties
		private var _value		:Number = 0;
		private var _min		:Number = 0;
		private var _max		:Number = 10;
		private var _stepSize	:Number = 1;
		private var _showMarkers:Boolean = true;
		
		// Child elements
		private var track		:Sprite;
		private var thumb		:Sprite;
		private var markers		:Array;
		
		public function HSlider() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			track = new SliderTrackSkin();
			addChild(track);
			
			_width = track.width;
			_height = track.height;
			
			thumb = new SliderThumbSkin();
			addChild(thumb);
			
			markers = [];
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		override protected function validate():void
		{
			track.width = _width;
			track.height = _height;
			
			var range:Number = (_max - _min);
			thumb.x = int(_width * ((_value-_min) / range));
			
			var numMarkers:int = showMarkers ? range / _stepSize : 0;
			var stepWidth:Number = (_stepSize / range) * _width;
			for ( var i:int = 0; i < numMarkers; i++ )
			{
				var marker:Sprite;
				if ( i >= markers.length )
				{
					marker = markers[i] = new SliderMarkerSkin();
					addChild(marker);
				}
				else
				{
					marker = markers[i];
				}
				marker.x = int((i+1) * stepWidth);
			}
			
			while ( markers.length > numMarkers )
			{
				removeChild(markers.pop());
			}
		}
		
		private function beginDrag():void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		protected function endDrag():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		protected function updateDrag():void
		{
			var ratio:Number = mouseX / _width;
			value = _min + ratio * (_max - _min);
		}
		
		protected function snapToInterval( value:Number, interval:Number ):Number
		{
			var overshoot:Number = value % interval;
			return overshoot < interval*0.5 ? value - overshoot : value + (interval-overshoot);
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
		
		private function removedFromStageHandler( event:Event ):void
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
			if ( stepSize > 0 )
			{
				var ratio:Number = (v-_min) / (_max - _min);
				ratio = ratio < 0 ? 0 : ratio > 1 ? 1 : ratio;
				var stepSizeAsRatio:Number = _stepSize / (_max - _min);
				var numSteps:int = 1 / stepSizeAsRatio;
				var total:Number = (stepSizeAsRatio * numSteps);
				var leftOver:Number = 1 - total;
				if ( ratio > total + leftOver * 0.5 )
				{
					ratio = 1;
				}
				else
				{
					ratio = snapToInterval(ratio, stepSizeAsRatio);
				}
				
				v = _min + (ratio * (_max - _min));
			}
			
			v = v < _min ? _min : v > _max ? _max : v;
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
		
		public function get stepSize():Number 
		{
			return _stepSize;
		}
		
		public function set stepSize(v:Number):void 
		{
			v = v <= 0 ? 0 : v;
			if ( _stepSize == v ) return;
			_stepSize = v;
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