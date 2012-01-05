/**
 * Tree.as
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
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flux.data.ArrayCollection;
	import flux.events.ArrayCollectionEvent;
	import flux.events.DragAndDropEvent;
	import flux.events.TreeEvent;
	
	[Event( type="flux.events.TreeEvent", name="itemOpen" )]
	[Event( type="flux.events.TreeEvent", name="itemClose" )]
	public class Tree extends List 
	{
		// Properties
		private var _showRoot		:Boolean = true;
		
		// Internal vars
		private var isOpenedTable	:Dictionary;
		private var depthTable		:Dictionary;
		
		public function Tree() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Public methods
		////////////////////////////////////////////////
		
		public function setItemOpened( item:Object, opened:Boolean, dispatchEvent:Boolean = false ):void
		{
			if ( isOpenedTable[item] == opened ) return;
			isOpenedTable[item] = opened;
			invalidate();
			
			if ( dispatchEvent )
			{
				this.dispatchEvent( new TreeEvent( opened ? TreeEvent.ITEM_OPEN : TreeEvent.ITEM_CLOSE, item ) );
			}
		}
		
		public function getItemOpened( item:Object ):Boolean
		{
			return isOpenedTable[item];
		}
		
		/**
		 * Given a data item, this function will return its logical parent. Ie, the object with a 'children' collection containing the item.
		 * @param	item				The item to return the parent for.
		 * @param	searchOnlyVisible	By default, this function only searches visible items (ie opened). Pass false for a fully recursive search.
		 * @return						The parent of the item, or null if none found.
		 */
		public function getParent( item:Object, searchOnlyVisible:Boolean = true ):Object
		{
			var itemsToSearch:Array = _dataProvider ? [_dataProvider] : [];
			while ( itemsToSearch.length > 0 )
			{
				var currentItem:Object = itemsToSearch.pop();
				if ( _dataDescriptor.hasChildren(currentItem) == false ) continue;
				if ( searchOnlyVisible && isOpenedTable[currentItem] != true ) continue;
				
				var children:ArrayCollection = _dataDescriptor.getChildren(currentItem);
				if ( item is ArrayCollection )
				{
					if ( children == item ) return currentItem;
				}
				else if ( children.getItemIndex(item) != -1 )
				{
					return currentItem;
				}
				itemsToSearch = itemsToSearch.concat(children.source);
			}
			return null;
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			super.init();
			isOpenedTable = new Dictionary(true);
			_itemRendererClass = TreeItemRenderer;
			
			content.addEventListener(Event.CHANGE, itemRendererChangeHandler);
		}
		
		override protected function calculateFlattenedData():void
		{
			if ( _showRoot == false && _dataProvider != null )
			{
				isOpenedTable[_dataProvider] = true;
			}
			
			flattenedData = [];
			var dataToParse:Array;
			dataToParse = _dataProvider == null ? [] : [_dataProvider];
			
			depthTable = new Dictionary(true);
			while ( dataToParse.length > 0 )
			{
				var data:Object = dataToParse[0];
				var depth:int = depthTable[data];
				dataToParse.splice(0, 1);
				if ( data != _dataProvider || showRoot )
				{
					flattenedData.push(data);
				}
				
				if ( _dataDescriptor.hasChildren(data) == false ) continue;
				if ( isOpenedTable[data] != true ) continue;
				
				var children:ArrayCollection = _dataDescriptor.getChildren(data);
				children.addEventListener(ArrayCollectionEvent.CHANGE, dataProviderChangeHandler, false, 0, true);
				var childrenSource:Array = children.source;
				for ( var i:int = 0; i < childrenSource.length; i++ )
				{
					depthTable[childrenSource[i]] = depth + 1;
				}
				dataToParse = childrenSource.concat( dataToParse );
			}
		}
		
		override protected function initVisibleItemRenderers():void
		{
			for ( var i:int = 0; i < visibleItemRenderers.length; i++ )
			{
				var itemRenderer:ITreeItemRenderer = ITreeItemRenderer(visibleItemRenderers[i]);
				itemRenderer.depth = depthTable[itemRenderer.data] + (showRoot ? 0 : -1);
			}
		}
		
		////////////////////////////////////////////////
		// Drag and drop protected methods
		////////////////////////////////////////////////
		
		override protected function updateDropTarget():void
		{
			var newDropTargetCollection:ArrayCollection;
			var newDropTargetIndex:int;
			
			for each ( var itemRenderer:IItemRenderer in visibleItemRenderers )
			{
				if ( DisplayObject(itemRenderer).hitTestPoint( stage.mouseX, stage.mouseY ) == false ) continue;
				
				var after:Boolean = DisplayObject(itemRenderer).mouseY > (itemRenderer.height >> 1);
				var hasChildren:Boolean = _dataDescriptor.hasChildren(itemRenderer.data);
				
				if ( after && hasChildren && isOpenedTable[itemRenderer.data] == true )
				{
					newDropTargetCollection = _dataDescriptor.getChildren(itemRenderer.data);
					newDropTargetIndex = 0;
				}
				else 
				{
					var dropTargetParent:Object = getParent(itemRenderer.data);
					newDropTargetCollection = _dataDescriptor.getChildren(dropTargetParent);
					newDropTargetIndex = newDropTargetCollection.getItemIndex(itemRenderer.data);
					
					if ( after )
					{
						newDropTargetIndex++;
					}
				}
				
				break;
			}
			
			// Dissallow adding as child of oneself.
			if ( isParentOf( IItemRenderer(draggedItemRenderer).data, newDropTargetCollection ) )
			{
				dropTargetCollection = null;
				dropTargetIndex - -1;
				return;
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
		
		override protected function updateDropIndicator( dropTargetCollection:ArrayCollection, dropTargetIndex:int ):void
		{
			var after:Boolean = dropTargetIndex >= dropTargetCollection.length;
			var dropTargetData:Object = dropTargetCollection[after ? dropTargetIndex - 1 : dropTargetIndex];
			var itemRenderer:ITreeItemRenderer = ITreeItemRenderer(getItemRendererForData( dropTargetData ));
			dropIndicator.x = itemRenderer.depth * 16;
			
			super.updateDropIndicator( dropTargetCollection, dropTargetIndex );
		}
		
		override protected function handleDrop( draggedItem:Object, targetCollection:ArrayCollection, targetIndex:int ):void
		{
			var event:DragAndDropEvent = new DragAndDropEvent( DragAndDropEvent.DRAG_DROP, draggedItem, targetCollection, targetIndex );
			dispatchEvent(event);
			
			if ( event.isDefaultPrevented() ) return;
			
			// Removed the item from the data provider and re-insert it at the proper index
			var sourceCollection:ArrayCollection = _dataDescriptor.getChildren( getParent( draggedItem ) );
			var draggedItemIndex:int = sourceCollection.getItemIndex(draggedItem);
			sourceCollection.removeItemAt(draggedItemIndex);
			if ( sourceCollection == targetCollection && draggedItemIndex < targetIndex )
			{
				targetIndex--;		// Need to modify insertion index after previous item has been removed.
			}
			targetCollection.addItemAt(draggedItem, targetIndex);
		}
		
		
		private function isParentOf( parent:Object, item:Object ):Boolean
		{
			while ( item )
			{
				if ( parent == item ) return true;
				item = getParent(item);
			}
			return false;
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function itemRendererChangeHandler( event:Event ):void
		{
			var itemRenderer:ITreeItemRenderer = ITreeItemRenderer(event.target);
			setItemOpened( itemRenderer.data, itemRenderer.opened, true );
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		override public function set dataProvider( value:Object ):void
		{
			if ( value is ArrayCollection )
			{
				throw( new Error( "Tree control does not support ArrayCollection as its root node. Pass an object with children instead." ) );
				return;
			}
			
			_dataProvider = value;
			_selectedItems = [];
			invalidate();
		}
		
		public function set showRoot( value:Boolean ):void
		{
			if ( value == _showRoot ) return;
			_showRoot = value;
			_selectedItems = [];
			invalidate();
		}
		
		public function get showRoot():Boolean
		{
			return _showRoot;
		}
	}
}