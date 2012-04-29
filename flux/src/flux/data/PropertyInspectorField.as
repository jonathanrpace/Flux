/**
 * PropertyInspectorField.as
 * 
 * Used internally by the PropertyInspector control. Should not be created outside this scope.
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

package flux.data 
{
	public class PropertyInspectorField
	{
		public var host				:Object;		// The owner of the property
		public var property			:String;		// The name of the property on the host
		
		public var editorID			:String;
		public var editorParameters	:Object;
		public var labelFunction	:Function;
		
		
		public function PropertyInspectorField( host:Object = null, property:String = null )
		{
			editorParameters = {};
			this.host = host;
			this.property = property;
		}
		
		public function get valueLabel():String
		{
			if ( labelFunction != null )
			{
				return labelFunction( value, host, property );
			}
			else
			{
				return String(value);
			}
		}
		
		public function set value( v:* ):void
		{
			host[property] = v;
		}
		public function get value():*
		{ 
			return host[property]; 
		}
	}

}