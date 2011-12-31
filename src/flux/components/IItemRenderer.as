package flux.components 
{
	public interface IItemRenderer extends IUIComponent
	{
		function set list( value:List ):void
		function get list():List
		function set data( value:Object ):void
		function get data():Object
		function set selected( value:Boolean ):void
		function get selected():Boolean
	}
	
}