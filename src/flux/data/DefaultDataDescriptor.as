package flux.data 
{
	public class DefaultDataDescriptor implements IDataDescriptor 
	{
		public function DefaultDataDescriptor() 
		{
			
		}
		
		public function getLabel(data:Object):String 
		{
			if ( data is String ) return String(data);
			return data.label;
		}
		
		public function getIcon(data:Object):Class 
		{
			if ( data.hasOwnProperty("icon") )
			{
				return data.icon;
			}
			return null;
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