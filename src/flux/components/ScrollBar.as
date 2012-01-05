/**
 * ScrollBar.as
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
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flux.skins.ScrollBarTrackSkin;
	import flux.skins.ScrollBarThumbSkin;
	import flux.skins.ScrollBarUpButtonSkin;
	import flux.skins.ScrollBarDownButtonSkin;
	
	public class ScrollBar extends UIComponent 
	{
		private static const DELAY_TIME		:int = 500;
		private static const REPEAT_TIME	:int = 100;
		
		// Properties
		private var _value					:Number = 0;
		private var _max					:Number = 10;
		private var _thumbSizeRatio			:Number = 0.5;
		private var _scrollSpeed			:Number = 1;
		private var _pageScrollSpeed		:Number = 4;
		
		// Child elements
		private var track					:Sprite;
		private var thumb					:PushButton;
		private var upBtn					:PushButton;
		private var downBtn					:PushButton;
		
		// Internal vars
		private var repeatSpeed				:int;
		private var dragStartRatio			:Number;
		private var dragStartValue			:int;
		private var delayTimer				:Timer;
		private var repeatTimer				:Timer;
		private var defaultUpBtnHeight		:Number;
		private var defaultDownBtnHeight	:Number;
		
		public function ScrollBar() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			track = new ScrollBarTrackSkin();
			addChild( track );
			_width = track.width;
			_height = track.height;
			track.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownTrackHandler);
			
			thumb = new PushButton( ScrollBarThumbSkin );
			thumb.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownThumbHandler);
			addChild( thumb );
			
			upBtn = new PushButton( ScrollBarUpButtonSkin );
			defaultUpBtnHeight = upBtn.height;
			addChild( upBtn );
			
			downBtn = new PushButton( ScrollBarDownButtonSkin );
			defaultDownBtnHeight = downBtn.height;
			addChild( downBtn );
			
			upBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownBtnHandler);
			upBtn.addEventListener(MouseEvent.ROLL_OUT, endScrollRepeatHandler);
			downBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownBtnHandler);
			downBtn.addEventListener(MouseEvent.ROLL_OUT, endScrollRepeatHandler);
			
			delayTimer = new Timer( DELAY_TIME, 1 );
			delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, delayCompleteHandler);
			repeatTimer = new Timer( REPEAT_TIME, 0 );
			repeatTimer.addEventListener(TimerEvent.TIMER, repeatHandler);
		}
		
		override protected function validate():void
		{
			if ( _height < defaultUpBtnHeight + defaultDownBtnHeight )
			{
				var ratio:Number = _height / (defaultUpBtnHeight + defaultDownBtnHeight);
				upBtn.height = defaultUpBtnHeight * ratio;
				downBtn.height = _height - upBtn.height;
			}
			else
			{
				upBtn.height = defaultUpBtnHeight;
				downBtn.height = defaultDownBtnHeight;
			}
			track.y = upBtn.height;
			track.height = _height - (upBtn.height + downBtn.height);
			
			downBtn.y = track.y + track.height;
			
			thumb.height = track.height * _thumbSizeRatio;
			thumb.validateNow();
			
			var lineRatio:Number = _value / _max;
			lineRatio = isNaN(lineRatio) ? 0 : lineRatio;
			thumb.y = upBtn.height + (track.height - thumb.height) * lineRatio;
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function mouseDownBtnHandler( event:MouseEvent ):void
		{
			repeatSpeed = event.target == upBtn ? -_scrollSpeed : _scrollSpeed;
			value += repeatSpeed;
			delayTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, endScrollRepeatHandler);
		}
		
		private function mouseDownTrackHandler( event:MouseEvent ):void
		{
			repeatSpeed = mouseY <  thumb.y ? -_pageScrollSpeed : _pageScrollSpeed;
			value += repeatSpeed;
			delayTimer.start();
			track.addEventListener(MouseEvent.ROLL_OUT, endScrollRepeatHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, endScrollRepeatHandler);
		}
		
		private function endScrollRepeatHandler( event:MouseEvent ):void
		{
			track.removeEventListener(MouseEvent.ROLL_OUT, endScrollRepeatHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endScrollRepeatHandler);
			delayTimer.stop();
			repeatTimer.stop();
		}
		
		private function mouseDownThumbHandler( event:MouseEvent ):void 
		{
			dragStartValue = _value;
			dragStartRatio = (mouseY - track.y) / (track.height - thumb.height);
			dragStartRatio = isNaN(dragStartRatio) || dragStartRatio == Infinity || dragStartRatio == -Infinity ? 0 : dragStartRatio;
			stage.addEventListener(MouseEvent.MOUSE_UP, endThumbDragHandler);
			stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
		}
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			var currentDragRatio:Number = (mouseY - track.y) / (track.height - thumb.height);
			currentDragRatio = isNaN(currentDragRatio) || currentDragRatio == Infinity || currentDragRatio == -Infinity ? 0 : currentDragRatio;
			var ratioOffset:Number = currentDragRatio - dragStartRatio;
			value = dragStartValue + ratioOffset * _max;
		}
		
		private function endThumbDragHandler( event:MouseEvent ):void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			stage.removeEventListener(MouseEvent.MOUSE_UP, endScrollRepeatHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endThumbDragHandler);
		}
		
		private function delayCompleteHandler( event:TimerEvent ):void
		{
			repeatTimer.start();
		}
		
		private function repeatHandler( event:TimerEvent ):void
		{
			value += repeatSpeed;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set value( v:Number ):void
		{
			v = v < 0 ? 0 : v > _max ? _max : v;
			if ( v == _value ) return;
			_value = v;
			invalidate();
			dispatchEvent( new Event( Event.CHANGE, true ) );
		}
		
		public function get value():Number
		{
			return _value;
		}
		
		public function set max( v:Number ):void
		{
			v = v < 0 ? 0 : v;
			if ( v == _max ) return;
			_max = v;
			if ( _value > _max )
			{
				_value = _max;
			}
			invalidate();
		}
		
		public function get max():Number
		{
			return _max
		}
		
		public function set thumbSizeRatio( v:Number ):void
		{
			v = v < 0 ? 0 : v > 1 ? 1 : v;
			if ( v == _thumbSizeRatio ) return;
			_thumbSizeRatio = v;
			invalidate();
		}
		
		public function get thumbSizeRatio():Number
		{
			return _thumbSizeRatio;
		}
		
		public function set scrollSpeed( v:Number ):void
		{
			if ( v < 0 ) return;
			_scrollSpeed = v;
		}
		
		public function get scrollSpeed():Number
		{
			return _scrollSpeed;
		}
		
		public function set pageScrollSpeed( v:Number ):void
		{
			if ( v < 0 ) return;
			_pageScrollSpeed = v;
		}
		
		public function get pageScrollSpeed():Number
		{
			return _pageScrollSpeed;
		}
	}

}