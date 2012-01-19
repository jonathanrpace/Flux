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
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flux.events.ListEvent;
	
	import flux.data.ArrayCollection;
	import flux.data.DefaultDataDescriptor;
	import flux.data.IDataDescriptor;
	import flux.events.ArrayCollectionChangeKind;
	import flux.events.ArrayCollectionEvent;
	import flux.events.DragAndDropEvent;
	import flux.events.ScrollEvent;
	import flux.events.SelectEvent;
	import flux.layouts.VerticalLayout;
	import flux.managers.FocusManager;
	import flux.skins.ListDropIndicatorSkin;
	import flux.skins.ListSkin;
	
	[Event( type = "flash.events.Event", name = "change" )]
	[Event( type = "flux.events.SelectEvent", name = "select" )]
	[Event( type = "flux.events.ScrollEvent", name = "scrollChange" )]
	[Event( type = "flux.events.DragAndDropEvent", name = "drop" )]
	[Event( type = "flux.events.ListEvent", name = "itemRollOver" )]
	[Event( type = "flux.events.ListEvent", name = "itemRollOut" )]
	
	public class List extends UIComponent
	{
		// Properties
		protected var _dataProvider				:Object;;
		protected var _selectedItems			:Array;
		protected var _allowMultipleSelection	:Boolean = false;
		protected var _dataDescriptor			:IDataDescriptor;
		protected var _filterFunction			:Function;
		protected var _autoHideVScrollBar		:Boolean = true;
		protected var _autoHideHScrollBar		:Boolean = true;
		protected var _itemRendererClass		:Class;
		protected var _clickSelect				:Boolean = false;
		protected var _allowDragAndDrop			:Boolean = false;
		protected var _padding					:int = 4;
		
		// Child elements
		protected var background				:Sprite;
		protected var content					:Sprite;
		protected var vScrollBar				:ScrollBar;
		protected var visibleItemRenderers		:Vector.<IItemRenderer>;
		protected var itemRendererPool			:Vector.<IItemRenderer>;
		protected var dropIndicator				:Sprite;
		
		// Internal vars
		protected var focusedItem				:Object
		protected var flattenedData				:Array;
		protected var visibleData				:Array;
		protected var _itemRendererHeight		:int;
		protected var dropTargetCollection		:ArrayCollection;
		protected var dropTargetIndex			:int;
		protected var draggedItemRenderer		:DisplayObject;
		private var mouseDownDragStart			:Point;
		
		public function List()
		{
			
		}
		
		////////////////////////////////////////////////
		// Public methods
		////////////////////////////////////////////////
		
		public function scrollToItem( item:Object ):void
		{
			validateNow();
			var index:int = flattenedData.indexOf(item);
			if ( index == -1 ) return;
			vScrollBar.value = index * _itemRendererHeight;
		}
		
		public function getItemRendererForData( data:Object ):IItemRenderer
		{
			for each ( var itemRenderer:IItemRenderer in visibleItemRenderers )
			{
				if ( itemRenderer.data == data ) return itemRenderer;
			}
			return null;
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			doubleClickEnabled = true;
			
			background = new ListSkin();
			addChild(background);
			
			content = new Sprite();
			content.scrollRect = new Rectangle();
			content.addEventListener(MouseEvent.MOUSE_OVER, rollOverContentHandler);
			content.addEventListener(MouseEvent.MOUSE_OUT, rollOutContentHandler);
			addChild(content);
			
			focusEnabled = true;
			
			visibleItemRenderers = new Vector.<IItemRenderer>();
			itemRendererPool = new Vector.<IItemRenderer>();
			_itemRendererClass = ListItemRenderer;
			
			_dataDescriptor = new DefaultDataDescriptor();
			
			_selectedItems = [];
			
			// Create an item renderer so we can pluck out its height
			var itemRenderer:IItemRenderer = new _itemRendererClass();
			_itemRendererHeight = UIComponent(itemRenderer).height;
			
			vScrollBar = new ScrollBar();
			vScrollBar.scrollSpeed = _itemRendererHeight;
			vScrollBar.pageScrollSpeed = _itemRendererHeight * 4;
			addChild(vScrollBar);
			
			dropIndicator = new ListDropIndicatorSkin();
			addChild(dropIndicator);
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
				_height = flattenedData.length * _itemRendererHeight + _padding * 2;
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
					visibleItemRenderersByData[data] = itemRenderer;
					itemRenderer.data = data;
					itemRenderer.resizeToContent = _resizeToContent;
					itemRenderer.percentWidth = _resizeToContent ? NaN : 100;
					
				}
				
				visibleItemRenderers.push(itemRenderer);
				content.addChild( DisplayObject(itemRenderer) );
				itemRenderer.selected = _selectedItems.indexOf(data) != -1;
			}
			
			initVisibleItemRenderers();
			
			var layoutArea:Rectangle = getChildrenLayoutArea();
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
				}
				
				_width = maxWidth + _padding * 2;
				layoutArea.width = maxWidth;
			}
			
			if ( _resizeToContent == false )
			{
				vScrollBar.removeEventListener(Event.CHANGE, onChangeVScrollBar );
				vScrollBar.x = _width - vScrollBar.width;
				vScrollBar.height = _height;
				vScrollBar.validateNow();
				vScrollBar.addEventListener(Event.CHANGE, onChangeVScrollBar );
				
				vScrollBar.visible = vScrollBar.thumbSizeRatio < 1;
				if ( vScrollBar.visible ) layoutArea.right = vScrollBar.x + _padding;
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
			
			// Finally, layout the item renderers
			for ( i = 0; i < visibleItemRenderers.length; i++ )
			{
				itemRenderer = visibleItemRenderers[i];
				itemRenderer.y = i * _itemRendererHeight;
				itemRenderer.width = layoutArea.width;
				itemRenderer.validateNow();
			}
			
			background.width = _width;
			background.height = _height;
		}
		
		protected function getChildrenLayoutArea():Rectangle
		{
			return new Rectangle( _padding, _padding, _width - _padding*2, _height - _padding*2 );
		}
		
		protected function initVisibleItemRenderers():void {}
				
		protected function calculateFlattenedData():void
		{
			if ( _dataProvider is ArrayCollection )
			{
				flattenedData = ArrayCollection(_dataProvider).source;
			}
			else
			{
				flattenedData = [];
			}
			
			
			if ( _filterFunction != null )
			{
				flattenedData = flattenedData.slice();
				for ( var i:int = 0; i < flattenedData.length; i++ )
				{
					var data:Object = flattenedData[i];
					if ( _filterFunction(data) == false )
					{
						flattenedData.splice(i, 1);
						i--;
					}
				}
			}
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
		// Drag and drop protected methods
		////////////////////////////////////////////////
		
		protected function beginDrag():void
		{
			// Find out which item renderer the mouse was over when the user pressed.
			var pressPos:Point = content.localToGlobal(mouseDownDragStart);
			for ( var i:int = 0; i < content.numChildren; i++ )
			{
				var itemRenderer:DisplayObject = content.getChildAt(i);
				if ( itemRenderer.hitTestPoint( pressPos.x, pressPos.y ) == false ) continue;
				
				// Begin dragging this item renderer
				// Clone the item renderer and attach it to the mouse.
				dropIndicator.visible = true;
				
				draggedItemRenderer = new itemRendererClass();
				InteractiveObject(draggedItemRenderer).mouseEnabled = false;
				IItemRenderer(draggedItemRenderer).list = this;
				IItemRenderer(draggedItemRenderer).data = IItemRenderer(itemRenderer).data;;
				IItemRenderer(draggedItemRenderer).selected = IItemRenderer(itemRenderer).selected;
				draggedItemRenderer.width = itemRenderer.width;
				draggedItemRenderer.height = itemRenderer.height;
				draggedItemRenderer.alpha = 0.5;
				IItemRenderer(draggedItemRenderer).validateNow();
				draggedItemRenderer.x = stage.mouseX - itemRenderer.mouseX;
				draggedItemRenderer.y = stage.mouseY - itemRenderer.mouseY;
				Sprite(draggedItemRenderer).startDrag(false);
				stage.addChild( draggedItemRenderer );
				
				dispatchEvent( new DragAndDropEvent( DragAndDropEvent.DRAG_START, IItemRenderer(itemRenderer).data ) );
				
				return;
			}
		}
				
		protected function updateDropTarget():void
		{
			var newDropTargetCollection:ArrayCollection;
			var newDropTargetIndex:int;
			for each ( var itemRenderer:IItemRenderer in visibleItemRenderers )
			{
				if ( DisplayObject(itemRenderer).hitTestPoint( stage.mouseX, stage.mouseY ) == false ) continue;
				
				newDropTargetCollection = ArrayCollection(_dataProvider);
				newDropTargetIndex = dropTargetCollection.getItemIndex(itemRenderer.data);
				if ( DisplayObject(itemRenderer).mouseY > (itemRenderer.height >> 1) )
				{
					dropTargetIndex++;
				}
				break;
			}
			
			if ( newDropTargetCollection == dropTargetCollection && newDropTargetIndex == dropTargetIndex ) return;
			
			var event:DragAndDropEvent = new DragAndDropEvent( DragAndDropEvent.DRAG_OVER, IItemRenderer(draggedItemRenderer).data, newDropTargetCollection, newDropTargetIndex );
			dispatchEvent( event );
			if ( event.isDefaultPrevented() )
			{
				dropTargetCollection = null;
				dropTargetIndex = -1;
				return;
			}
			dropTargetCollection = newDropTargetCollection;
			dropTargetIndex = newDropTargetIndex;
		}
		
		protected function updateDropIndicator( dropTargetCollection:ArrayCollection, dropTargetIndex:int ):void
		{
			var after:Boolean = dropTargetIndex >= dropTargetCollection.length;
			
			var dropTargetData:Object = dropTargetCollection[after ? dropTargetIndex - 1 : dropTargetIndex];
			var itemRenderer:IItemRenderer = getItemRendererForData( dropTargetData );
			
			if ( after )
			{
				dropIndicator.y = -content.scrollRect.y + itemRenderer.y + itemRenderer.height;
			}
			else
			{
				dropIndicator.y = -content.scrollRect.y + itemRenderer.y;
			}
			dropIndicator.width = itemRenderer.width - dropIndicator.x - 10;
		}
		
		protected function handleDrop( draggedItem:Object, targetCollection:ArrayCollection, targetIndex:int ):void
		{
			var event:DragAndDropEvent = new DragAndDropEvent( DragAndDropEvent.DRAG_DROP, draggedItem, targetCollection, targetIndex );
			dispatchEvent(event);
			
			if ( event.isDefaultPrevented() ) return;
			
			// Removed the item from the data provider and re-insert it at the proper index
			var draggedItemIndex:int = targetCollection.getItemIndex(draggedItem);
			targetCollection.removeItemAt(draggedItemIndex);
			if ( draggedItemIndex < targetIndex )
			{
				targetIndex--;		// Need to modify insertion index after previous item has been removed.
			}
			targetCollection.addItemAt(draggedItem, targetIndex);
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		protected function rollOverContentHandler( event:MouseEvent ):void
		{
			var itemRenderer:IItemRenderer = event.target as IItemRenderer;
			if ( itemRenderer == null ) return;
			dispatchEvent( new ListEvent( ListEvent.ITEM_ROLL_OVER, itemRenderer.data ) );
		}
		
		protected function rollOutContentHandler( event:MouseEvent ):void
		{
			var itemRenderer:IItemRenderer = event.target as IItemRenderer;
			if ( itemRenderer == null ) return;
			dispatchEvent( new ListEvent( ListEvent.ITEM_ROLL_OUT, itemRenderer.data ) );
		}
		
		protected function dataProviderChangeHandler( event:ArrayCollectionEvent ):void
		{
			if ( event.kind == ArrayCollectionChangeKind.RESET )
			{
				_selectedItems = [];
			}
			else if ( event.kind == ArrayCollectionChangeKind.REMOVE )
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
			
			var item:Object = flattenedData[index];
			if ( _dataDescriptor.getEnabled(item) == false ) return;
			
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
			dispatchEvent( new ScrollEvent( ScrollEvent.CHANGE_SCROLL ) );
		}
		
		private function mouseDownContentHandler( event:MouseEvent ):void
		{
			if ( _allowDragAndDrop )
			{
				mouseDownDragStart = new Point( content.mouseX, content.mouseY );
				stage.addEventListener( Event.ENTER_FRAME, dragHandler );
				stage.addEventListener( MouseEvent.MOUSE_UP, endDragHandler );
			}
		}
			
		private function dragHandler( event:Event ):void
		{
			// If we're not yet dragging, check to see if we've moved the mouse enough from the press point.
			if ( draggedItemRenderer == null )
			{
				var dis:int = Math.abs(content.mouseX - mouseDownDragStart.x) + Math.abs(content.mouseY - mouseDownDragStart.y);
				if ( dis > 3 )
				{
					beginDrag();
				}
			}
			
			if ( draggedItemRenderer )
			{
				if ( content.mouseY < 20 )
				{
					scrollY -= 2;
				}
				else if ( content.mouseY > getChildrenLayoutArea().height - 20 )
				{
					scrollY += 2;
				}
				updateDropTarget();
				
				if ( dropTargetCollection == null )
				{
					dropIndicator.visible = false;
				}
				else
				{
					dropIndicator.visible = true;
					updateDropIndicator( dropTargetCollection, dropTargetIndex );
				}
			}
		}
		
		private function endDragHandler( event:MouseEvent ):void
		{
			if ( draggedItemRenderer )
			{
				handleDrop(IItemRenderer(draggedItemRenderer).data, dropTargetCollection, dropTargetIndex);
				
				Sprite(draggedItemRenderer).stopDrag();
				stage.removeChild( draggedItemRenderer );
				draggedItemRenderer = null;
				dropTargetCollection = null;
				dropTargetIndex - -1;
			}
			
			dropIndicator.visible = false;
			stage.removeEventListener( Event.ENTER_FRAME, dragHandler );
			stage.removeEventListener( MouseEvent.MOUSE_UP, endDragHandler );
		}
		
		
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set dataProvider( value:Object ):void
		{
			if ( _dataProvider is ArrayCollection )
			{
				ArrayCollection(_dataProvider).removeEventListener( ArrayCollectionEvent.CHANGE, dataProviderChangeHandler );
			}
			_dataProvider = value;
			if ( _dataProvider is ArrayCollection )
			{
				ArrayCollection(_dataProvider).addEventListener( ArrayCollectionEvent.CHANGE, dataProviderChangeHandler );
			}
			_selectedItems = [];
			invalidate();
		}
		
		public function get dataProvider():Object
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
		
		public function set selectedItem( value:Object ):void
		{
			selectedItems = value == null ? [] : [value];
		}
		
		public function get selectedItem():Object
		{
			return _selectedItems.length == 0 ? null : _selectedItems[0];
		}
		
		public function get maxScrollY():int
		{
			return vScrollBar.max;
		}
		
		public function set scrollY( value:int ):void
		{
			if ( value == vScrollBar.value ) return;
			vScrollBar.removeEventListener( Event.CHANGE, onChangeVScrollBar );
			vScrollBar.value = value;
			vScrollBar.addEventListener( Event.CHANGE, onChangeVScrollBar );
			invalidate();
			dispatchEvent( new ScrollEvent( ScrollEvent.CHANGE_SCROLL ) );
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
		
		public function set allowDragAndDrop( value:Boolean ):void
		{
			_allowDragAndDrop = value;
		}
		
		public function get allowDragAndDrop():Boolean
		{
			return _allowDragAndDrop;
		}
		
		public function get filterFunction():Function
		{
			return _filterFunction;
		}
		
		public function set filterFunction(value:Function):void
		{
			_filterFunction = value;
			invalidate();
		}
		
		public function set showBorder( value:Boolean ):void
		{
			background.visible = value;
		}
		
		public function get showBorder():Boolean
		{
			return background.visible;
		}
		
		public function set padding( value:int ):void
		{
			_padding = value;
			invalidate();
		}
		
		public function get padding():int
		{
			return _padding;
		}
	}
}