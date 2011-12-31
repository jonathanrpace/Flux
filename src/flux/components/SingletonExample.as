package flux.components 
{
	public class SingletonExample 
	{
		public static var instance	:SingletonExample = new SingletonExample();
		
		public function SingletonExample() 
		{
			if ( instance )
			{
				throw( new Error() );
			}
			
			instance = this;
		}
		
	}

}