package flux.components 
{
	public interface ITreeItemRenderer extends IItemRenderer
	{
		function set depth( value:int ):void
		function get depth():int
		function set opened( value:Boolean ):void
		function get opened():Boolean
	}
	
}