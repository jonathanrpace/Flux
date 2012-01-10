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
	 * Panel, default button
	 * TextArea
	 * Label
	 * Tooltips
	 * Change InputField to TextInput
	 */
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flux.components.*;
	import flux.data.ArrayCollection;
	import flux.events.DragAndDropEvent;
	import flux.events.TabNavigatorEvent;
	import flux.events.TreeEvent;
	import flux.managers.PopUpManager;
	import flux.util.FluxDeserializer;
	import icons.*
	
	[SWF( backgroundColor="0x101010", frameRate="60" )]
	public class FluxSandbox extends Container 
	{
		public var propertyInspector	:PropertyInspector;
		public var list					:List;
		public var tree					:Tree;
		public var tabNavigator			:TabNavigator;
		public var dropDownMenu			:DropDownMenu;
		public var menuBar				:MenuBar;
		public var panel				:Panel;
		
		public function FluxSandbox() 
		{
			var myType:Class = FluxSandbox;
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
					
						<VBox width="100%" height="100%">
							<PropertyInspector id="propertyInspector" width="100%" height="100%" />
							<TextArea width="100%" height="100%" resizeToContent="true" text="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla viverra ultricies velit, id porttitor felis laoreet vitae. Mauris blandit ullamcorper magna, vitae accumsan massa adipiscing eget. Mauris condimentum egestas magna ac tristique. Mauris et ante nulla. Cras eget nisi sit amet augue tempor elementum a vitae justo."/>
							<TextInput width="100%" height="100%" multiline="true" text="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla viverra ultricies velit, id porttitor felis laoreet vitae. Mauris blandit ullamcorper magna, vitae accumsan massa adipiscing eget. Mauris condimentum egestas magna ac tristique. Mauris et ante nulla. Cras eget nisi sit amet augue tempor elementum a vitae justo."/>
						
						</VBox>
						
					
						<List id="list" width="100%" height="100%" allowMultipleSelection="false" />
						<Tree id="tree" width="100%" height="100%" allowMultipleSelection="true" showRoot="false" allowDragAndDrop="true" />
						
						<TabNavigator id="tabNavigator" width="100%" height="100%" padding="4" showCloseButtons="false" >
							<VBox width="100%" height="100%" label="Misc controls"  >
								<CheckBox label="Button 1" selected="true" indeterminate="true" />
								<CheckBox label="Button 1" selected="false" indeterminate="true" />
								<CheckBox label="Button 1" selected="true" width="100%" />
								
								<RadioButtonGroup resizeToContent="true">
									<RadioButton label="Radio Button A" selected="true" />
									<RadioButton label="Radio Button B" selected="false" />
									<RadioButton label="Radio Button C" selected="false" />
									
									<layout>
										<VerticalLayout/>
									</layout>
								</RadioButtonGroup>
								
								<NumericStepper width="100%" min="-10" max="10" />
								<ProgressBar width="100%" progress="0.4" indeterminate="true" />
								<Label text="I'm a label"/>
								<ColorPicker width="100%" />
							</VBox>
							
							<ScrollPane width = "100%" height = "100%" label="Collapsible Panels">
								
								<CollapsiblePanel width="100%" height="200"/>
								<CollapsiblePanel width="100%" height="200"/>
								<CollapsiblePanel width="100%" height="200"/>
								<CollapsiblePanel width="100%" height="200"/>
								
								<layout>
									<VerticalLayout/>
								</layout>
								
							</ScrollPane>
						
							<TextInput width="100%" label="TextInput" />
							<DropDownMenu id="dropDownMenu" width="100%" label="DropDownMenu" />
							<PushButton label="Button 2 longer" toggle="false" />
							<PushButton label="Button 3 with a really long label" toggle="true" resizeToContent="true" />
						</TabNavigator>
						
						
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
			
			// Create an inspectable data provider for the property inspector.
			var propertyInspectorDataProvider:ArrayCollection = new ArrayCollection();
			propertyInspectorDataProvider.addItem( new InspectableObject() );
			propertyInspector.dataProvider = propertyInspectorDataProvider;
			
			// Build an example data provider
			var dp:Object = { label:"root" };
			dp.icon = Folder16x16;
			dp.children = createDataProvider(15);
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
			
			// Bind multiple controls to the same data provider.
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
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stageResizeHandler(null);
			
			stage.addEventListener( FocusEvent.FOCUS_IN, stageFocusInHandler );
			stage.addEventListener( FocusEvent.FOCUS_OUT, stageFocusOutHandler );
			
			new PopUpManager(stage);
			Alert.show("Alert", "This is an alert", ["Cancel", "OK"], Info32x32);
		}
		
		private function stageFocusInHandler( event:FocusEvent ):void
		{
			//trace("Focus in : " + event.target);
		}
		
		private function stageFocusOutHandler( event:FocusEvent ):void
		{
			//trace("Focus out : " + event.target);
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
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			if ( event.keyCode == Keyboard.DELETE )
			{
				var selectedItems:Array = tree.selectedItems;
				for ( var i:int = 0; i < selectedItems.length; i++ )
				{
					var selectedItem:Object = selectedItems[i];
					var parent:Object = tree.getParent(selectedItem, false);
					parent.children.removeItem(selectedItem);
				}
			}
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
		
		private function stageResizeHandler( event:Event ):void
		{
			if ( event && event.target != stage ) return;
			width = stage.stageWidth;
			height = stage.stageHeight;
			validateNow();
		}
	}
}