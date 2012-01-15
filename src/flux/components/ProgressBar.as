/**
 * ProgressBar.as
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
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flux.skins.ProgressBarSkin;
	import flux.skins.ProgressBarBorderSkin;
	import flux.skins.ProgressBarIndeterminateSkin;
	
	public class ProgressBar extends UIComponent 
	{
		// Styles
		public static var styleBorderThickness	:int = 3;
		
		// Properties
		private var _progress			:Number = 0;
		private var _indeterminate		:Boolean = false;
		private var _borderThickness	:int;
		
		// Child elements
		private var border				:Sprite;
		private var bar					:Sprite;
		private var indeterminateBar	:Sprite;
		
		public function ProgressBar() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			border = new ProgressBarBorderSkin();
			addChild(border);
			
			_width = border.width;
			_height = border.height;
			
			bar = new ProgressBarSkin();
			addChild(bar);
			
			indeterminateBar = new ProgressBarIndeterminateSkin();
			addChild(indeterminateBar);
			
			_borderThickness = styleBorderThickness;
			
			indeterminate = false;
		}
		
		override protected function validate():void
		{
			bar.visible = !_indeterminate;
			indeterminateBar.visible = _indeterminate;
			
			border.width = _width;
			border.height = _height;
			
			bar.x = bar.y = indeterminateBar.x = indeterminateBar.y = _borderThickness;
			indeterminateBar.width = _width - (_borderThickness << 1);
			bar.height = indeterminateBar.height = _height - (_borderThickness << 1);
			
			bar.width = _progress * indeterminateBar.width;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set progress( v:Number ):void
		{
			v = v < 0 ? 0 : v > 1 ? 1 : v;
			if ( v == _progress ) return;
			_progress = v;
			invalidate();
		}
		
		public function get progress():Number
		{
			return _progress;
		}
		
		public function set indeterminate( v:Boolean ):void
		{
			if ( _indeterminate == v ) return;
			_indeterminate = v;
			invalidate();
		}
		
		public function get indeterminate():Boolean
		{
			return _indeterminate;
		}
	}

}