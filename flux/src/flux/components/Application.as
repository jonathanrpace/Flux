/**
 * Application.as
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
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flux.managers.CursorManager;
	import flux.managers.FocusManager;
	import flux.managers.PopUpManager;
	import flux.managers.ToolTipManager;
	
	public class Application extends Container
	{
		private static var instance	:Application;
		public static function getInstance():Application
		{
			return instance;
		}
		
		// Properties
		public var focusManager			:FocusManager;
		public var cursorManager		:CursorManager;
		public var toolTipManager		:ToolTipManager;
		public var popUpManager			:PopUpManager;
		
		// Child elements
		private var _popUpContainer		:Sprite;
		private var _toolTipContainer	:Sprite;
		private var disableSheet		:Sprite;
		private var _cursorContainer	:Sprite;
		
		public function Application()
		{
			
		}
		
		override protected function init():void
		{
			if ( instance )
			{
				throw( new Error("Only one instance of Application allowed") );
				return;
			}
			instance = this;
			
			super.init();
			
			_popUpContainer = new Sprite();
			_toolTipContainer = new Sprite();
			disableSheet = new Sprite();
			disableSheet.graphics.beginFill(0, 0);
			disableSheet.graphics.drawRect(0, 0, 10, 10);
			disableSheet.visible = false;
			_cursorContainer = new Sprite();
			addRawChild(_popUpContainer);
			addRawChild(_toolTipContainer);
			addRawChild(disableSheet);
			addRawChild(_cursorContainer);
			
			if ( stage )
			{
				init2();
			}
			else
			{
				addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			}
		}
		
		override protected function validate():void
		{
			super.validate();
			
			disableSheet.width = _width;
			disableSheet.height = _height;
		}
		
		private function addedToStageHandler( event:Event ):void
		{
			if ( event.target != this ) return;
			removeEventListener( Event.ADDED, addedToStageHandler );
			init2();
		}
		
		private function init2():void
		{
			popUpManager = new PopUpManager(this);
			toolTipManager = new ToolTipManager(this);
			cursorManager = new CursorManager(this);
			focusManager = new FocusManager();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener( Event.RESIZE, stageResizeHandler );
			stageResizeHandler();
		}
		
		private function stageResizeHandler( event:Event = null ):void
		{
			if ( event && event.target != stage ) return;
			_width = stage.stageWidth;
			_height = stage.stageHeight;
			invalidate();
			validateNow();
		}
		
		public function get popUpContainer():Sprite
		{
			return _popUpContainer;
		}
		
		public function get toolTipContainer():Sprite
		{
			return _toolTipContainer;
		}
		
		public function get cursorContainer():Sprite
		{
			return _cursorContainer;
		}
		
		override public function set enabled( value:Boolean ):void
		{
			if ( value == _enabled ) return;
			_enabled = value;
			if ( _enabled )
			{
				disableSheet.visible = !_enabled;
				invalidate();
			}
		}
	}
}