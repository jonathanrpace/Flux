/**
 * List.as
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
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flux.data.ArrayCollection;
	import flux.data.DefaultDataDescriptor;
	import flux.data.IDataDescriptor;
	import flux.events.ArrayCollectionChangeKind;
	import flux.events.ArrayCollectionEvent;
	import flux.events.SelectEvent;
	import flux.layouts.VerticalLayout;
	import flux.skins.ListDropIndicatorSkin;
	
	public class List extends Canvas 
	{
		// Properties
		protected var _dataProvider				:ArrayCollection;
		protected var _selectedItems			:Array;
		protected var _allowMultipleSelection	:Boolean = false;
		protected var _dataDescriptor			:IDataDescriptor;
		protected var _autoHideVScrollBar		:Boolean = true;
		protected var _autoHideHScrollBar		:Boolean = true;
		protected var _itemRendererClass		:Class;
		protected var _clickSelect				:Boolean = false;
		
		// Child elements
		protected var vScrollBar				:ScrollBar;
		protected var visibleItemRenderers		:Vector.<IItemRenderer>;
		protected var itemRendererPool			:Vector.<IItemRenderer>;
		protected var dropIndicator				:Sprite;
		
		// Internal vars
		protected var focusedItem				:Object
		protected var flattenedData				:Array;
		protected var visibleData				:Array;
		protected var _itemRendererHeight		:int;
		private var mouseDownDragStart			:Point;
		private var dragOffset					:Point;
		private var draggedItem					:Object;
		private var draggedItemRenderer			:DisplayObject;
		
		public function List() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			super.init();
			
			visibleItemRenderers = new Vector.<IItemRenderer>();
			itemRendererPool = new Vector.<IItemRenderer>();
			_itemRendererClass = ListItemRenderer;
			
			padding = 1;
			_layout = new VerticalLayout(0);
			_dataDescriptor = new DefaultDataDescriptor();
			
			_selectedItems = [];
			
			// Create an item renderer so we can pluck out its height
			var itemRenderer:IItemRenderer = new _itemRendererClass();
			_itemRendererHeight = itemRenderer.height;
			
			vScrollBar = new ScrollBar();
			vScrollBar.scrollSpeed = _itemRendererHeight;
			vScrollBar.pageScrollSpeed = _itemRendererHeight * 4;
			addRawChild(vScrollBar);
			
			dropIndicator = new ListDropIndicatorSkin();
			addRawChild(dropIndicator);
			dropIndicator.visible = false;
			
			_clickSelect = true;
			clickSelect = false;
			content.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownContentHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
		
		override protected function validate():void
		{
			calculateFlattenedData();
			
			if ( _resizeToContent )
			{
				_height = flattenedData.length * _itemRendererHeight + _paddingTop + _paddingBottom ;
			}
			
			calculateVisibleData();
			
			var firstVisibleDataIndex:int = visibleData.length > 0 ? flattenedData.indexOf( visibleData[0] ) : 0;
				
			// First, loop through existing visible item renderers and stick them
			// on the pool if their data is no longer visible.
			var visibleItemRenderersByData:Dictionary = new Dictionary(true);
			while ( visibleItemRenderers.length > 0 )
			{
				var itemRenderer:IItemRenderer = visibleItemRenderers.pop();
				var data:Object = itemRenderer.data;
				if ( visibleData.indexOf( data ) == -1 )
				{
					itemRendererPool.push(itemRenderer);
					itemRenderer.selected = false;
					content.removeChild(DisplayObject(itemRenderer));
				}
				else
				{
					visibleItemRenderersByData[data] = itemRenderer;
				}
			}
			
			for ( var i:int = 0; i < visibleData.length; i++ )
			{
				data = visibleData[i];
				itemRenderer = visibleItemRenderersByData[data];
				
				if ( itemRenderer == null )
				{
					if ( itemRendererPool.length > 0 )
					{
						itemRenderer = itemRendererPool.pop();
					}
					else
					{
						itemRenderer = new _itemRendererClass();
						itemRenderer.list = this;
					}
					itemRenderer.data = data;
					itemRenderer.resizeToContent = _resizeToContent;
					itemRenderer.percentWidth = _resizeToContent ? NaN : 100;
				}
				
				visibleItemRenderers.push(itemRenderer);
				content.addChild( DisplayObject(itemRenderer) );
				itemRenderer.selected = _selectedItems.indexOf(data) != -1;
			}
			
			initVisibleItemRenderers();
			
			if ( _resizeToContent )
			{
				var maxWidth:int = 0;
				for ( i = 0; i < visibleData.length; i++ )
				{
					itemRenderer = visibleItemRenderers[i];
					itemRenderer.validateNow();
					maxWidth = itemRenderer.width > maxWidth ? itemRenderer.width : maxWidth;
				}
				for ( i = 0; i < visibleData.length; i++ )
				{
					itemRenderer = visibleItemRenderers[i];
					itemRenderer.resizeToContent = false;
					itemRenderer.width = maxWidth;
				}
				
				_width = maxWidth + _paddingLeft + _paddingRight;
			}
			
			
			var layoutArea:Rectangle = getChildrenLayoutArea();
			
			if ( _resizeToContent == false )
			{
				vScrollBar.removeEventListener(Event.CHANGE, onChangeVScrollBar );
				vScrollBar.x = _width - vScrollBar.width;
				vScrollBar.height = _height;
				vScrollBar.validateNow();
				vScrollBar.addEventListener(Event.CHANGE, onChangeVScrollBar );
				
				vScrollBar.visible = vScrollBar.thumbSizeRatio < 1;
				if ( vScrollBar.visible ) layoutArea.width -= (vScrollBar.x + vScrollBar.width) - layoutArea.right;
			}
			else
			{
				vScrollBar.visible = false;
			}
			
			content.x = layoutArea.x;
			content.y = layoutArea.y;
			
			var scrollRect:Rectangle = content.scrollRect;
			scrollRect.width = layoutArea.width;
			scrollRect.height = layoutArea.height;
			scrollRect.y = -Math.round( -vScrollBar.value + firstVisibleDataIndex * _itemRendererHeight);
			content.scrollRect = scrollRect;
			
			_layout.layout( content, layoutArea.width, layoutArea.height );
			
			background.width = _width;
			background.height = _height;
		}
		
		protected function initVisibleItemRenderers():void {}
				
		protected function calculateFlattenedData():void
		{
			flattenedData = _dataProvider ? _dataProvider.source : [];
		}
		
		protected function calculateVisibleData():void
		{
			if ( _resizeToContent ) 
			{
				vScrollBar.value = 0;
				visibleData = flattenedData.slice();
				return;
			}
			
			var contentHeight:int = flattenedData.length * _itemRendererHeight;
			var layoutArea:Rectangle = getChildrenLayoutArea();
			vScrollBar.max = contentHeight - layoutArea.height;
			vScrollBar.thumbSizeRatio = layoutArea.height / contentHeight;
			var startIndex:int = Math.floor( vScrollBar.value / _itemRendererHeight );
			var endIndex:int = startIndex + Math.ceil(  layoutArea.height / _itemRendererHeight ) + 1;
			endIndex = endIndex > flattenedData.length ? flattenedData.length : endIndex;
			visibleData = flattenedData.slice( startIndex, endIndex );
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		protected function dataProviderChangeHandler( event:ArrayCollectionEvent ):void
		{
			if ( event.changeKind == ArrayCollectionChangeKind.REFRESH )
			{
				_selectedItems = [];
			}
			else if ( event.changeKind == ArrayCollectionChangeKind.REMOVE )
			{
				var selectedIndex:int = _selectedItems.indexOf(event.item);
				if ( selectedIndex != -1 )
				{
					_selectedItems.splice(selectedIndex, 1);
				}
			}
			invalidate();
		}
		
		private function mouseSelectContentHandler( event:MouseEvent ):void
		{
			// Determine the selected index into the flattedData array
			var firstVisibleDataIndex:int = visibleData.length > 0 ? flattenedData.indexOf( visibleData[0] ) : 0;
			var selectedVisibleIndex:int = (content.mouseY / _itemRendererHeight);
			var index:int = firstVisibleDataIndex + selectedVisibleIndex;
			if ( index < 0 || index >= flattenedData.length ) return;
			
			// The following logic implements the behaviour we expect to see from lists
			// with various combinations of clicking and CTRL and/or SHIFT.
			// I've lifted this directly from Window's native list behaviour.
			if ( _allowMultipleSelection && (event.shiftKey || event.ctrlKey) )
			{
				if ( event.shiftKey )
				{
					// Range select
					var focusedIndex:int = flattenedData.indexOf(focusedItem);
					focusedIndex = focusedIndex == -1 ? 0 : focusedIndex;
					var min:int = Math.min( focusedIndex, index );
					var max:int = Math.max( focusedIndex, index );
					
					var newSelectedItems:Array = [];
					for ( var i:int = min; i <= max; i++ )
					{
						newSelectedItems.push(flattenedData[i]);
					}
					
					// Append the range select
					if ( event.ctrlKey )
					{
						focusedItem = flattenedData[index];
						selectedItems = _selectedItems.concat( newSelectedItems );
					}
					// Replace selection with range
					else
					{
						selectedItems = newSelectedItems;
					}
				}
				else if ( event.ctrlKey )
				{
					// Single click add selected item
					focusedItem = flattenedData[index];
					if ( _selectedItems.indexOf(focusedItem) == -1 )
					{
						_selectedItems.push( focusedItem );
					}
					// Single click 
					else
					{
						_selectedItems.splice(_selectedItems.indexOf(focusedItem), 1);
					}
				}
			}
			else
			{
				focusedItem = flattenedData[index];
				_selectedItems = [focusedItem];
			}
			
			// We use the setter method to ensure the new _selectedItems value is clean of duplicates.
			selectedItems = _selectedItems;
			invalidate();
			
			dispatchEvent( new SelectEvent( SelectEvent.SELECT, flattenedData[index] ) );
		}
		
		private function mouseWheelHandler( event:MouseEvent ):void
		{
			vScrollBar.value += vScrollBar.scrollSpeed * (event.delta < 0 ? 1 : -1);
		}
		
		private function onChangeVScrollBar( event:Event ):void
		{
			invalidate();
		}
		
		private function onChangeHScrollBar( event:Event ):void
		{
			invalidate();
		}
		
		private function mouseDownContentHandler( event:MouseEvent ):void
		{
			mouseDownDragStart = new Point( content.mouseX, content.mouseY );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveDragHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, endDragHandler );
		}
		
		private function mouseMoveDragHandler( event:MouseEvent ):void
		{
			if ( draggedItem == null )
			{
				var dis:int = Math.abs(content.mouseX - mouseDownDragStart.x) + Math.abs(content.mouseY - mouseDownDragStart.y);
				if ( dis > 3 )
				{
					for ( var i:int = 0; i < content.numChildren; i++ )
					{
						var itemRenderer:DisplayObject = content.getChildAt(i);
						if ( itemRenderer.hitTestPoint( stage.mouseX, stage.mouseY ) )
						{
							draggedItem = IItemRenderer(itemRenderer).data;
							dropIndicator.visible = true;
							
							draggedItemRenderer = new itemRendererClass();
							IItemRenderer(draggedItemRenderer).list = this;
							IItemRenderer(draggedItemRenderer).data = draggedItem;
							IItemRenderer(draggedItemRenderer).selected = IItemRenderer(itemRenderer).selected;
							draggedItemRenderer.width = itemRenderer.width;
							draggedItemRenderer.height = itemRenderer.height;
							draggedItemRenderer.alpha = 0.5;
							IItemRenderer(draggedItemRenderer).validateNow();
							
							dragOffset = new Point( itemRenderer.mouseX, itemRenderer.mouseY );
							
							stage.addChild( draggedItemRenderer );
							draggedItemRenderer.x = stage.mouseX - dragOffset.x;
							draggedItemRenderer.y = stage.mouseY - dragOffset.y;
							
							break;
						}
					}
				}
			}
			
			if ( draggedItem != null )
			{
				draggedItemRenderer.x = stage.mouseX - dragOffset.x;
				draggedItemRenderer.y = stage.mouseY - dragOffset.y;
				
				// Calculate drop position
				for ( i = 0; i < content.numChildren; i++ )
				{
					itemRenderer = content.getChildAt(i);
					if ( itemRenderer.hitTestPoint( stage.mouseX, stage.mouseY ) )
					{
						// Before this item
						if ( itemRenderer.mouseY < (itemRenderer.height >> 1) )
						{
							updateDropIndicator( IItemRenderer(itemRenderer), false );
						}
						// After this item
						else
						{
							updateDropIndicator( IItemRenderer(itemRenderer), true );
						}
					}
				}
			}
		}
		
		protected function updateDropIndicator( itemRenderer:IItemRenderer, after:Boolean ):void
		{
			if ( after )
			{
				dropIndicator.x = itemRenderer.x;
				dropIndicator.y = itemRenderer.y + itemRenderer.height;
			}
			else
			{
				dropIndicator.x = itemRenderer.x;
				dropIndicator.y = itemRenderer.y;
			}
			
			dropIndicator.width = itemRenderer.width;
		}
		
		private function endDragHandler( event:MouseEvent ):void
		{
			if ( draggedItemRenderer )
			{
				stage.removeChild( draggedItemRenderer );
				draggedItem = null;
				draggedItemRenderer = null;
			}
			dropIndicator.visible = false;
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveDragHandler );
			stage.removeEventListener( MouseEvent.MOUSE_UP, endDragHandler );
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set dataProvider( value:ArrayCollection ):void
		{
			if ( _dataProvider )
			{
				_dataProvider.removeEventListener( ArrayCollectionEvent.CHANGE, dataProviderChangeHandler );
			}
			_dataProvider = value;
			if ( _dataProvider )
			{
				_dataProvider.addEventListener( ArrayCollectionEvent.CHANGE, dataProviderChangeHandler );
			}
			_selectedItems = [];
			invalidate();
		}
		
		public function get dataProvider():ArrayCollection
		{
			return _dataProvider;
		}
		
		public function set selectedItems( value:Array ):void
		{
			_selectedItems = value.slice();
			
			// Clear the array of duplicates
			var table:Dictionary = new Dictionary(true);
			for ( var i:int = 0; i < _selectedItems.length; i++ )
			{
				var item:Object = _selectedItems[i];
				if ( table[item] )
				{
					_selectedItems.splice(i, 1);
					i--;
				}
				else
				{
					table[item] = true;
				}
			}
			
			dispatchEvent( new Event( Event.CHANGE ) );
			
			invalidate();
		}
		
		public function get selectedItems():Array
		{
			return _selectedItems.slice();
		}
		
		public function get maxScrollY():int 
		{ 
			return vScrollBar.max; 
		}
		
		public function set scrollY( value:int ):void
		{
			vScrollBar.removeEventListener( Event.CHANGE, onChangeVScrollBar );
			vScrollBar.value = value;
			vScrollBar.addEventListener( Event.CHANGE, onChangeVScrollBar );
			invalidate();
		}
		public function get scrollY():int 
		{ 
			return vScrollBar.value; 
		}
		
		public function get itemRendererHeight():int
		{
			return _itemRendererHeight;
		}
		
		public function set dataDescriptor( value:IDataDescriptor ):void
		{
			_dataDescriptor = value;
		}
		public function get dataDescriptor():IDataDescriptor
		{
			return _dataDescriptor;
		}
		
		public function set clickSelect( value:Boolean ):void
		{
			if ( value == _clickSelect ) return;
			
			_clickSelect = value;
			if ( _clickSelect )
			{
				content.addEventListener(MouseEvent.CLICK, mouseSelectContentHandler);
				content.removeEventListener(MouseEvent.MOUSE_DOWN, mouseSelectContentHandler);
			}
			else
			{
				content.removeEventListener(MouseEvent.CLICK, mouseSelectContentHandler);
				content.addEventListener(MouseEvent.MOUSE_DOWN, mouseSelectContentHandler);
			}
		}
		
		public function get clickSelect():Boolean
		{
			return _clickSelect;
		}
		
		public function set allowMultipleSelection( value:Boolean ):void
		{
			if ( value == _allowMultipleSelection ) return;
			_allowMultipleSelection = value;
			if ( !_allowMultipleSelection )
			{
				if ( _selectedItems.length > 1 )
				{
					_selectedItems = [_selectedItems[_selectedItems.length - 1]];
				}
			}
			invalidate();
		}
		
		public function get allowMultipleSelection():Boolean
		{
			return _allowMultipleSelection;
		}
		
		public function set itemRendererClass( value:Class ):void
		{
			if ( value == _itemRendererClass ) return;
			_itemRendererClass = value;
			visibleItemRenderers = new Vector.<IItemRenderer>();
			itemRendererPool = new Vector.<IItemRenderer>();
			while ( content.numChildren > 0 )
			{
				content.removeChildAt(0);
			}
			invalidate();
		}
		
		public function get itemRendererClass():Class
		{
			return _itemRendererClass;
		}
	}
}