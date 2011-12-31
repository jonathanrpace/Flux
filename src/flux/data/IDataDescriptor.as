package flux.data 
{
	public interface IDataDescriptor 
	{
		function getLabel( data:Object ):String
		function getIcon( data:Object ):Class
		function hasChildren( data:Object ):Boolean
		function getChildren( data:Object ):ArrayCollection;
	}
}