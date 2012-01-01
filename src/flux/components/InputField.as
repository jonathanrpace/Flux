package flux.components 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flux.skins.InputFieldSkin;
	
	public class InputField extends UIComponent 
	{
		// Child elements
		protected var skin				:Sprite;
		protected var textField			:TextField;
		
		public function InputField() 
		{
			
		}
		
		override protected function init():void
		{
			skin = new InputFieldSkin();
			addChild(skin);
			
			_width = skin.width;
			_height = skin.height;
			
			textField = new TextField();
			textField.defaultTextFormat = new TextFormat( Style.fontFace, Style.fontSize, Style.fontColor );
			textField.selectable = true;
			textField.type = TextFieldType.INPUT;
			textField.multiline = false;
			
			SelectionColor.setFieldSelectionColor(textField, 0xCCCCCC);
			
			addChild( textField );
		}
		
		override protected function validate():void
		{
			textField.x = 4;
			textField.width = _width - 4;
			textField.height = Math.min(textField.textHeight + 4, _height);
			textField.y = (_height - (textField.height)) >> 1;
			
			skin.width = _width;
			skin.height = _height;
		}
		
		public function set restrict( value:String ):void
		{
			textField.restrict = value;
		}
		
		public function get restrict():String
		{
			return textField.restrict;
		}
		
		public function set text( value:String ):void
		{
			textField.text = value;
		}
		
		public function get text():String
		{
			return textField.text;
		}
	}
}