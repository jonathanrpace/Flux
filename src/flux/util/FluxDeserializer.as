/**
 * FluxDeserializer.as
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
	import flash.utils.getDefinitionByName;
	import flux.components.*;
	import flux.layouts.*;
	
	public class FluxDeserializer 
	{
		public static function deserialize( xml:XML, topLevel:Container ):UIComponent
		{
			return parseComp( xml, topLevel, null, topLevel );
		}
		
		private static function parseComp( xml:XML, topLevel:Container, parent:Container = null, instance:UIComponent = null ):UIComponent
		{
			if ( instance == null )
			{
				var nodeName:String = xml.name();
				var type:Class = Class(getDefinitionByName( "flux.components." + nodeName ));
				instance = new type();
			}
			
			if ( topLevel == null )
			{
				topLevel = instance as Container;
			}
			
			parseAttributes(xml, instance, topLevel);
			
			if ( parent && instance.stage == null )
			{
				parent.addChild(instance);
			}
			
			if ( instance is Container )
			{
				var container:Container = Container(instance);
				
				var childNodes:XMLList = xml.children();
				for ( var i:int = 0; i < childNodes.length(); i++ )
				{
					var childNode:XML = childNodes[i];
					var childNodeName:String = childNode.name();
					
					if ( container.hasOwnProperty(childNodeName) )
					{
						if ( container[childNodeName] is ILayout )
						{
							var layoutInstanceNode:XML = childNode.children()[0];
							var layoutType:Class = Class(getDefinitionByName( "flux.layouts." + layoutInstanceNode.name() ));
							var layoutInstance:ILayout = new layoutType();
							parseAttributes( childNode, layoutInstance, topLevel );
							container.layout = layoutInstance;
							continue;
						}
						else if ( container[childNodeName] is Container )
						{
							parseComp( childNode, topLevel, null, container[childNodeName] );
							continue;
						}
					}
					// Assume it's a child component
					parseComp( childNode, topLevel, container );
				}
			}
			
			return instance;
		}
		
		private static function parseAttributes( xml:XML, instance:Object, topLevel:Container ):void
		{
			for each ( var attribute:XML in xml.attributes() )
			{
				var prop:String = attribute.name();
				var value:String = String(attribute);
				
				if ( prop == "id" )
				{
					topLevel[value] = instance;
					continue;
				}
				
				// Handle special case of width="100%" syntax
				if ( prop == "width" || prop == "height" )
				{
					if ( value.charAt(value.length - 1) == "%" )
					{
						instance[prop == "width"?"percentWidth":"percentHeight"] = Number( value.substring(0, value.length - 1 ) );
					}
					else
					{
						instance[prop] = Number(value);
					}
				}
				
				else if ( instance[prop] is Boolean )
				{
					instance[prop] = value == "true";
				}
				else if ( instance[prop] is Number )
				{
					instance[prop] = Number(value);
				}
				else
				{
					try
					{
						var definition:Class = getDefinitionByName( value ) as Class;
						instance[prop] = definition;
					}
					catch ( e:Error )
					{
						instance[prop] = value;
					}
				}
			}
		}
		
		CheckBox;
		ColorPicker;
		DropDownMenu;
		HBox;
		HorizontalLayout;
		InputField;
		NumericStepper;
		MenuBar;
		Panel;
		ProgressBar;
		PropertyInspector;
		RadioButton;
		RadioButtonGroup;
		ScrollPane;
		TabNavigator;
		Tree;
		VBox;
		VerticalLayout;
	}

}