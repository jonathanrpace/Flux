/**
 * IUIComponent.as
 * 
 * Copyright (c) 2011 Jonathan Pace
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package flux.components 
{
	import flash.events.IEventDispatcher;
	public interface IUIComponent extends IEventDispatcher
	{
		function set x( value:Number ):void;
		function get x():Number;
		function set y( value:Number ):void;
		function get y():Number;
		function set label( value:String ):void;
		function get label():String;
		function set toolTip( value:String ):void;
		function get toolTip():String;
		function set icon( value:Class ):void;
		function get icon():Class;
		function set width( value:Number ):void;
		function get width():Number;
		function set height( value:Number ):void;
		function get height():Number;
		function set enabled( value:Boolean ):void;
		function get enabled():Boolean;
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