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
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flux.data.ArrayCollection;
	import flux.events.ArrayCollectionEvent;
	public class Tree extends List 
	{
		private var isOpenedTable	:Dictionary;
		private var depthTable		:Dictionary;
		
		public function Tree() 
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			isOpenedTable = new Dictionary(true);
			depthTable = new Dictionary(true);
			_itemRendererClass = TreeItemRenderer;
			
			content.addEventListener(Event.CHANGE, itemRendererChangeHandler);
		}
		
		public function setItemOpened( item:Object, opened:Boolean ):void
		{
			if ( isOpenedTable[item] == opened ) return;
			isOpenedTable[item] = opened;
			invalidate();
		}
		
		public function getItemOpened( item:Object ):Boolean
		{
			return isOpenedTable[item];
		}
		
		override protected function calculateFlattenedData():void
		{
			flattenedData = [];
			var dataToParse:Array = _dataProvider ? _dataProvider.source.slice() : [];
			
			while ( dataToParse.length > 0 )
			{
				var data:Object = dataToParse[0];
				var depth:int = depthTable[data];
				dataToParse.splice(0, 1);
				flattenedData.push(data);
				
				if ( _dataDescriptor.hasChildren(data) && isOpenedTable[data] )
				{
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
		}
		
		override protected function initVisibleItemRenderers():void
		{
			for ( var i:int = 0; i < visibleItemRenderers.length; i++ )
			{
				var itemRenderer:ITreeItemRenderer = ITreeItemRenderer(visibleItemRenderers[i]);
				itemRenderer.depth = depthTable[itemRenderer.data];
			}
		}
		
		private function itemRendererChangeHandler( event:Event ):void
		{
			var itemRenderer:ITreeItemRenderer = ITreeItemRenderer(event.target);
			isOpenedTable[itemRenderer.data] = itemRenderer.opened;
			invalidate();
		}
	}
}