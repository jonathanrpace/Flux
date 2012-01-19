package
{
	import flash.events.Event;
	import flux.components.Application;
	import flux.components.Container;
	import flux.components.TextArea;
	import flux.components.TextInput;
	import flux.components.UIComponent;
	import flux.components.VBox;
	import flux.layouts.HorizontalLayout;
	import flux.util.FluxDeserializer;
	
	public class FluxEditor extends Application
	{
		private var textInput	:TextInput;
		private var output		:Container;
		private var errorOutput	:TextArea;
		
		
		public function FluxEditor()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			layout = new HorizontalLayout();
			
			var vBox:VBox = new VBox();
			vBox.percentWidth = 100;
			vBox.percentHeight = 100;
			addChild(vBox);
			
			textInput = new TextInput();
			textInput.editable = true;
			textInput.multiline = true;
			textInput.percentWidth = 100;
			textInput.percentHeight = 100;
			textInput.addEventListener(Event.CHANGE, changeTextHandler);
			textInput.fontFamily = "_typewriter";
			textInput.embedFonts = false;
			textInput.fontSize = 11;
			vBox.addChild(textInput);
			
			errorOutput = new TextArea();
			errorOutput.percentWidth = 100;
			errorOutput.height = 100;
			vBox.addChild(errorOutput);
			
			output = new Container();
			output.percentWidth = 100;
			output.percentHeight = 100;
			addChild(output);
			
			var exampleXML:XML =
			<VBox width="100%" height="100%" >
					<HBox width="100%" height="100%" >
						<TextArea id="textArea" width="100%" height="100%" resizeToContent="false" text="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla viverra ultricies velit, id porttitor felis laoreet vitae. Mauris blandit ullamcorper magna, vitae accumsan massa adipiscing eget. Mauris condimentum egestas magna ac tristique. Mauris et ante nulla. Cras eget nisi sit amet augue tempor elementum a vitae justo."/>
						
						
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
								<ProgressBar id="progressBar" width="100%" progress="0.4" indeterminate="false" />
								<Label text="I'm a label"/>
								<HSlider width="100%" min="-3" max="7" stepSize="0.7" showMarkers="true"/>
								<HSlider width="100%" min="-3" max="7" stepSize="0" showMarkers="false"/>
								<ColorPicker width="100%" />
							</VBox>
							
							<ScrollPane width = "100%" height = "100%" label="Collapsible Panels">
								
								<CollapsiblePanel label="Panel 1" width="100%" height="200"/>
								<CollapsiblePanel label="Panel 2" width="100%" height="200"/>
								<CollapsiblePanel label="Panel 3" width="100%" height="200"/>
								<CollapsiblePanel label="Panel 4" width="100%" height="200"/>
								
								<layout>
									<VerticalLayout/>
								</layout>
								
							</ScrollPane>
						
							<TextArea width="100%" label="TextArea" editable="true" />
							<DropDownMenu id="dropDownMenu" width="100%" label="DropDownMenu" />
							<Button label="Button 2 longer" toggle="false" />
							<Button label="Button 3 with a really long label" toggle="true" resizeToContent="true" />
						</TabNavigator>
						
						
					</HBox>
					
				</VBox>
				
				textInput.text = exampleXML.toXMLString();
		}
		
		private function changeTextHandler( event:Event ):void
		{
			errorOutput.text = "";
			try
			{
				var xml:XML = XML( textInput.text );
				var component:UIComponent = FluxDeserializer.deserialize(xml);
				while ( output.numChildren > 0 )
				{
					output.removeChildAt(0);
				}
				output.addChild(component);
			}
			catch ( e:Error )
			{
				errorOutput.text = e.message;
				
				if ( textInput.text == "" )
				{
					while ( output.numChildren > 0 )
					{
						output.removeChildAt(0);
					}
				}
			}
		}
	}
}