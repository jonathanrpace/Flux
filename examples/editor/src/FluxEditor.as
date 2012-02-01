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
	
	[SWF( width="800", height="600", backgroundColor="0x101010", frameRate="60" )]
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
				<Button label="Button A" />
				<Button label="Button B" toggle="true" />
				<Button label="Button C" selected="true" />
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