package flux.components 
{
	import flux.skins.NumericStepperUpBtnSkin;
	import flux.skins.NumericStepperDownBtnSkin;
	
	public class NumericStepper extends UIComponent 
	{
		private var inputField		:InputField;
		private var upBtn			:PushButton;
		private var downBtn			:PushButton;
		
		public function NumericStepper() 
		{
			
		}
		
		override protected function init():void
		{
			inputField = new InputField();
			addChild(inputField);
			
			_width = inputField.width;
			_height = inputField.height;
			
			upBtn = new PushButton(NumericStepperUpBtnSkin);
			addChild(upBtn);
			
			downBtn = new PushButton(NumericStepperDownBtnSkin);
			addChild(downBtn);
		}
		
		override protected function validate():void
		{
			inputField.width = _width - upBtn.width;
			inputField.height = _height;
			
			upBtn.height = _height >> 1;
			upBtn.x = inputField.width;
			
			downBtn.height = _height - upBtn.height;
			downBtn.x = inputField.width;
			downBtn.y = upBtn.height;
		}
	}
}