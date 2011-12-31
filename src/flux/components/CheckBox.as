package flux.components 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flux.skins.CheckBoxSkin;
	
	public class CheckBox extends PushButton 
	{
		protected var _indeterminate		:Boolean = false;
		
		public function CheckBox() 
		{
			super( CheckBoxSkin );
		}
		
		override protected function init():void
		{
			super.init()
			
			_toggle = true;
			
			var textFormat:TextFormat = labelField.defaultTextFormat;
			textFormat.align = TextFormatAlign.LEFT;
			labelField.defaultTextFormat = textFormat;
			labelField.autoSize = TextFieldAutoSize.LEFT;
			
			iconContainer.visible = false;
		}
		
		public function set indeterminate( value:Boolean ):void
		{
			_indeterminate = value;
			updateSkinState();
		}
		
		public function get indeterminate():Boolean
		{
			return _indeterminate;
		}
		
		override protected function validate():void
		{
			_height = labelField.height;
			skin.y = (_height - skin.height) >> 1;
			labelField.x = skin.x + skin.width + 4;
			labelField.height = Math.min(labelField.textHeight + 4, _height);
			labelField.y = (_height - (labelField.height)) >> 1;
			_width = labelField.x + labelField.width;
		}
		
		protected function updateSkinState():void
		{
			if ( !_selected && !_indeterminate )
			{
				_down ? skin.gotoAndPlay("Down") : _over ? skin.gotoAndPlay("Over") : skin.gotoAndPlay("Up");
			}
			else if ( _selected && !_indeterminate )
			{
				_down ? skin.gotoAndPlay("SelectedDown") : _over ? skin.gotoAndPlay("SelectedOver") : skin.gotoAndPlay("SelectedUp");
			}
			else
			{
				_down ? skin.gotoAndPlay("IndeterminateDown") : _over ? skin.gotoAndPlay("IndeterminateOver") : skin.gotoAndPlay("IndeterminateUp");
			}
		}
		
		override protected function rollOverHandler(event:MouseEvent):void
		{
			_over = true;
			updateSkinState();
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		override protected function rollOutHandler(event:MouseEvent):void
		{
			_over = false;
			_indeterminate ? skin.gotoAndPlay("IndeterminateOut") : _selected ? skin.gotoAndPlay( "SelectedOut" ) : skin.gotoAndPlay( "Out" );
			removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		override protected function mouseDownHandler(event:MouseEvent):void
		{
			_down = true;
			updateSkinState();
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}

		override protected function mouseUpHandler(event:MouseEvent):void
		{
			if(_over)
			{
				_selected = !_selected;
				_indeterminate = false;
				dispatchEvent( new Event( Event.CHANGE ) );
			}
			_down = false;
			
			updateSkinState();
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
	}
}