package flux.layouts 
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	public interface ILayout 
	{
		function layout( content:DisplayObjectContainer, visibleWidth:Number, visibleHeight:Number, allowProportional:Boolean = true ):Rectangle
	}
}