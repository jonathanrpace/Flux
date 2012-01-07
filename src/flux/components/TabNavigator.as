/**
 * TabNavigator.as
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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flux.events.PropertyChangeEvent;
	import flux.events.TabNavigatorEvent;
	import flux.layouts.HorizontalLayout;
	import flux.layouts.LayoutAlign;
	import flux.skins.TabNavigatorSkin;
	
	[Event( type="flux.events.TabNavigatorEvent", name="closeTab" )]
	public class TabNavigator extends ViewStack 
	{
		// Properties
		private var _showCloseButtons	:Boolean = true;
		
		// Child elements
		private var tabBar				:Container;
		private var background			:Sprite;
		
		public function TabNavigator() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			background = new TabNavigatorSkin();
			addRawChild(background);
			
			super.init();
			
			_width = background.width;
			_height = background.height;
			
			var testTab:TabNavigatorTab = new TabNavigatorTab();
			
			tabBar = new Container();
			tabBar.focusEnabled = true;
			tabBar.height = testTab.height;
			tabBar.layout = new HorizontalLayout( -1, LayoutAlign.BOTTOM);
			addRawChild(tabBar);
			
			tabBar.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownTabHandler );
			tabBar.addEventListener( Event.CLOSE, closeTabHandler );
		}
		
		override protected function validate():void
		{
			super.validate();
			
			var layoutArea:Rectangle = getChildrenLayoutArea();
			
			background.width = _width;
			background.y = (tabBar.height-1);
			background.height = _height - (tabBar.height-1);
			tabBar.width = _width;
			
			for ( var i:int = 0; i < tabBar.numChildren; i++ )
			{
				var tab:TabNavigatorTab = TabNavigatorTab( tabBar.getChildAt(i) );
				tab.selected = i == _visibleIndex;
				tab.showCloseButton = _showCloseButtons;
			}
			tabBar.validateNow();
		}
		
		override protected function getChildrenLayoutArea():Rectangle
		{
			return new Rectangle( _paddingLeft, _paddingTop + (tabBar.height-1), _width - (_paddingRight+_paddingLeft), _height - ((_paddingBottom+_paddingTop) + (tabBar.height-1)) );
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		override protected function onChildrenChanged( child:UIComponent, index:int, added:Boolean ):void
		{
			super.onChildrenChanged( child, index, added );
			
			if ( added )
			{
				child.addEventListener( "propertyChange_label", childPropertyChangeHandler );
				child.addEventListener( "propertyChange_icon", childPropertyChangeHandler );
				var tab:TabNavigatorTab = new TabNavigatorTab();
				tab.width = 100;
				tab.percentHeight = 100;
				tab.label = child.label;
				tab.icon = child.icon;
				tabBar.addChildAt( tab, index );
			}
			else
			{
				child.removeEventListener( "propertyChange_label", childPropertyChangeHandler );
				child.removeEventListener( "propertyChange_icon", childPropertyChangeHandler );
				tabBar.removeChildAt(index);
			}
		}
		
		protected function childPropertyChangeHandler( event:PropertyChangeEvent ):void
		{
			var child:UIComponent = UIComponent(event.target);
			var childIndex:int = content.getChildIndex(child);
			var tab:TabNavigatorTab = TabNavigatorTab(tabBar.getChildAt(childIndex));
			tab.icon = child.icon;
			tab.label = child.label;
			tabBar.invalidate();
		}
		
		private function mouseDownTabHandler( event:MouseEvent ):void
		{
			var tab:TabNavigatorTab = event.target as TabNavigatorTab;
			if ( !tab ) return; // Looks like we've click the background, or some other chrome.
			focusManager.setFocus(tabBar);
			var index:int = tabBar.getChildIndex(tab);
			visibleIndex = index;
		}
		
		private function closeTabHandler( event:Event ):void
		{
			var tab:TabNavigatorTab = TabNavigatorTab(event.target);
			event.stopImmediatePropagation();
			var index:int = tabBar.getChildIndex(tab);
			dispatchEvent( new TabNavigatorEvent( TabNavigatorEvent.CLOSE_TAB, index, true ) );
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set showCloseButtons( value:Boolean ):void
		{
			if ( _showCloseButtons == value ) return;
			_showCloseButtons = value;
			invalidate();
		}
		
		public function get showCloseButtons():Boolean
		{
			return _showCloseButtons;
		}
	}
}