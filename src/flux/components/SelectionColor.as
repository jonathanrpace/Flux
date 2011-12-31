package flux.components
{
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	public class SelectionColor
	{
		public static function setFieldSelectionColor( field:TextField, color:uint ):void
		{
			field.backgroundColor = invert( field.backgroundColor );
			field.borderColor = invert( field.borderColor );
			field.textColor = invert( field.textColor );
				
			var colorTrans:ColorTransform = field.transform.colorTransform;
			colorTrans.color = color;
			colorTrans.redMultiplier = -1;
			colorTrans.greenMultiplier = -1;
			colorTrans.blueMultiplier = -1;
			field.transform.colorTransform = colorTrans;
		}
		
		protected static function invert( color:uint ):uint
		{
			var colorTrans:ColorTransform = new ColorTransform();
			colorTrans.color = color;
			
			return invertColorTransform( colorTrans ).color;
		}
		
		protected static function invertColorTransform( colorTrans:ColorTransform ):ColorTransform
		{
			with( colorTrans )
			{
				redMultiplier = -redMultiplier;
				greenMultiplier = -greenMultiplier;
				blueMultiplier = -blueMultiplier;
				redOffset = 255 - redOffset;
				greenOffset = 255 - greenOffset;
				blueOffset = 255 - blueOffset;
			}
			
			return colorTrans;
		}
		
	}
	
}