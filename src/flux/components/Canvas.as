package flux.components 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flux.layouts.AbsoluteLayout;
	import flux.layouts.ILayout;
	import flux.skins.CanvasSkin;
	
	public class Canvas extends UIComponent 
	{
		// Child elements
		protected var background		:Sprite;
		protected var content			:Sprite;
		
		// Properties
		protected var _paddingLeft		:int = 0;
		protected var _paddingRight		:int = 0;
		protected var _paddingTop		:int = 0;
		protected var _paddingBottom	:int = 0;
		protected var _layout			:ILayout;
		
		public function Canvas() 
		{
			
		}
		
		override protected function init():void
		{
			_layout = new AbsoluteLayout();
			
			background = new CanvasSkin();
			background.visible = false;
			addRawChild(background);
			
			_width = 100;
			_height = 100;
			
			content = new Sprite();
			content.scrollRect = new Rectangle();
			addRawChild(content);
			
			content.addEventListener( Event.RESIZE, resizeHandler );
		}
		
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			content.addChildAt(child, index);
			invalidate();
			onChildrenChanged( UIComponent(child), index, true );
			return child;
		}
		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			content.addChild(child);
			invalidate();
			onChildrenChanged( UIComponent(child), content.numChildren-1, true );
			return child;
		}
		
		public override function removeChildAt(index:int):DisplayObject
		{
			invalidate();
			var child:DisplayObject = content.removeChildAt(index);
			onChildrenChanged( UIComponent(child), index, false );
			return child;
		}
		
		public override function removeChild(child:DisplayObject):DisplayObject
		{
			var index:int = content.getChildIndex(child);
			content.removeChild(child);
			invalidate();
			onChildrenChanged( UIComponent(child), index, false );
			return child;
		}
		
		protected function onChildrenChanged( child:UIComponent, index:int, added:Boolean ):void {}
		
		public override function getChildAt( index:int ):DisplayObject
		{
			return content.getChildAt(index);
		}
		
		public override function getChildIndex( child:DisplayObject ):int
		{
			return content.getChildIndex(child);
		}
		
		public override function get numChildren():int
		{
			return content.numChildren;
		}
		
		public function addRawChild(child:DisplayObject):DisplayObject
		{
			super.addChild(child);
			return child;
		}
		
		override protected function validate():void
		{
			var layoutArea:Rectangle = getChildrenLayoutArea();
			
			if ( _resizeToContent )
			{
				var contentSize:Rectangle = _layout.layout( content, layoutArea.width, layoutArea.height, false );
				_width = contentSize.width + _paddingLeft + _paddingRight;
				_height = contentSize.width + _paddingTop + _paddingBottom;
				layoutArea.width = contentSize.width;
				layoutArea.height = contentSize.height;
			}
			else
			{
				_layout.layout( content, layoutArea.width, layoutArea.height, true );
			}
			
			content.x = layoutArea.x;
			content.y = layoutArea.y;
			
			var scrollRect:Rectangle = content.scrollRect;
			scrollRect.width = layoutArea.width;
			scrollRect.height = layoutArea.height;
			content.scrollRect = scrollRect;
			
			background.width = _width;
			background.height = _height;
		}
		
		protected function getChildrenLayoutArea():Rectangle
		{
			return new Rectangle( _paddingLeft, _paddingTop, _width - (_paddingRight+_paddingLeft), _height - (_paddingBottom+_paddingTop) );
		}
		
		public function set padding( value:int ):void
		{
			_paddingLeft = _paddingRight = _paddingTop = _paddingBottom = value;
			invalidate();
		}
		
		public function get padding():int
		{
			return _paddingLeft;
		}
		
		public function set paddingLeft( value:int ):void
		{
			_paddingLeft = value;
			invalidate();
		}
		
		public function get paddingLeft():int
		{
			return _paddingLeft;
		}
		
		public function set paddingRight( value:int ):void
		{
			_paddingRight = value;
			invalidate();
		}
		
		public function get paddingRight():int
		{
			return _paddingRight;
		}
		
		public function set paddingTop( value:int ):void
		{
			_paddingTop = value;
			invalidate();
		}
		
		public function get paddingTop():int
		{
			return _paddingTop;
		}
		
		public function set paddingBottom( value:int ):void
		{
			_paddingBottom = value;
			invalidate();
		}
		
		public function get paddingBottom():int
		{
			return _paddingBottom;
		}
		
		public function set showBackground( value:Boolean ):void
		{
			background.visible = value;
		}
		
		public function get showBackground()
		{
			return background.visible;
		}
		
		public function set layout( value:ILayout ):void
		{
			_layout = value;
			if ( _layout )
			{
				invalidate();
			}
		}
		public function get layout():ILayout
		{
			return _layout;
		}
		
		private function resizeHandler( event:Event ):void
		{
			if ( event.target.parent == content )
			{
				invalidate();
			}
		}
	}
}