/**
 * DefaultDataDescriptor.as
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
	public class DefaultDataDescriptor implements IDataDescriptor 
	{
		public var labelField		:String = "label";
		public var iconField		:String = "icon";
		public var enabledField		:String = "enabled";
		
		public function DefaultDataDescriptor() 
		{
			
		}
		
		public function getLabel(data:Object):String 
		{
			if ( data.hasOwnProperty(labelField) )
			{
				return String(data[labelField]);
			}
			return String(data);
		}
		
		public function getIcon(data:Object):Class 
		{
			if ( data.hasOwnProperty(iconField) )
			{
				return data[iconField];
			}
			return null;
		}
		
		public function getEnabled(data:Object):Boolean 
		{
			if ( data.hasOwnProperty(enabledField) )
			{
				return data[enabledField];
			}
			return true;
		}
		
		public function hasChildren(data:Object):Boolean 
		{
			return data.children != null;
		}
		
		public function getChildren(data:Object):ArrayCollection 
		{
			return data.children;
		}
	}
}