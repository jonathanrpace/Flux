/**
 * FluxSandbox.as
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

package  
{
	/*
	 * TODO
	 * 
	 * Add support for axis aligned layout values on all layouts.
	 * RadioButton + groups
	 * List Drag and Drop
	 * Tabnavigator close buttons and drag and drop
	 * ProgressBar
	 */
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flux.components.*;
	import flux.data.ArrayCollection;
	import flux.util.FluxDeserializer;
	import icons.Bin;
	
	[SWF( backgroundColor="0x101010", frameRate="60" )]
	public class FluxSandbox extends Container 
	{
		public var list			:List;
		public var tree			:Tree;
		public var tabNavigator	:TabNavigator;
		public var dropDownMenu	:DropDownMenu;
		public var menuBar		:MenuBar;
		public var panel		:Panel;
		
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
			<Container padding="20">
				
				<VBox width="100%" height="100%" >
					
					<MenuBar id="menuBar" width="100%"/>
					<HBox width="100%" height="100%" >
						<List id="list" width="100%" height="100%" allowMultipleSelection="false" />
						<Tree id="tree" width="100%" height="100%" allowMultipleSelection="true" />
						
						<TabNavigator id="tabNavigator" width="100%" height="100%" padding="4" >
							<InputField width="100%" label="InputField" />
							<DropDownMenu id="dropDownMenu" width="100%" label="DropDownMenu" />
							<PushButton label="Button 2 longer" toggle="false" />
							<PushButton label="Button 3 with a really long label" toggle="true" resizeToContent="true" />
							<TabNavigator width="100%" height="100%" padding="4" label="Nested Tab Navigator" >
								<ScrollPane width="100%" height="100%">
									<DropDownMenu width="200" />
								</ScrollPane>
								<PushButton label="Button 2 longer" toggle="false" />
								<PushButton label="Button 3 with a really long label" toggle="true" resizeToContent="true" width="200" />
							</TabNavigator>
						</TabNavigator>
						
						<VBox width="100%" height="100%"  >
							<CheckBox label="Button 1" selected="true" indeterminate="true" />
							<CheckBox label="Button 1" selected="false" indeterminate="true" />
							<CheckBox label="Button 1" selected="true" width="100%" />
							<NumericStepper width="100%" />
						</VBox>
						
					</HBox>
					
					<Panel id="panel" title="I'm a Panel" width="100%" height="80" >
						<PushButton label="Button 2" toggle="false" width="100%" height="100%" />
						<PushButton label="Button 3" toggle="true" width="100%" height="100%" />
						<PushButton label="Button 4" toggle="false" width="100%" height="100%" />
						<PushButton label="Button 5" toggle="true" width="100%" height="100%" />
						<PushButton label="Button 6" toggle="false" width="100%" height="100%" />
						<PushButton label="Button 7" toggle="true" width="100%" height="100%" />
						
						<layout>
							<HorizontalLayout/>
						</layout>
						
						<controlBar>
							<PushButton label="OK"/>
							<PushButton label="Cancel"/>
						</controlBar>
					</Panel>
				</VBox>
				
			</Container>
			
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