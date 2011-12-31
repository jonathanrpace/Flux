package flux.components 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flux.components.ScrollBarTrackSkin;
	import flux.skins.ScrollBarThumbSkin;
	import flux.skins.ScrollBarUpButtonSkin;
	import flux.skins.ScrollBarDownButtonSkin;
	
	public class ScrollBar extends UIComponent 
	{
		private static const DELAY_TIME		:int = 500;
		private static const REPEAT_TIME	:int = 100;
		
		// Child elements
		protected var track				:Sprite;
		protected var thumb				:PushButton;
		protected var upBtn				:PushButton;
		protected var downBtn			:PushButton;
		
		// Properties
		protected var _value			:Number = 0;
		protected var _max				:Number = 10;
		protected var _thumbSizeRatio	:Number = 0.5;
		protected var _scrollSpeed		:Number = 1;
		protected var _pageScrollSpeed	:Number = 4;
		protected var repeatSpeed		:int;
		protected var dragStartRatio	:Number;
		protected var dragStartValue		:int;
		protected var delayTimer		:Timer;
		protected var repeatTimer		:Timer;
		protected var defaultUpBtnHeight:Number;
		protected var defaultDownBtnHeight:Number;
		
		public function ScrollBar() 
		{
			
		}
		
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
			
			var lineRatio:Number = _value / _max;
			lineRatio = isNaN(lineRatio) ? 0 : lineRatio;
			thumb.y = upBtn.height + (track.height - thumb.height) * lineRatio;
		}
		
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
		}
		
		private function delayCompleteHandler( event:TimerEvent ):void
		{
			repeatTimer.start();
		}
		
		private function repeatHandler( event:TimerEvent ):void
		{
			value += repeatSpeed;
		}
	}

}