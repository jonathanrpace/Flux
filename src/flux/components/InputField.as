package flux.components 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flux.skins.InputFieldSkin;
	
	public class InputField extends UIComponent 
	{
		// Child elements
		protected var skin				:Sprite;
		protected var labelField		:TextField;
		
		public function InputField() 
		{
			
		}
		
		override protected function init():void
		{
			skin = new InputFieldSkin();
			addChild(skin);
			
			_width = skin.width;
			_height = skin.height;
			
			labelField = new TextField();
			labelField.defaultTextFormat = new TextFormat( Style.fontFace, Style.fontSize, Style.fontColor );
			//labelField.addEventListener( Event.CHANGE, labelFieldChangeHandler );
			labelField.selectable = true;
			labelField.type = TextFieldType.INPUT;
			labelField.multiline = false;
			
			SelectionColor.setFieldSelectionColor(labelField, 0xCCCCCC);
			
			addChild( labelField );
		}
		
		override protected function validate():void
		{
			labelField.x = 4;
			labelField.width = _width - 4;
			labelField.height = Math.min(labelField.textHeight + 4, _height);
			labelField.y = (_height - (labelField.height)) >> 1;
			
			skin.width = _width;
			skin.height = _height;
		}
	}

}