/**
 * TreeItemRenderer.as
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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flux.skins.TreeItemRendererOpenIconSkin;
	
	public class TreeItemRenderer extends ListItemRenderer implements ITreeItemRenderer
	{
		// Properties
		protected var _depth		:int = 0;
		protected var _opened		:Boolean = false;
		
		// Child elements
		protected var openIcon	:MovieClip;
		
		public function TreeItemRenderer()
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			super.init();
			
			openIcon = new TreeItemRendererOpenIconSkin();
			addChild(openIcon);
			
			openIcon.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOpenIconHandler);
		}
		
		override protected function validate():void
		{
			super.validate();
			
			var offsetLeft:int = _depth * 16;
			
			openIcon.x = offsetLeft;
			openIcon.y = Math.round((_height - openIcon.height) * 0.5);
			openIcon.visible = _list && _data && _list.dataDescriptor.hasChildren(_data);
			
			iconImage.x = openIcon.x + openIcon.width + 2;
			labelField.x = iconImage.x + iconImage.width + 4;
			labelField.width = _width - labelField.x;
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function mouseDownOpenIconHandler( event:MouseEvent ):void
		{
			opened = !_opened;
			dispatchEvent( new Event( Event.CHANGE, true, false ) );
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set opened( value:Boolean ):void
		{
			if ( value == _opened ) return;
			_opened = value;
			_opened ? openIcon.gotoAndPlay( "Opened" ) : openIcon.gotoAndPlay("Closed");
			invalidate();
		}
		
		public function get opened():Boolean
		{
			return _opened;
		}
		
		public function set depth( value:int ):void
		{
			if ( _depth == value ) return;
			_depth = value;
			invalidate();
		}
		
		public function get depth():int
		{
			return _depth;
		}
	}
}