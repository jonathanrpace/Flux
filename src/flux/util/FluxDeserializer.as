package flux.util 
{
	import flash.utils.getDefinitionByName;
	import flux.components.Canvas;
	import flux.components.CheckBox;
	import flux.components.DropDownMenu;
	import flux.components.HBox;
	import flux.components.InputField;
	import flux.components.MenuBar;
	import flux.components.NumericStepper;
	import flux.components.PushButton;
	import flux.components.ScrollCanvas;
	import flux.components.TabNavigator;
	import flux.components.Tree;
	import flux.components.UIComponent;
	import flux.components.VBox;
	import flux.layouts.HorizontalLayout;
	import flux.layouts.ILayout;
	import flux.layouts.VerticalLayout;
	
	public class FluxDeserializer 
	{
		public static function deserialize( xml:XML, topLevel:Canvas ):UIComponent
		{
			return parseComp( xml, topLevel, null, topLevel );
		}
		
		private static function parseComp( xml:XML, topLevel:Canvas, parent:Canvas = null, instance:UIComponent = null ):UIComponent
		{
			if ( instance == null )
			{
				var nodeName:String = xml.name();
				var type:Class = Class(getDefinitionByName( "flux.components." + nodeName ));
				instance = new type();
			}
			
			if ( topLevel == null )
			{
				topLevel = instance as Canvas;
			}
			
			parseAttributes(xml, instance, topLevel);
			
			if ( parent )
			{
				parent.addChild(instance);
			}
			
			if ( instance is Canvas )
			{
				var canvas:Canvas = Canvas(instance);
				
				var childNodes:XMLList = xml.children();
				for ( var i:int = 0; i < childNodes.length(); i++ )
				{
					var childNode:XML = childNodes[i];
					var childNodeName:String = childNode.name();
					
					// Handle non-child component nodes
					if ( childNodeName == "layout" )
					{
						var layoutInstanceNode:XML = childNode.children()[0];
						var layoutType:Class = Class(getDefinitionByName( "flux.layouts." + layoutInstanceNode.name() ));
						var layoutInstance:ILayout = new layoutType();
						parseAttributes( childNode, layoutInstance, topLevel );
						canvas.layout = layoutInstance;
					}
					// Assume it's a child component
					else
					{
						parseComp( childNode, topLevel, canvas );
					}
				}
			}
			
			return instance;
		}
		
		private static function parseAttributes( xml:XML, instance:Object, topLevel:Canvas ):void
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
		DropDownMenu;
		HBox;
		HorizontalLayout;
		InputField;
		NumericStepper;
		MenuBar;
		ScrollCanvas;
		TabNavigator;
		Tree;
		VBox;
		VerticalLayout;
	}

}