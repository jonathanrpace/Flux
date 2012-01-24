/**
 * PropertyInspector.as
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
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import flux.data.ArrayCollection;
	import flux.data.PropertyInspectorField;
	import flux.events.ArrayCollectionEvent;
	import flux.events.ItemEditorEvent;
	import flux.events.ListEvent;
	import flux.events.PropertyInspectorEvent;
	import flux.events.ScrollEvent;
	import flux.events.SelectEvent;
	import flux.managers.FocusManager;
	
	[Event( type = "flux.events.PropertyInspectorEvent", name = "commitValue" )]
	public class PropertyInspector extends UIComponent
	{
		// Properties
		private var _dataProvider			:ArrayCollection;
		
		// Child elements
		private var list					:List;
		
		// Internal vars
		private var dataIsInvalid			:Boolean = false;
		private var editorDescriptorTable	:Object;
		private var editor					:UIComponent;
		private var editorDescriptor		:EditorDescriptor;
		private var fieldBeingEdited		:PropertyInspectorField;
		
		public function PropertyInspector()
		{
			
		}
		
		////////////////////////////////////////////////
		// Public methods
		////////////////////////////////////////////////
		
		/**
		 *
		 * @param	id					The id of the editor. This is how the property inspector matches up inspectable properties with an editor.
		 * 								For example, the metatdata
		 * 								[Inspectable(editor="ColorPicker")]
		 * 								Will cause the PropertyInspector to look for a EditorDescriptor with an id =="ColorPicker"
		 * @param	type				The type of the editor.
		 * @param	valueField			The name of the property on the editor that contains the value being edited (eg NumericStepper's is "value"))
		 * @param	labelFunction		(Optional) A function used to transform the value of an object to a string. Defaults to String(value);
		 * @param	itemField			(Optional) The name of the property on the editor that should be set with a reference to the item being edited.
		 * @param	itemPropertyField	(Optional) The name of the property on the editor that should be set with the name of the property on the item being edited .
		 */
		public function registerEditor( id:String, type:Class, valueField:String, labelFunction:Function = null, itemField:String = null, itemPropertyField:String = null ):void
		{
			var descriptor:EditorDescriptor = new EditorDescriptor( id, type, valueField, labelFunction, itemField, itemPropertyField );
			editorDescriptorTable[id] = descriptor;
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			list = new List();
			list.itemRendererClass = PropertyInspectorItemRenderer;
			list.focusEnabled = false;
			addChild(list);
			
			editorDescriptorTable = { };
			registerEditor( "TextInput", TextInput, "text" );
			registerEditor( "NumberInput", NumberInput, "value", numberLabelFunction );
			registerEditor( "DropDownMenu", DropDownMenu, "selectedItem" );
			registerEditor( "NumericStepper", NumericStepper, "value", numberLabelFunction );
			registerEditor( "Slider", HSlider, "value", numberLabelFunction );
			registerEditor( "ColorPicker", ColorPickerItemEditor, "color", hexLabelFunction );
			
			list.addEventListener( ListEvent.ITEM_SELECT, selectListItemHandler );
			list.addEventListener( ScrollEvent.CHANGE_SCROLL, changeListScrollHandler );
		}
		
		private function hexLabelFunction( item:uint ):String
		{
			return "#" + item.toString(16).toUpperCase();
		}
		
		private function numberLabelFunction( item:Number ):String
		{
			var a:Number = 1 / 0.001;
			item = int(item * a) / a;
			return String(item);
		}
		
		override protected function validate():void
		{
			if ( dataIsInvalid )
			{
				validateData();
			}
			
			list.width = _width;
			list.height = _height;
			list.validateNow();
		}
		
		private function validateData():void
		{
			if ( _dataProvider == null || _dataProvider.length == 0 )
			{
				list.dataProvider = new ArrayCollection();
			}
			else
			{
				disposeEditor();
				var fields:Array = getFields( _dataProvider[0] );
				list.dataProvider = new ArrayCollection( fields );
			}
		}
		
		override public function onLoseComponentFocus():void
		{
			commitEditorValue();
			disposeEditor();
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function changeListScrollHandler( event:ScrollEvent ):void
		{
			commitEditorValue();
			disposeEditor();
		}
		
		private function commitValueHandler( event:ItemEditorEvent ):void
		{
			commitEditorValue();
			disposeEditor();
		}
		
		private function selectListItemHandler( event:ListEvent ):void
		{
			var selectedItem:Object = list.selectedItems[0];
			commitEditorValue();
			disposeEditor();
			
			if ( selectedItem is PropertyInspectorField )
			{
				var selectedItemRenderer:PropertyInspectorItemRenderer = PropertyInspectorItemRenderer(list.getItemRendererForData(selectedItem));
				
				fieldBeingEdited = PropertyInspectorField(selectedItem);
				
				editorDescriptor = editorDescriptorTable[fieldBeingEdited.editorID];
				if ( editorDescriptor == null )
				{
					throw( new Error( "Unknown editor id : " + fieldBeingEdited.editorID ) );
					return;
				}
				var editorType:Class = editorDescriptor.type;
				editor = UIComponent( new editorType() );
				
				for ( var editorParameterName:String in fieldBeingEdited.editorParameters )
				{
					editor[editorParameterName] = fieldBeingEdited.editorParameters[editorParameterName];
				}
				
				editor[ editorDescriptor.valueField ] = fieldBeingEdited.value;
				addChild(editor);
				
				var pt:Point = new Point();
				pt = selectedItemRenderer.localToGlobal( pt );
				pt = globalToLocal(pt);
				var rect:Rectangle = selectedItemRenderer.editorRect;
				editor.x = pt.x + rect.x;
				editor.y = pt.y + rect.y;
				editor.width = rect.width;
				editor.height = rect.height;
				FocusManager.setFocus(editor);
				
				editor.addEventListener(ItemEditorEvent.COMMIT_VALUE, commitValueHandler);
			}
			else
			{
				FocusManager.setFocus(this);
			}
		}
		
		private function changeDataProviderHandler( event:ArrayCollectionEvent ):void
		{
			dataIsInvalid = true;
			invalidate();
		}
		
		////////////////////////////////////////////////
		// Private methods
		////////////////////////////////////////////////
		
		private function commitEditorValue():void
		{
			if ( editor == null ) return;
			var value:Object = editor[ editorDescriptor.valueField ];
			
			var event:PropertyInspectorEvent = new PropertyInspectorEvent( PropertyInspectorEvent.COMMIT_VALUE, [fieldBeingEdited.host], fieldBeingEdited.property, value, false, true );
			dispatchEvent(event);
			
			if (event.isDefaultPrevented() == false )
			{
				fieldBeingEdited.value = value;
			}
			
			var itemRenderer:PropertyInspectorItemRenderer = PropertyInspectorItemRenderer(list.getItemRendererForData(fieldBeingEdited));
			if ( itemRenderer != null ) itemRenderer.data = fieldBeingEdited;
		}
		
		private function disposeEditor():void
		{
			if ( !editor ) return;
			
			editor.removeEventListener(ItemEditorEvent.COMMIT_VALUE, commitValueHandler);
			removeChild(editor);
			editor = null;
		}
		
		private function getFields(object:Object):Array
		{
			var description:XML = describeType( object );
			var fields:Array = [];
			
			for each( var node:XML in description.children() )
			{
				if ( node.name() != "accessor" && node.name() != "variable" ) continue;
				var metadata:XML = node.metadata.( @name=="Inspectable" )[0];
				if ( !metadata ) continue;
				
				
				// If the property is an inspectable list, then populate the fields with the children of that list too.
				if ( object[node.@name] is ArrayCollection )
				{
					var collection:ArrayCollection = ArrayCollection(object[node.@name]);
					for ( i = 0; i < collection.length; i++ )
					{
						var child:Object = collection[i];
						fields.push({label:getClassName(child), header:true});
						fields = fields.concat( getFields(child) );
					}
				}
				else
				{
					var field:PropertyInspectorField = new PropertyInspectorField( object, String( node.@name ) );
					
					// Parse each metadata argument into the field
					for ( var i:int = 0; i < metadata.arg.length(); i++ )
					{
						var argNode:XML = metadata.arg[i];
						
						var key:String = String(argNode.@key);
						var value:String = String(argNode.@value);
						
						// 'editorType' is special, and is id for mapping a property to an editor
						if ( key == "editor" )
						{
							field.editorID = value;
						}
						// Everything else gets parsed into the editorParameters object. These
						// values then get passed to the editor when created.
						else
						{
							if ( value.charAt(0) == "[" && value.charAt(value.length-1) == "]" )
							{
								value = value.substr(1, value.length-2);
								field.editorParameters[key] = new ArrayCollection(value.split(","));
							}
							else
							{
								field.editorParameters[key] = value;
							}
						}
					}
									
					if ( field.editorID == null || field.editorID == "")
					{
						if ( field.value is Number )
						{
							field.editorID = "NumberInput";
						}
						else if ( field.value is Boolean )
						{
							field.editorID = "DropDownMenu";
							field.editorParameters.dataProvider = new ArrayCollection([true, false]);
						}
						else
						{
							field.editorID = "TextInput";
						}
					}
					
					var editorDescriptor:EditorDescriptor = editorDescriptorTable[field.editorID];
					if ( editorDescriptor )
					{
						field.labelFunction = editorDescriptor.labelFunction;
					}
					
					fields.push(field);
				}
				
			}
			
			return fields;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		public function set dataProvider( value:ArrayCollection ):void
		{
			if ( _dataProvider )
			{
				_dataProvider.removeEventListener( ArrayCollectionEvent.CHANGE, changeDataProviderHandler );
			}
			_dataProvider = value;
			if ( _dataProvider )
			{
				_dataProvider.addEventListener( ArrayCollectionEvent.CHANGE, changeDataProviderHandler );
			}
			dataIsInvalid = true;
			invalidate();
		}
		
		static private function getClassName( object:Object ):String
		{
			var classPath:String = flash.utils.getQualifiedClassName(object).replace("::",".");
			if ( classPath.indexOf(".") == -1 ) return classPath;
			var split:Array = classPath.split( "." );
			return split[split.length-1];
		}
	}
}

internal class EditorDescriptor
{
	public var id					:String
	public var type					:Class
	public var valueField			:String;
	public var itemField			:String;
	public var itemPropertyField	:String;
	public var labelFunction		:Function;
		
	public function EditorDescriptor( id:String, type:Class, valueField:String, labelFunction:Function = null, itemField:String = null, itemPropertyField:String = null )
	{
		this.id = id;
		this.type =  type;
		this.valueField = valueField;
		this.labelFunction = labelFunction;
		this.itemField = itemField;
		this.itemPropertyField = itemPropertyField;
	}
}
