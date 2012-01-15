/**
 * Container.as
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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import flux.events.ContainerEvent;
	import flux.layouts.AbsoluteLayout;
	import flux.layouts.ILayout;
	
	[Event( type="flux.events.ContainerEvent", name="childrenChanged" )]
	public class Container extends UIComponent 
	{
		// Properties
		protected var _paddingLeft		:int = 0;
		protected var _paddingRight		:int = 0;
		protected var _paddingTop		:int = 0;
		protected var _paddingBottom	:int = 0;
		protected var _layout			:ILayout;
		
		// Child elements
		protected var content			:Sprite;
		
		public function Container() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Public methods
		////////////////////////////////////////////////
		
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			content.addChildAt(child, index);
			invalidate();
			onChildrenChanged( child, index, true );
			dispatchEvent( new ContainerEvent( ContainerEvent.CHILDREN_CHANGED ) );
			return child;
		}
		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			content.addChild(child);
			invalidate();
			onChildrenChanged( child, content.numChildren - 1, true );
			dispatchEvent( new ContainerEvent( ContainerEvent.CHILDREN_CHANGED ) );
			return child;
		}
		
		public override function removeChildAt(index:int):DisplayObject
		{
			invalidate();
			var child:DisplayObject = content.removeChildAt(index);
			onChildrenChanged( child, index, false );
			dispatchEvent( new ContainerEvent( ContainerEvent.CHILDREN_CHANGED ) );
			return child;
		}
		
		public override function removeChild(child:DisplayObject):DisplayObject
		{
			var index:int = content.getChildIndex(child);
			content.removeChild(child);
			invalidate();
			onChildrenChanged( child, index, false );
			dispatchEvent( new ContainerEvent( ContainerEvent.CHILDREN_CHANGED ) );
			return child;
		}
		
		public override function getChildAt( index:int ):DisplayObject
		{
			return content.getChildAt(index);
		}
		
		public override function getChildIndex( child:DisplayObject ):int
		{
			return content.getChildIndex(child);
		}
		
		public override function get numChildren():int
		{
			return content.numChildren;
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			_layout = new AbsoluteLayout();
			
			_width = 100;
			_height = 100;
			
			content = new Sprite();
			content.scrollRect = new Rectangle();
			addRawChild(content);
			
			content.addEventListener( Event.RESIZE, resizeHandler );
		}
		
		override protected function validate():void
		{
			var layoutArea:Rectangle = getChildrenLayoutArea();
			
			if ( _resizeToContent )
			{
				var contentSize:Rectangle = _layout.layout( content, layoutArea.width, layoutArea.height, false );
				_width = contentSize.width + _paddingLeft + _paddingRight;
				_height = contentSize.height + _paddingTop + _paddingBottom;
				layoutArea.width = contentSize.width;
				layoutArea.height = contentSize.height;
			}
			else
			{
				_layout.layout( content, layoutArea.width, layoutArea.height, true );
			}
			
			content.x = layoutArea.x;
			content.y = layoutArea.y;
			
			var scrollRect:Rectangle = content.scrollRect;
			scrollRect.width = layoutArea.width;
			scrollRect.height = layoutArea.height;
			content.scrollRect = scrollRect;
		}
		
		/**
		 * 'Virtual' method. Can be overriden to provide information when children change.
		 * @param	child The child that has been added/removed from the child list.
		 * @param	index The index of the child.
		 * @param	added If true, the child has just been added, otherwise it's just been removed.
		 */
		protected function onChildrenChanged( child:DisplayObject, index:int, added:Boolean ):void
		{
			// Intentionally blank
		}
		
		/**
		 * By default returns a rectangle the same size as the component, minus padding.
		 * Override this for containers that need something more custom, and needs to take into account other chrome elements.
		 * @return
		 */
		protected function getChildrenLayoutArea():Rectangle
		{
			return new Rectangle( _paddingLeft, _paddingTop, _width - (_paddingRight+_paddingLeft), _height - (_paddingBottom+_paddingTop) );
		}
		
		protected function addRawChild(child:DisplayObject):DisplayObject
		{
			super.addChild(child);
			return child;
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function resizeHandler( event:Event ):void
		{
			if ( event.target.parent == content )
			{
				event.stopImmediatePropagation();
				invalidate();
			}
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set padding( value:int ):void
		{
			_paddingLeft = _paddingRight = _paddingTop = _paddingBottom = value;
			invalidate();
		}
		
		public function get padding():int
		{
			return _paddingLeft;
		}
		
		public function set paddingLeft( value:int ):void
		{
			_paddingLeft = value;
			invalidate();
		}
		
		public function get paddingLeft():int
		{
			return _paddingLeft;
		}
		
		public function set paddingRight( value:int ):void
		{
			_paddingRight = value;
			invalidate();
		}
		
		public function get paddingRight():int
		{
			return _paddingRight;
		}
		
		public function set paddingTop( value:int ):void
		{
			_paddingTop = value;
			invalidate();
		}
		
		public function get paddingTop():int
		{
			return _paddingTop;
		}
		
		public function set paddingBottom( value:int ):void
		{
			_paddingBottom = value;
			invalidate();
		}
		
		public function get paddingBottom():int
		{
			return _paddingBottom;
		}
		
		public function set layout( value:ILayout ):void
		{
			_layout = value;
			if ( _layout )
			{
				invalidate();
			}
		}
		public function get layout():ILayout
		{
			return _layout;
		}
	}
}