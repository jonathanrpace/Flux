/**
 * PopUpManager.as
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

package flux.managers 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class PopUpManager 
	{
		private static var instance		:PopUpManager;
		
		private var stage		:Stage;
		private var container	:Sprite;
		private var modalCover	:Sprite;
		
		private var isModalTable	:Dictionary;
		
		public function PopUpManager( stage:Stage ) 
		{
			if ( instance != null )
			{
				return;
			}
			instance = this;
			
			this.stage = stage;
			stage.addEventListener(Event.RESIZE, resizeStageHandler);
			
			isModalTable = new Dictionary(true);
			container = new Sprite();
			modalCover = new Sprite();
		}
		
		public function addPopUp( popUp:DisplayObject, modal:Boolean = false, center:Boolean = true ):void
		{
			isModalTable[popUp] = modal;
			
			container.addChild(popUp);
			
			if ( container.numChildren == 1 )
			{
				stage.addChild(container);
			}
			
			if ( modal )
			{
				container.addChildAt( modalCover, container.numChildren - 1 );
				updateModalCover();
			}
			
			if ( center )
			{
				popUp.x = (stage.stageWidth - popUp.width) >> 1;
				popUp.y = (stage.stageHeight - popUp.height) >> 1;
			}
		}
		
		public function removePopUp( popUp:DisplayObject ):void
		{
			container.removeChild(popUp);
			delete isModalTable[popUp];
			
			var stillModal:Boolean = false;
			for ( var i:int = 0; i < container.numChildren; i++ )
			{
				var child:DisplayObject = container.getChildAt(i);
				var isModal:Boolean = isModalTable[child];
				if ( isModal )
				{
					stillModal = true;
					container.addChildAt( modalCover, i );
					break;
				}
			}
			
			if ( !isModal && modalCover.stage )
			{
				container.removeChild(modalCover);
			}
		}
		
		private function resizeStageHandler(event:Event):void
		{
			if ( event.target != stage ) return;
			updateModalCover();
		}
		
		private function updateModalCover():void
		{
			if ( modalCover.stage == null ) return;
			modalCover.graphics.clear();
			modalCover.graphics.beginFill(0x000000, 0.4);
			modalCover.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		}
		
		public static function addPopUp( popUp:DisplayObject, modal:Boolean = false, center:Boolean = true ):void
		{
			instance.addPopUp(popUp, modal, center);
		}
		
		public static function removePopUp( popUp:DisplayObject ):void
		{
			instance.removePopUp(popUp);
		}
	}
}