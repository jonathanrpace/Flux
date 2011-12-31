package flux.components 
{
	import flash.events.IEventDispatcher;
	public interface IUIComponent extends IEventDispatcher
	{
		function set x( value:Number ):void;
		function get x():Number;
		function set y( value:Number ):void;
		function get y():Number;
		function set width( value:Number ):void;
		function get width():Number;
		function set height( value:Number ):void;
		function get height():Number;
		function set percentWidth( value:Number ):void;
		function get percentWidth():Number;
		function set percentHeight( value:Number ):void;
		function get percentHeight():Number;
		function set excludeFromLayout( value:Boolean ):void;
		function get excludeFromLayout():Boolean;
		function set resizeToContent( value:Boolean ):void;
		function get resizeToContent():Boolean;
		function validateNow():void;
		function isInvalid():Boolean;
	}
}