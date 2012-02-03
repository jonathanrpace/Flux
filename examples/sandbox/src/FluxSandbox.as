/**
 * FluxSandbox.as
 *
 * This isn't so much an 'example' as a place where I can stress test various
 * combinations of Flux components. As such it doesn't have a single topic it's
 * trying to explain. I've included it anyway as it still may provide useful
 * reference for components I've not documented, or not provided examples for
 * yet.
 * 
 * 
 * Copyright (c) 2012 Jonathan Pace
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
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flux.components.*;
	import flux.data.ArrayCollection;
	import flux.events.DragAndDropEvent;
	import flux.events.TabNavigatorEvent;
	import flux.events.TreeEvent;
	import flux.managers.CursorManager;
	import flux.managers.PopUpManager;
	import flux.managers.ToolTipManager;
	import flux.util.BindingUtil;
	import flux.util.FluxDeserializer;
	import icons.*
	import flux.cursors.*;
	
	[SWF( width="800", height="600", backgroundColor="0x101010", frameRate="60" )]
	public class FluxSandbox extends Application
	{
		public var list					:List;
		public var tree					:Tree;
		public var tabNavigator			:TabNavigator;
		public var dropDownMenu			:DropDownMenu;
		public var menuBar				:MenuBar;
		public var panel				:Panel;
		public var textArea				:TextArea;
		public var progressBar			:ProgressBar;
		public var spawnAlertBtn		:Button;
		
		public function FluxSandbox()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML =
			<Container padding="20">
				
				<VBox width="100%" height="100%" >
					
					<MenuBar id="menuBar" width="100%"/>
					<HBox width="100%" height="100%" >
					
						<VBox width="100%" height="100%">
							<TextArea id="textArea" width="100%" height="100%" resizeToContentWidth="true" text="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla viverra ultricies velit, id porttitor felis laoreet vitae. Mauris blandit ullamcorper magna, vitae accumsan massa adipiscing eget. Mauris condimentum egestas magna ac tristique. Mauris et ante nulla. Cras eget nisi sit amet augue tempor elementum a vitae justo."/>
							<TextArea width="100%" height="100%" editable="true" multiline="true" text="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla viverra ultricies velit, id porttitor felis laoreet vitae. Mauris blandit ullamcorper magna, vitae accumsan massa adipiscing eget. Mauris condimentum egestas magna ac tristique. Mauris et ante nulla. Cras eget nisi sit amet augue tempor elementum a vitae justo."/>
						</VBox>
						
					
						<List id="list" width="100%" height="100%" allowMultipleSelection="false" />
						<Tree id="tree" width="100%" height="100%" allowMultipleSelection="true" showRoot="false" allowDragAndDrop="true" />
						
						<TabNavigator id="tabNavigator" width="100%" height="100%" padding="4" showCloseButtons="false" >
							<VBox width="100%" height="100%" label="Misc controls"  >
								<CheckBox label="Button 1" selected="true" indeterminate="true" />
								<CheckBox label="Button 1" selected="false" indeterminate="true" />
								<CheckBox label="Button 1" selected="true" width="100%" />
								
								<RadioButtonGroup resizeToContentWidth="true" resizeToContentHeight="true">
									<RadioButton label="Radio Button A" selected="true" />
									<RadioButton label="Radio Button B" selected="false" />
									<RadioButton label="Radio Button C" selected="false" />
									
									<layout>
										<VerticalLayout/>
									</layout>
								</RadioButtonGroup>
								
								<NumericStepper width="100%" min="-10" max="10" />
								<ProgressBar id="progressBar" width="100%" progress="0.4" indeterminate="true" />
								<Label text="I'm a label"/>
								<HSlider width="100%" min="-3" max="7" snapInterval="0.7" showMarkers="true"/>
								<HSlider width="100%" min="-3" max="7" snapInterval="0" showMarkers="false"/>
								<ColorPicker width="100%" />
							</VBox>
							
							<ScrollPane width = "100%" height = "100%" label="Collapsible Panels">
								
								<VDividedBox width="100%" resizeToContentHeight="true">
									<CollapsiblePanel label="Panel 1" width="100%" height="100" showCloseButton="true"/>
									<CollapsiblePanel label="Panel 2" width="100%" height="100"/>
									<CollapsiblePanel label="Panel 3" width="100%" height="100"/>
									<CollapsiblePanel label="Panel 4" width="100%" height="100"/>
								</VDividedBox>
								
							</ScrollPane>
						
							<TextArea width="100%" label="TextArea" editable="true" />
							<DropDownMenu id="dropDownMenu" width="100%" label="DropDownMenu" />
							<Button label="Button 2 longer" toggle="false" />
							<Button label="Button 3 with a really long label" toggle="true" resizeToContentWidth="true" />
						</TabNavigator>
						
						
					</HBox>
					
					<Panel id="panel" label="I'm a Panel" width="100%" height="120" >
						<Button label="Click me to show an alert" id="spawnAlertBtn" toggle="false" width="100%" height="40" />
						<Button label="Button 3" toggle="true" width="100%" height="30" selectMode="mouseDown" />
						<Button label="Button 4" toggle="false" width="100%" height="20" />
						<Button label="Button 5" toggle="true" width="100%" height="40" />
						<Button label="Button 6" toggle="false" width="100%" height="30" toolTip="This is another tooltip"/>
						<Button label="Button 7" toggle="true" width="100%" height="20" toolTip="This is a tooltip" />
						
						<layout>
							<HorizontalLayout verticalAlign="centre"/>
						</layout>
						
						<controlBar>
							<Button label="OK"/>
							<Button label="Cancel"/>
						</controlBar>
					</Panel>
					
				</VBox>
				
			</Container>
			
			FluxDeserializer.deserialize( xml, this );
			
			spawnAlertBtn.addEventListener(MouseEvent.CLICK, clickSpawnAlertBtn);
			
			// Build an example data provider
			var dp:Object = { label:"root" };
			dp.icon = Folder16x16;
			dp.children = createDataProvider(25);
			// Randomly insert second-level of data
			for ( var i:int = 0; i < dp.children.length; i++ )
			{
				var data:Object = dp.children[i];
				if ( i < 7 )
				{
					data.icon = Folder16x16;
					data.children = createDataProvider(4);
				}
			}
			
			
			list.dataProvider = dp.children;
			list.filterFunction = function (item:Object):Boolean
			{
				return item.index > 2 && item.index < 7;
			}
			
			tree.dataProvider = dp;
			dropDownMenu.dataProvider = dp.children;
			menuBar.dataProvider = dp.children;
			
			tree.addEventListener( DragAndDropEvent.DRAG_START, dragHandler);
			tree.addEventListener( DragAndDropEvent.DRAG_OVER, dragHandler);
			tree.addEventListener( DragAndDropEvent.DRAG_DROP, dragHandler);
			tree.addEventListener( TreeEvent.ITEM_OPEN, itemOpenHandler);
			tree.addEventListener( TreeEvent.ITEM_CLOSE, itemCloseHandler);
			
			tabNavigator.addEventListener(TabNavigatorEvent.CLOSE_TAB, closeTabHandler);
			
			stage.addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			
			validateNow();
		}
		
		private function clickSpawnAlertBtn( event:MouseEvent ):void
		{
			Alert.show("Alert", "This is an alert", ["Cancel", "OK"], "OK", Info32x32);
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			progressBar.progress += 0.003;
			if ( progressBar.progress == 1 )
			{
				progressBar.progress = 0;
			}
		}
		
		private function itemOpenHandler( event:TreeEvent ):void
		{
			trace("open : " + event.item.label);
		}
		
		private function itemCloseHandler( event:TreeEvent ):void
		{
			trace("close : " + event.item.label);
		}
		
		private function dragHandler( event:DragAndDropEvent ):void
		{
			trace( event.type + ", " + event.item.label + ", " + (event.targetCollection ? tree.getParent(event.targetCollection).label : "") + ", " + event.index );
		}
		
		private function closeTabHandler( event:TabNavigatorEvent ):void
		{
			tabNavigator.removeChildAt(event.tabIndex);
		}
		
		private function createDataProvider( numItems:int ):ArrayCollection
		{
			var dp:ArrayCollection = new ArrayCollection();
			for ( var i:int = 0; i < numItems; i++ )
			{
				dp.addItem( { label:"Item " + i, index:i, icon:FileIcon16x16 } );
			}
			return dp;
		}
	}
}