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
		
		// This number is incremented each time we enter this function, and decremented when we leave.
		// Because we may set a property that ends up calling this handler during a previous call, this number
		// will reflect the length of the binding chain.
		// We keep track of which objects we've already set which proeprties on, to protect against infinite loops.
		// This table is cleared when the depth == 0 when exiting, as by this point we will have visited every object
		// affected by the property change.
		private static var depth:int;
		private static var visitedObjects:Dictionary;
		private static function propertyChangeHandler( event:PropertyChangeEvent ):void
		{
			if ( visitedObjects == null )
			{
				visitedObjects = new Dictionary(true);
				depth = 0;
			}
			
			depth++;
			
			var propertiesForThisSource:Object = propertiesForSourceTable[event.target];
			var targetDataForThisPropertyOnThisSource:Object = propertiesForThisSource[event.propertyName];
			for each ( var targetData:Object in targetDataForThisPropertyOnThisSource )
			{
				var setProperties:Object = visitedObjects[targetData.target];
				if ( setProperties == null )
				{
					setProperties = visitedObjects[targetData.target] = {};
				}
				
				if ( setProperties[targetData.targetProperty] )
				{
					continue;
				}
				
				setProperties[targetData.targetProperty] = true;
				targetData.target[targetData.targetProperty] = event.newValue;
			}
			
			if ( targetDataForThisPropertyOnThisSource.handler )
			{
				targetDataForThisPropertyOnThisSource.handler(event);
			}
			depth--;
			
			if ( depth == 0 )
			{
				visitedObjects = new Dictionary(true);
			}
		}
	}
}