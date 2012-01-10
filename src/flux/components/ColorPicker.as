/**
 * Container.as
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
	import adobe.utils.CustomActions;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flux.skins.ColorPickerSkin;
	import flux.skins.ColorPickerColorCursorSkin;
	import flux.skins.ColorPickerBrightnessCursorSkin;
	
	public class ColorPicker extends UIComponent 
	{
		// Styles
		public static var stylePadding				:int = 4;
		public static var styleInnerPadding			:int = 2;
		public static var styleBrightnessSliderWidth:int = 20;
		public static var styleGap					:int = 4;
		
		// Properties
		private var _color					:uint;
		private var _padding				:int = stylePadding;
		private var _innerPadding			:int = styleInnerPadding;
		private var _brightnessSliderWidth	:int = styleBrightnessSliderWidth;
		private var _gap					:int = styleGap;
		
		// Child elements
		private var border					:Sprite;
		private var hueSaturationBorder		:Sprite;
		private var hueSaturationGradient	:Shape;
		private var brightnessBorder		:Sprite;
		private var brightnessGradient		:Shape;
		private var colorCursor				:Sprite;
		private var brightnessCursor		:Sprite;
		private var swatchBorder			:Sprite;
		private var swatch					:Shape;
		private var inputField				:TextInput;
		private var hexLabel				:TextField;
		
		// Internal vars
		private var m						:Matrix;
		private var selectedHue				:Number;
		private var selectedSaturation		:Number;
		private var selectedBrightness		:Number;
		
		public function ColorPicker() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			border = new ColorPickerSkin();
			addChild(border);
			_width = border.width;
			_height = border.height;
			
			hueSaturationBorder = new ColorPickerSkin();
			addChild(hueSaturationBorder);
			hueSaturationGradient = new Shape();
			addChild(hueSaturationGradient);
			brightnessBorder = new ColorPickerSkin();
			addChild(brightnessBorder);
			brightnessGradient = new Shape();
			addChild(brightnessGradient);
			
			colorCursor = new ColorPickerColorCursorSkin();
			colorCursor.blendMode = BlendMode.DIFFERENCE;
			addChild(colorCursor);
			
			brightnessCursor = new ColorPickerBrightnessCursorSkin();
			brightnessCursor.blendMode = BlendMode.DIFFERENCE;
			addChild(brightnessCursor);
			
			var colours:Array = [];
			var ratios:Array = [];
			var alphas:Array = [];
			var numSteps:int = 16;
			for ( var i:int = 0; i < numSteps; i++ )
			{
				var ratio:Number = i / (numSteps - 1);
				var rgb:uint = hsl2rgb(ratio, 1, 0.5);
				colours[i] = rgb;
				ratios[i] = ratio*255;
				alphas[i] = 1;
			}
			
			m = new Matrix();
			m.createGradientBox(100, 100);
			hueSaturationGradient.graphics.beginGradientFill( GradientType.LINEAR, colours, alphas, ratios, m );
			hueSaturationGradient.graphics.drawRect(0, 0, 100, 100);
			
			m.createGradientBox(100, 100, Math.PI*0.5);
			colours = [0x999999, 0x999999];
			ratios = [0, 255];
			alphas = [0, 1];
			hueSaturationGradient.graphics.beginGradientFill( GradientType.LINEAR, colours, alphas, ratios, m );
			hueSaturationGradient.graphics.drawRect(0, 0, 100, 100);
			
			hueSaturationBorder.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownColorAreaHandler);
			brightnessBorder.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownBrightnessAreaHandler);
			
			inputField = new TextInput();
			inputField.maxChars = 6;
			inputField.width = 50;
			inputField.addEventListener(Event.CHANGE, changeInputFieldHandler);
			addChild(inputField);
			
			hexLabel = TextStyles.createTextField();
			hexLabel.text = "#";
			hexLabel.autoSize = TextFieldAutoSize.LEFT;
			addChild(hexLabel);
			
			swatchBorder = new ColorPickerSkin();
			swatchBorder.x = _padding;
			swatchBorder.height = inputField.height;
			addChild(swatchBorder);
			
			swatch = new Shape();
			addChild(swatch);
			
			color = 0xFF0000;
			
			updateInputField();
		}
		
		override protected function validate():void
		{
			border.width = _width;
			border.height = _height;
			
			hueSaturationBorder.x = hueSaturationBorder.y = _padding;
			
			hueSaturationBorder.width = _width - ((_padding << 1) + gap + _brightnessSliderWidth);
			hueSaturationBorder.height = _height - ((_padding << 1) + inputField.height + _gap);
			
			hueSaturationGradient.x = hueSaturationGradient.y = _padding + _innerPadding;
			hueSaturationGradient.width = hueSaturationBorder.width - (_innerPadding * 2);
			hueSaturationGradient.height = hueSaturationBorder.height - (_innerPadding * 2);
			
			brightnessBorder.x = hueSaturationBorder.x + hueSaturationBorder.width + _gap;
			brightnessBorder.y = hueSaturationBorder.y;
			brightnessBorder.width = _width - (brightnessBorder.x + _padding);
			brightnessBorder.height = hueSaturationBorder.height;
			
			brightnessGradient.x = brightnessBorder.x + _innerPadding;
			brightnessGradient.y = brightnessBorder.y + _innerPadding;
			
			var w:int = brightnessBorder.width - _innerPadding * 2;
			var h:int = brightnessBorder.height - _innerPadding * 2;
			m.createGradientBox( w, h, Math.PI*0.5 );
			var ratios:Array = [0, 128, 255];
			var selectedColor:uint = hsl2rgb(selectedHue, 1, 0.5);
			var colors:Array = [0xFFFFFF, selectedColor, 0x000000];
			var alphas:Array = [1, 1, 1];
			brightnessGradient.graphics.clear();
			brightnessGradient.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, m);
			brightnessGradient.graphics.drawRect(0, 0, w, h);
			
			colorCursor.x = int(hueSaturationGradient.x + selectedHue * hueSaturationGradient.width);
			colorCursor.y = int(hueSaturationGradient.y + (1 - selectedSaturation) * hueSaturationGradient.height);
			
			brightnessCursor.x = brightnessGradient.x;
			brightnessCursor.width = brightnessGradient.width
			brightnessCursor.y = brightnessGradient.y + (1-selectedBrightness) * brightnessGradient.height;
			
			inputField.x = _width - _padding - inputField.width;
			inputField.y = brightnessBorder.y + brightnessBorder.height + _gap;
			
			hexLabel.x = inputField.x - hexLabel.width;
			hexLabel.y = inputField.y + (( inputField.height - hexLabel.height ) >> 1);
			
			swatchBorder.y = inputField.y;
			swatchBorder.width = hexLabel.x - _padding * 2;
			
			swatch.x = swatchBorder.x + _innerPadding;
			swatch.y = swatchBorder.y + _innerPadding;
			swatch.graphics.clear();
			var rgb:uint = hsl2rgb( selectedHue, selectedSaturation, selectedBrightness );
			swatch.graphics.beginFill(rgb);
			swatch.graphics.drawRect( 0, 0, swatchBorder.width - _innerPadding * 2, swatchBorder.height - _innerPadding * 2 );
		}
		
		protected function updateInputField():void
		{
			var rgb:uint = hsl2rgb( selectedHue, selectedSaturation, selectedBrightness );
			inputField.text = rgb.toString(16).toUpperCase();
		}
		
		////////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////////
		
		private function mouseDownColorAreaHandler( event:MouseEvent ):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpColorAreaHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveColorAreaHandler);
			mouseMoveColorAreaHandler(null);
		}
		
		private function mouseMoveColorAreaHandler( event:MouseEvent ):void
		{
			var xRatio:Number = hueSaturationGradient.mouseX / hueSaturationGradient.width * hueSaturationGradient.scaleX;
			var yRatio:Number = hueSaturationGradient.mouseY / hueSaturationGradient.height * hueSaturationGradient.scaleY;
			xRatio = xRatio < 0 ? 0 : xRatio > 1 ? 1 : xRatio;
			yRatio = yRatio < 0 ? 0 : yRatio > 1 ? 1 : yRatio;
			
			selectedHue = xRatio;
			selectedSaturation = 1 - yRatio;
			updateInputField();
			invalidate();
		}
		
		private function mouseUpColorAreaHandler( event:MouseEvent ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveColorAreaHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpColorAreaHandler);
		}
		
		private function mouseDownBrightnessAreaHandler( event:MouseEvent ):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpBrightnessAreaHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveBrightnessAreaHandler);
			mouseMoveBrightnessAreaHandler(null);
		}
		
		private function mouseMoveBrightnessAreaHandler( event:MouseEvent ):void
		{
			var yRatio:Number = brightnessGradient.mouseY / brightnessGradient.height * brightnessGradient.scaleY;
			yRatio = yRatio < 0 ? 0 : yRatio > 1 ? 1 : yRatio;
			
			selectedBrightness = 1 - yRatio;
			updateInputField();
			invalidate();
		}
		
		private function mouseUpBrightnessAreaHandler( event:MouseEvent ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveBrightnessAreaHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpBrightnessAreaHandler);
		}
		
		private function changeInputFieldHandler( event:Event ):void
		{
			color = uint( "0x" + inputField.text );
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set color( value:uint ):void
		{
			if ( value == _color ) return;
			_color = value;
			var hsl:Array = rgb2hsl(_color);
			selectedHue = hsl[0];
			selectedSaturation = hsl[1];
			selectedBrightness = hsl[2];
			invalidate();
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set padding( value:int ):void
		{
			if ( _padding == value ) return;
			_padding = value;
			invalidate();
		}
		
		public function get padding():int
		{
			return _padding;
		}
		
		public function set innerPadding( value:int ):void
		{
			if ( _innerPadding == value ) return;
			_innerPadding = value;
			invalidate();
		}
		
		public function get innerPadding():int
		{
			return _innerPadding;
		}
		
		public function set brightnessSliderWidth( value:int ):void
		{
			if ( _brightnessSliderWidth == value ) return;
			_brightnessSliderWidth = value;
			invalidate();
		}
		
		public function get brightnessSliderWidth():int
		{
			return _brightnessSliderWidth;
		}
		
		public function set gap( value:int ):void
		{
			if ( _gap == value ) return;
			_gap = value;
			invalidate();
		}
		
		public function get gap():int
		{
			return _gap;
		}
		
		////////////////////////////////////////////////
		// Private static methods
		////////////////////////////////////////////////
		
		private static function hsl2rgb( H:Number, S:Number, L:Number ):uint
		{
			var r:uint, g:uint, b:uint;
			
			if ( S == 0 )
			{
				r = L * 255;
				g = L * 255;
				b = L * 255;
			}
			else
			{
				var v2:Number = L < 0.5 ? L * ( 1 + S ) : ( L + S ) - ( S * L );
				var v1:Number = 2 * L - v2;
				
				r = 255 * hue2rgb( v1, v2, H + (1 / 3) );
				g = 255 * hue2rgb( v1, v2, H );
				b = 255 * hue2rgb( v1, v2, H - (1 / 3) );
			}
			
			return (r << 16) | (g << 8) | b;
		}
		
		private static function hue2rgb( v1:Number, v2:Number, vH:Number ):Number
		{
			if ( vH < 0 ) vH += 1;
			if ( vH > 1 ) vH -= 1;
			if ( ( 6 * vH ) < 1 ) return ( v1 + ( v2 - v1 ) * 6 * vH )
			if ( ( 2 * vH ) < 1 ) return ( v2 )
			if ( ( 3 * vH ) < 2 ) return ( v1 + ( v2 - v1 ) * ( ( 2 / 3 ) - vH ) * 6 )
			return v1;
		}
		
		private static function rgb2hsl( rgb:uint ):Array
		{
			var r:Number = ((rgb & 0xFF0000) >> 16) / 255;
			var g:Number = ((rgb & 0x00FF00) >> 8) / 255;
			var b:Number = (rgb & 0x0000FF) / 255;
			
			var min:Number = Math.min(r, g, b);
			var max:Number = Math.max(r, g, b);
			var delta:Number = max - min;
			
			var H:Number;
			var S:Number;
			var L:Number = (max + min) / 2;
			
			if ( delta == 0 )
			{
				H = 0;
				S = 0;
			}
			else
			{
				S = L < 0.5 ? delta / ( max + min ) : delta / ( 2 - max - min );
				
				var deltaR:Number = ( ( ( max - r ) / 6 ) + ( delta / 2 ) ) / delta;
				var deltaG:Number = ( ( ( max - g ) / 6 ) + ( delta / 2 ) ) / delta;
				var deltaB:Number = ( ( ( max - b ) / 6 ) + ( delta / 2 ) ) / delta;
				
				if		( r == max ) H = deltaB - deltaG;
				else if ( g == max ) H = ( 1 / 3 ) + deltaR - deltaB;
				else if ( b == max ) H = ( 2 / 3 ) + deltaG - deltaR;
				
				H = H < 0 ? H + 1 : H;
				H = H > 1 ? H - 1 : H;
			}
			
			return [H, S, L];
		}
	}
}