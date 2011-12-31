package flux.components 
{
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flux.skins.ListItemRendererSkin;
	
	public class ListItemRenderer extends PushButton implements IItemRenderer
	{
		// Parent
		protected var _list			:List;
		
		// State and data
		protected var _data			:Object;
		
		public function ListItemRenderer(skinClass:Class = null) 
		{
			super(skinClass == null ? ListItemRendererSkin : skinClass );
		}
		
		override protected function validate():void
		{
			super.validate();
			var textFormat:TextFormat = labelField.defaultTextFormat;
			textFormat.align = TextFormatAlign.LEFT;
			labelField.defaultTextFormat = textFormat;
		}
		
		public function set data( value:Object ):void
		{
			_data = value;
			if ( _data )
			{
				label = list.dataDescriptor.getLabel(_data);
				icon = list.dataDescriptor.getIcon(_data);
			}
			else
			{
				label = "";
			}
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set list( value:List ):void
		{
			_list = value;
		}
		
		public function get list():List
		{
			return _list;
		}
	}
}