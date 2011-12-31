package flux.components 
{
	import flash.text.TextFieldAutoSize;
	import flux.skins.TabNavigatorTabSkin;
	
	public class TabNavigatorTab extends PushButton
	{
		public function TabNavigatorTab() 
		{
			super( TabNavigatorTabSkin );
		}
		
		override protected function init():void
		{
			super.init();
			_resizeToContent = true;
		}
	}
}