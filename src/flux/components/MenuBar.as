/**
 * MenuBar.as
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
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flux.data.ArrayCollection;
	import flux.data.DefaultDataDescriptor;
	import flux.data.IDataDescriptor;
	import flux.events.ArrayCollectionEvent;
	import flux.events.SelectEvent;
	import flux.layouts.HorizontalLayout;
	import flux.managers.FocusManager;
	import flux.skins.MenuBarButtonSkin;
	import flux.skins.MenuBarSkin;
	
	[Event( type="flux.events.SelectEvent", name="select" )]
	public class MenuBar extends UIComponent
	{
		// Properties
		private var _dataProvider	:ArrayCollection;
		private var _dataDescriptor	:IDataDescriptor;
		
		// Child elements
		private var background		:Sprite;
		private var buttonBar		:Container;
		private var list			:List;
		
		// Internal vars
		private var selectedData	:Object;
		
		public function MenuBar()
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			focusEnabled = true;
			
			background = new MenuBarSkin();
			addChild(background);
			_height = background.height;
			_width = background.width;
			
			buttonBar = new Container();
			buttonBar.layout = new HorizontalLayout(0);
			addChild(buttonBar);
			
			list = new List();
			list.itemRendererClass = DropDownListItemRenderer;
			list.resizeToContent = true;
			list.clickSelect = true;
			list.focusEnabled = false;
			
			_dataDescriptor = new DefaultDataDescriptor();
			list.dataDescriptor = _dataDescriptor;
			
			buttonBar.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownButtonBarHandler);
			buttonBar.addEventListener(SelectEvent.SELECT, selectButtonBarHandler);
		}
		
		override protected function validate():void
		{
			var dataProviderLength:int = _dataProvider ? _dataProvider.length : 0;
			var maxLength:int = Math.max( dataProviderLength, buttonBar.numChildren )
			
			for ( var i:int = 0; i < dataProviderLength; i++ )
			{
				var data:Object = _dataProvider[i];
				var btn:Button;
				
				// Re-use existing button if possible
				if ( buttonBar.numChildren > i )
				{
					btn = Button(buttonBar.getChildAt(i));
				}
				else
				{
					btn = new Button(MenuBarButtonSkin);
					btn.focusEnabled = false;
					btn.resizeToContent = true;
					buttonBar.addChild(btn);
				}
				
				btn.label = _dataDescriptor.getLabel(data);
			}
			
			// Remove any left-over buttons
			while ( buttonBar.numChildren > dataProviderLength )
			{
				buttonBar.removeChildAt(dataProviderLength);
			}
			
			background.width = _width;
			background.height = _height;
			
			buttonBar.width = _width;
			buttonBar.height = _height;
			buttonBar.validateNow();
		}
		
		protected function openList():void
		{
			var selectedBtn:Button = Button(buttonBar.getChildAt( _dataProvider.source.indexOf(selectedData) ));
			
			if ( list.stage == null )
			{
				stage.addChild(list);
			}
			
			var pt:Point = new Point( selectedBtn.x, buttonBar.height);
			pt = localToGlobal(pt);
			list.x = pt.x;
			list.y = pt.y;
			var dp:ArrayCollection = _dataDescriptor.getChildren(selectedData);
			list.dataProvider = dp;
			list.visible = dp != null && dp.length > 0;
			
			for ( var i:int = 0; i < buttonBar.numChildren; i++ )
			{
				var child:Button = Button(buttonBar.getChildAt(i));
				child.selected = child == selectedBtn;
			}
			
			buttonBar.addEventListener(MouseEvent.MOUSE_OVER, mouseOverButtonBarHandler );
			list.addEventListener(MouseEvent.MOUSE_UP, mouseUpListHandler );
		}
		
		protected function closeList():void
		{
			if ( selectedData == null ) return;
			if ( list.stage == null ) return;
			
			stage.removeChild(list);
			
			for ( var i:int = 0; i < buttonBar.numChildren; i++ )
			{
				var child:Button = Button(buttonBar.getChildAt(i));
				child.selected = false;
			}
			
			selectedData = null;
			buttonBar.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverButtonBarHandler );
			list.removeEventListener(MouseEvent.MOUSE_UP, mouseUpListHandler );
		}
		
		override public function onLoseComponentFocus():void
		{
			closeList();
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function selectButtonBarHandler( event:SelectEvent ):void
		{
			event.stopImmediatePropagation();
		}
		
		private function mouseDownButtonBarHandler( event:MouseEvent ):void
		{
			var btn:Button = event.target as Button;
			if ( !btn ) return;
			
			if ( selectedData )
			{
				closeList();
			}
			else
			{
				var index:int = buttonBar.getChildIndex(btn);
				selectedData = _dataProvider[index];
				openList();
			}
		}
		
		private function mouseOverButtonBarHandler( event:MouseEvent ):void
		{
			var btn:Button = event.target as Button;
			if ( !btn ) return;
			
			var index:int = buttonBar.getChildIndex(btn);
			selectedData = _dataProvider[index];
			openList();
		}
		
		private function mouseUpListHandler( event:MouseEvent ):void
		{
			var itemRenderer:IItemRenderer = event.target as IItemRenderer;
			if ( itemRenderer == null ) return;
			if ( list.dataDescriptor.getEnabled(itemRenderer.data) == false ) return;
			dispatchEvent( new SelectEvent( SelectEvent.SELECT, itemRenderer.data, true, false ) );
			
			closeList();
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
			closeList();
			invalidate();
		}
		
		public function get dataProvider():ArrayCollection
		{
			return _dataProvider;
		}
		
		private function dataProviderChangeHandler( event:ArrayCollectionEvent ):void
		{
			invalidate();
		}
		
		public function set dataDescriptor( value:IDataDescriptor ):void
		{
			if ( value == _dataDescriptor ) return;
			_dataDescriptor = value;
			list.dataDescriptor = _dataDescriptor;
		}
		
		public function get dataDescriptor():IDataDescriptor
		{
			return _dataDescriptor;
		}
	}
}