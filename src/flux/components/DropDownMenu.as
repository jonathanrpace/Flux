package flux.components 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flux.data.ArrayCollection;
	import flux.events.SelectEvent;
	import flux.skins.DropDownMenuSkin;
	import flux.components.DropDownListItemRenderer;
	
	public class DropDownMenu extends UIComponent 
	{
		// Child elements
		protected var skin				:MovieClip;
		protected var labelField		:TextField;
		protected var list				:List;
		
		// Settable properties
		protected var _maxVisibleItems	:int = 8;
		protected var _dataProvider		:ArrayCollection;
		protected var _selectedItem		:Object;
		
		// Internal vars
		protected var buttonWidth	:int;
		
		
		
		
		
		public function DropDownMenu() 
		{
			
		}
		
		override protected function init():void
		{
			skin = new DropDownMenuSkin();
			addChild(skin);
			
			buttonWidth = skin.width - skin.scale9Grid.right;
			
			_height = skin.height;
			_width = skin.width;
			
			labelField = new TextField();
			labelField.defaultTextFormat = new TextFormat( Style.fontFace, Style.fontSize, Style.fontColor );
			labelField.selectable = false;
			labelField.autoSize = TextFieldAutoSize.NONE;
			labelField.multiline = false;
			labelField.mouseEnabled = false;
			labelField.text = "Label Label Label Label"
			addChild( labelField );
			
			skin.addEventListener( MouseEvent.ROLL_OVER, rollOverSkinHandler );
			skin.addEventListener( MouseEvent.ROLL_OUT, rollOutSkinHandler );
			skin.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownSkinHandler );
			
			list = new List();
			list.itemRendererClass = DropDownListItemRenderer;
			list.allowMultipleSelection = false;
			list.clickSelect = true;
			list.addEventListener( SelectEvent.SELECT, listSelectHandler );
		}
		
		override protected function validate():void
		{
			skin.width = _width;
			skin.height = _height;
			
			labelField.x = 4;
			labelField.width = _width - (buttonWidth + 4);
			labelField.height = Math.min(labelField.textHeight + 4, _height);
			labelField.y = (_height - (labelField.height)) >> 1;
			
			var pt:Point = new Point( 0, _height );
			pt = localToGlobal(pt);
			list.x = pt.x;
			list.y = pt.y;
			list.width = _width;
			updateListHeight();
			list.validateNow();
			
			if ( list.visible )
			{
				stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownStageHandler );
			}
		}
		
		protected function updateListHeight():void
		{
			if ( list.stage == null ) return;
			
			var maxHeight:int = _maxVisibleItems * list.itemRendererHeight + list.paddingTop + list.paddingBottom;
			var currentHeight:int = _dataProvider.length * list.itemRendererHeight + list.paddingTop + list.paddingBottom;
			list.height = Math.min( maxHeight, currentHeight );
		}
		
		protected function updateLabel():void
		{
			if ( selectedItem == null )
			{
				labelField.text = "";
			}
			else
			{
				labelField.text = list.dataDescriptor.getLabel( selectedItem );
			}
		}
		
		public function set selectedItem( value:Object ):void
		{
			if ( value == _selectedItem ) return;
			_selectedItem = value;
			updateLabel();
		}
		
		public function get selectedItem():Object
		{
			return _selectedItem;
		}
		
		public function set dataProvider( value:ArrayCollection ):void
		{
			_dataProvider = value;
			list.dataProvider = _dataProvider;
			// Auto-select the first item
			_selectedItem = (_dataProvider != null && _dataProvider.length > 0) ? _dataProvider[0] : null;
			updateLabel();
		}
		
		public function get dataProvider():ArrayCollection
		{
			return _dataProvider;
		}
		
		public function set maxVisibleItems( value:int )
		{
			if ( value == _maxVisibleItems ) return;
			_maxVisibleItems = value;
			updateListHeight();
		}
		
		public function get maxVisibleItems():int
		{
			return _maxVisibleItems;
		}
		
		protected function openList():void
		{
			if ( list.stage ) return;
			stage.addChild(list);
			invalidate();
		}
		
		protected function closeList():void
		{
			if ( list.stage == null ) return;
			stage.removeChild(list);
			list.selectedItems = [];
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownStageHandler );
		}
		
		protected function listSelectHandler( event:SelectEvent ):void
		{
			_selectedItem = event.selectedItem;
			dispatchEvent( new SelectEvent( SelectEvent.SELECT, selectedItem ) );
			updateLabel();
			closeList();
		}
		
		protected function rollOverSkinHandler( event:MouseEvent ):void
		{
			skin.gotoAndPlay("Over");
		}
		
		protected function rollOutSkinHandler( event:MouseEvent ):void
		{
			skin.gotoAndPlay("Out");
		}
		
		protected function mouseDownSkinHandler( event:MouseEvent ):void
		{
			skin.gotoAndPlay("Down");
			openList();
		}
		
		protected function mouseDownStageHandler( event:MouseEvent ):void
		{
			if ( list.hitTestPoint( stage.mouseX, stage.mouseY ) ) return;
			closeList();
		}
	}

}