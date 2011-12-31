package  
{
	/*
	 * TODO
	 * 
	 * RadioButton + groups
	 * NumericStepper
	 * List Drag and Drop
	 * Tabnavigator close buttons and drag and drop
	 * InputField
	 */
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flux.components.Canvas;
	import flux.components.CheckBox;
	import flux.components.DropDownMenu;
	import flux.components.HBox;
	import flux.components.List;
	import flux.components.MenuBar;
	import flux.components.PushButton;
	import flux.components.SingletonExample;
	import flux.components.TabNavigator;
	import flux.components.Tree;
	import flux.components.UIComponent;
	import flux.components.VBox;
	import flux.components.ViewStack;
	import flux.data.ArrayCollection;
	import flux.util.FluxDeserializer;
	import icons.Bin;
	
	public class FluxSandbox extends VBox 
	{
		public var list			:List;
		public var tree			:Tree;
		public var buttonBar	:HBox;
		public var tabNavigator	:TabNavigator;
		public var dropDownMenu	:DropDownMenu;
		public var menuBar		:MenuBar;
		
		public function FluxSandbox() 
		{
			Bin;
		}
		
		override protected function init():void
		{
			super.init();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener( Event.RESIZE, stageResizeHandler );
			
			var xml:XML = 
			<VBox showBackground="false" padding="20" spacing="-1" >
				
				<MenuBar id="menuBar" width="100%"/>
				<HBox width="100%" height="100%" showBackground="false" >
					<List id="list" width="100%" height="100%" allowMultipleSelection="false" />
					<Tree id="tree" width="100%" height="100%" allowMultipleSelection="true" />
					
					<TabNavigator id="tabNavigator" width="100%" height="100%" padding="4" >
						<InputField width="100%" />
						<ScrollCanvas width="100%" height="100%">
							<DropDownMenu id="dropDownMenu" width="200" />
						</ScrollCanvas>
						<PushButton label="Button 2 longer" toggle="false" />
						<PushButton label="Button 3 with a really long label" toggle="true" resizeToContent="true" />
						<TabNavigator width="100%" height="100%" padding="4" label="Nested Tab Navigator" >
							<ScrollCanvas width="100%" height="100%">
								<DropDownMenu width="200" />
							</ScrollCanvas>
							<PushButton label="Button 2 longer" toggle="false" />
							<PushButton label="Button 3 with a really long label" toggle="true" resizeToContent="true" width="200" />
						</TabNavigator>
					</TabNavigator>
					
					<VBox width="100%" height="100%"  >
						<CheckBox label="Button 1" selected="true" indeterminate="true" width="100%" height="100%" />
						<CheckBox label="Button 1" selected="false" indeterminate="true" width="100%" height="100%" />
						<CheckBox label="Button 1" selected="true" width="100%" height="100%" />
						<CheckBox label="Button 1" selected="true" width="100%" height="100%" />
						<CheckBox label="Button 1" selected="true" width="100%" height="100%" />
						<CheckBox label="Button 1" selected="true" width="100%" height="100%" />
					</VBox>
					
				</HBox>
				
				<HBox id="buttonBar" width="100%" height="40" align="center" showBackground="false" >
					<PushButton label="Button 2" toggle="false" width="100%" height="100%" />
					<PushButton label="Button 3" toggle="true" width="100%" height="100%" />
					<PushButton label="Button 4" toggle="false" width="100%" height="100%" />
					<PushButton label="Button 5" toggle="true" width="100%" height="100%" />
					<PushButton label="Button 6" toggle="false" width="100%" height="100%" />
					<PushButton label="Button 7" toggle="true" width="100%" height="100%" />
				</HBox>
					
			</VBox>
			
			FluxDeserializer.deserialize( xml, this );
			
			
			// Build an example data provider
			var dp:Object = { };
			dp.children = createDataProvider(15, dp);
			for ( var i:int = 0; i < dp.children.length; i++ )
			{
				var data:Object = dp.children[i];
				// Randomly insert second-level of data
				if ( i < 7 )
				{
					data.children = createDataProvider(1 + Math.random() * 5, data);
				}
			}
			list.dataProvider = dp.children;
			tree.dataProvider = dp.children;
			dropDownMenu.dataProvider = dp.children;
			menuBar.dataProvider = dp.children;
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stageResizeHandler(null);
			
			validateNow();
		}
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			if ( event.keyCode == Keyboard.DELETE )
			{
				var selectedItems:Array = tree.selectedItems;
				for ( var i:int = 0; i < selectedItems.length; i++ )
				{
					var selectedItem:Object = selectedItems[i];
					selectedItem.parent.children.removeItem(selectedItem);
				}
			}
			else if ( event.keyCode == Keyboard.ENTER )
			{
				UIComponent(tabNavigator.getChildAt(0)).label = "Blah";
			}
			else if ( event.keyCode == Keyboard.RIGHT )
			{
				if ( tabNavigator.visibleIndex < tabNavigator.numChildren - 1 )
				{
					tabNavigator.visibleIndex++;
				}
			}
			else if ( event.keyCode == Keyboard.LEFT )
			{
				if ( tabNavigator.visibleIndex > -1 )
				{
					tabNavigator.visibleIndex--;
				}
			}
		}
		
		private function createDataProvider( numItems:int, parent:Object = null ):ArrayCollection
		{
			var dp:ArrayCollection = new ArrayCollection();
			for ( var i:int = 0; i < numItems; i++ )
			{
				dp.push( { label:"Item " + i, icon:Math.random() > 0.5 ? Bin : null, parent:parent } );
			}
			return dp;
		}
		
		private function stageResizeHandler( event:Event ):void
		{
			if ( event && event.target != stage ) return;
			width = stage.stageWidth;
			height = stage.stageHeight;
		}
	}
}