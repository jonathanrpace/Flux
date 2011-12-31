package flux.components 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flux.skins.TreeItemRendererOpenIconSkin;
	
	public class TreeItemRenderer extends ListItemRenderer implements ITreeItemRenderer
	{
		// Child elements
		protected var openIcon	:MovieClip;
		
		// State and data
		protected var _depth		:int = 0;
		protected var _opened		:Boolean = false;
		
		public function TreeItemRenderer() 
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			openIcon = new TreeItemRendererOpenIconSkin();
			addChild(openIcon);
			
			openIcon.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOpenIconHandler);
		}
		
		override protected function validate():void
		{
			super.validate();
			
			var offsetLeft:int = _depth * 16;
			
			openIcon.x = offsetLeft;
			openIcon.y = Math.round((_height - openIcon.height) * 0.5);
			openIcon.visible = _list && _data && _list.dataDescriptor.hasChildren(_data);
			
			iconContainer.x = openIcon.x + openIcon.width + 2;
			labelField.x = iconContainer.x + iconContainer.width + 4;
			labelField.width = _width - labelField.x;
		}
		
		public function set opened( value:Boolean ):void
		{
			if ( value == _opened ) return;
			_opened = value;
			_opened ? openIcon.gotoAndPlay( "Opened" ) : openIcon.gotoAndPlay("Closed");
			invalidate();
		}
		
		public function get opened():Boolean
		{
			return _opened;
		}
		
		public function set depth( value:int ):void
		{
			if ( _depth == value ) return;
			_depth = value;
			invalidate();
		}
		
		public function get depth():int
		{
			return _depth;
		}
		
		private function mouseDownOpenIconHandler( event:MouseEvent ):void
		{
			opened = !_opened;
			dispatchEvent( new Event( Event.CHANGE, true, false ) );
		}
	}
}