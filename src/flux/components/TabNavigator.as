package flux.components 
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flux.events.PropertyChangeEvent;
	import flux.layouts.HorizontalLayout;
	import flux.layouts.LayoutAlign;
	public class TabNavigator extends ViewStack 
	{
		private var tabBar	:Canvas;
		
		public function TabNavigator() 
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var testTab:TabNavigatorTab = new TabNavigatorTab();
			
			tabBar = new Canvas();
			tabBar.showBackground = false;
			tabBar.height = testTab.height;
			tabBar.layout = new HorizontalLayout( -1, LayoutAlign.BOTTOM);
			addRawChild(tabBar);
			
			tabBar.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownTabHandler );
			
			showBackground = true;
		}
		
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
		
		override protected function validate():void
		{
			super.validate();
			
			var layoutArea:Rectangle = getChildrenLayoutArea();
			
			background.y = (tabBar.height-1);
			background.height = _height - (tabBar.height-1);
			tabBar.width = _width;
			
			for ( var i:int = 0; i < tabBar.numChildren; i++ )
			{
				var tab:TabNavigatorTab = TabNavigatorTab( tabBar.getChildAt(i) );
				tab.selected = i == _visibleIndex;
			}
		}
		
		override protected function getChildrenLayoutArea():Rectangle
		{
			return new Rectangle( _paddingLeft, _paddingTop + (tabBar.height-1), _width - (_paddingRight+_paddingLeft), _height - ((_paddingBottom+_paddingTop) + (tabBar.height-1)) );
		}
		
		private function mouseDownTabHandler( event:MouseEvent ):void
		{
			var tab:TabNavigatorTab = event.target as TabNavigatorTab;
			if ( !tab ) return; // Looks like we've click the background, or some other chrome.
			
			var index:int = tabBar.getChildIndex(tab);
			visibleIndex = index;
		}
	}
}