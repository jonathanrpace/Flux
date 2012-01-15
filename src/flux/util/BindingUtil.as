/**
 * BindingUtil.as
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

package flux.util 
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import flux.events.PropertyChangeEvent;
	public class BindingUtil 
	{
		private static var propertiesForSourceTable	:Dictionary = new Dictionary(true);
		
		private static var ignoreObject:Object;
		private static var ignoreProperty:String;
		
		public static function bind( source:IEventDispatcher, sourceProperty:String, target:Object, targetProperty:String, handler:Function = null ):void
		{
			var propertiesForThisSource:Object = propertiesForSourceTable[source];
			if ( propertiesForThisSource == null )
			{
				propertiesForThisSource = propertiesForSourceTable[source] = new Dictionary(true);
			}
			
			var targetDataForThisPropertyOnThisSource:Array = propertiesForThisSource[sourceProperty];
			if ( targetDataForThisPropertyOnThisSource == null )
			{
				targetDataForThisPropertyOnThisSource = propertiesForThisSource[sourceProperty] = [];
				source.addEventListener( "propertyChange_" + sourceProperty, propertyChangeHandler, false, 0, true );
			}
			targetDataForThisPropertyOnThisSource.push( {target:target, targetProperty:targetProperty, handler:handler} );
			
			target[targetProperty] = source[sourceProperty];
		}
		
		public static function bindTwoWay( objectA:IEventDispatcher, propertyA:String, objectB:IEventDispatcher, propertyB:String ):void
		{
			bind(objectA, propertyA, objectB, propertyB);
			bind(objectB, propertyB, objectA, propertyA);
		}
		
		public static function unbind( source:IEventDispatcher, sourceProperty:String, target:Object, targetProperty:String ):void
		{
			var propertiesForThisSource:Object = propertiesForSourceTable[source];
			if ( propertiesForThisSource == null ) return;
			
			var targetDataForThisPropertyOnThisSource:Array = propertiesForThisSource[sourceProperty];
			if ( targetDataForThisPropertyOnThisSource == null ) return;
			
			for ( var i:int = 0; i < targetDataForThisPropertyOnThisSource.length; i++ )
			{
				var targetData:Object = targetDataForThisPropertyOnThisSource[i];
				if ( targetData.target == target && targetData.targetProperty == targetProperty )
				{
					targetDataForThisPropertyOnThisSource.splice(i, 1);
					i--;
				}
			}
			
			if ( targetDataForThisPropertyOnThisSource.length == 0 )
			{
				propertiesForThisSource[sourceProperty] = null;
				source.removeEventListener( "propertyChange_" + sourceProperty, propertyChangeHandler );
			}
		}
		
		public static function unbindTwoWay( objectA:IEventDispatcher, propertyA:String, objectB:IEventDispatcher, propertyB:String ):void
		{
			unbind(objectA, propertyA, objectB, propertyB);
			unbind(objectB, propertyB, objectA, propertyA);
		}
		
		private static function propertyChangeHandler( event:PropertyChangeEvent ):void
		{
			if ( event.target == ignoreObject && event.propertyName == ignoreProperty ) return;
			
			var propertiesForThisSource:Object = propertiesForSourceTable[event.target];
			var targetDataForThisPropertyOnThisSource:Object = propertiesForThisSource[event.propertyName];
			for each ( var targetData:Object in targetDataForThisPropertyOnThisSource )
			{
				ignoreObject = targetData.target;
				ignoreProperty = targetData.targetProperty;
				targetData.target[targetData.targetProperty] = event.newValue;
				ignoreObject = ignoreProperty = null
			}
			
			if ( targetDataForThisPropertyOnThisSource.handler )
			{
				targetDataForThisPropertyOnThisSource.handler(event);
			}
		}
	}
}