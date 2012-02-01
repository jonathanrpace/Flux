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
	
	import flux.components.Application;
	import flux.components.UIComponent;
	
	public class PopUpManager
	{
		private static var instance		:PopUpManager;
		
		private var app			:Application;
		private var modalCover	:Sprite;
		
		private var isModalTable	:Dictionary;
		
		public function PopUpManager( app:Application )
		{
			if ( instance ) return;
			instance = this;
			
			this.app = app;
			app.stage.addEventListener(Event.RESIZE, resizeStageHandler);
			
			isModalTable = new Dictionary(true);
			modalCover = new Sprite();
		}
		
		public function addPopUp( popUp:DisplayObject, modal:Boolean = false, center:Boolean = true ):void
		{
			isModalTable[popUp] = modal;
			
			app.popUpContainer.addChild(popUp);
			
			if ( modal )
			{
				if ( modalCover.parent )
				{
					modalCover.parent.removeChild(modalCover);
				}
				app.popUpContainer.addChildAt( modalCover, app.popUpContainer.getChildIndex(popUp) );
				updateModalCover();
				if ( popUp is UIComponent && UIComponent(popUp).focusEnabled )
				{
					FocusManager.setFocus(UIComponent(popUp));
				}
			}
			
			if ( center )
			{
				popUp.x = (app.stage.stageWidth - popUp.width) >> 1;
				popUp.y = (app.stage.stageHeight - popUp.height) >> 1;
			}
		}
		
		public function removePopUp( popUp:DisplayObject ):void
		{
			app.popUpContainer.removeChild(popUp);
			delete isModalTable[popUp];
			
			var stillModal:Boolean = false;
			for ( var i:int = 0; i < app.popUpContainer.numChildren; i++ )
			{
				var child:DisplayObject = app.popUpContainer.getChildAt(i);
				var isModal:Boolean = isModalTable[child];
				if ( isModal )
				{
					stillModal = true;
					app.popUpContainer.addChildAt( modalCover, i );
					break;
				}
			}
			
			if ( !isModal && modalCover.stage )
			{
				app.popUpContainer.removeChild(modalCover);
			}
		}
		
		private function resizeStageHandler(event:Event):void
		{
			if ( event.target != app.stage ) return;
			updateModalCover();
		}
		
		private function updateModalCover():void
		{
			if ( modalCover.stage == null ) return;
			modalCover.graphics.clear();
			modalCover.graphics.beginFill(0x000000, 0.4);
			modalCover.graphics.drawRect(0, 0, app.stage.stageWidth, app.stage.stageHeight);
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