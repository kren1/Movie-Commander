package model
{
  public class DropboxClient
  {
    private static var _instance:DropboxClient;
    
    public function DropboxClient()
    {
      
    }
    public static function getInstance():DropboxClient
    {
      if( _instance == null )
      {
        _instance = new DropboxClient(new SingletonEnforcer());
      }
      return _instance;
    }
  }
}
class SingletonEnforcer{}