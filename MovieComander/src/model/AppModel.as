package model
{ 
  import com.cartoonsmart.other.ErrorPop;
  import com.casrtoonsmart.Camera_Tutorial.MySocket;
  
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.utils.ByteArray;
  import flash.utils.Timer;
  
  import mx.core.FlexGlobals;
  import mx.managers.PopUpManager;
  import mx.resources.IResourceManager;
  import mx.resources.ResourceManager;
  
  import other.ComCommands;
  
  import slike.dir;
  import slike.file;
  import slike.movie;
  import slike.sub;
  import slike.text;
  
  import spark.components.BusyIndicator;
  import spark.components.View;
  import spark.components.ViewNavigator;
  
  import views.Intro;
  import views.MovieComanderHomeView;
  import views.MoviePlaying;
  import views.Options;
  import views.SubListSelector;
  

  [Bindable]
  public final class AppModel extends MySocket
  {
    import mx.collections.ArrayCollection;
    
    private static var _instance:AppModel;
    
    public function AppModel(singeltonEfnrocer:SingletonEnforcer)
    {
      addEvents(socket);
      socket.timeout = 3000;
      ReciveFunction = AllRecived;
    }
    
    public static function getInstance():AppModel
    {
      if( _instance == null )
      {
        _instance = new AppModel(new SingletonEnforcer());
      }
      return _instance;
    }
    
    
    public var mpcSel:Boolean = false;
    public var LangsSupported:ArrayCollection = new ArrayCollection([
      {lang:"English", Status: true, id: "2"},
      {lang:"Deutsch", Status: false, id: "5"},
      {lang:"Français", Status: false, id: "8"},
      {lang:"Slovenščina", Status: false, id: "1"},
      {lang:"Srpski", Status: false, id: "36"},
      {lang:"Hrvatski", Status: false, id: "38"},
      {lang:"Español", Status: false, id: "28"},
      {lang:"Italiano", Status: false, id: "9"},
      {lang:"Россию", Status: false, id: "27"},
      {lang:"Hànyǔ", Status: false, id: "17"},
      {lang:"hangug-eo", Status: false, id: "4"},
      {lang:"Nederlandse", Status: false, id: "23"},
      {lang:"Ελληνικά", Status: false, id: "16"}]);
    public var FileList:ArrayCollection = new ArrayCollection();
    private var ba:ByteArray = new ByteArray();
    public var nav:ViewNavigator;
    public var currentDir:String = "";
    private var SubList:ArrayCollection = new ArrayCollection();
    public var NfoName:String;
    public var NowPlaying:String;
    public var err:ErrorPop;
    public var mpc_on:Boolean = false;
    public var MovieLen:int = -1;
    public var scrolPos:Object = new Object();
    private var bi:BusyIndicator = new BusyIndicator();
    
    private var rm:IResourceManager = ResourceManager.getInstance();
    
    public var CurrentTime:int = 0;
    
    override protected function fCon(e:Event):void
    {
      SendLangsId();
     // CloseBusy();
    }
    public function ShowBusy():void
    {
      PopUpManager.addPopUp(bi,nav,true);
      PopUpManager.centerPopUp(bi);
      bi.height = nav.height;
      bi.width = nav.width;
    }
    public function CloseBusy():void
    {
      PopUpManager.removePopUp(bi);
    }
    public function SendLangsId():void
    {
      ba.clear();
      ba.writeByte(ComCommands.LANGS_REQUESTED);
      for(var i:String in LangsSupported)
      {
        if(LangsSupported[i].Status == true)
          ba.writeObject(LangsSupported[i].id);
      }
      Send(ba);
    }
    public function AddFileListItem(baf:ByteArray):void
    {
      var o:Object;
      while(baf.bytesAvailable != 0)
      {
        o = baf.readObject();
        if(o.dir == true)o.dirIcon = slike.dir;
        else if(o.end == "avi"||o.end == "mp4"||o.end == "mov"||o.end == "mkv"||o.end == "mpg"||o.end == "waw"||o.end == "3gp")o.dirIcon = slike.movie;
        else if(o.end == "srt"||o.end == "sub")o.dirIcon = slike.sub;
        else if(o.end == "nfo" || o.end == "txt")o.dirIcon = slike.text;
        else o.dirIcon = slike.file;
        FileList.addItem(o);
      }
    }
    private function AllRecived(baf:ByteArray):void
    {
      baf.position = 0;
      var cmd:int = baf.readByte();
      
      switch(cmd)
      {
        case ComCommands.ADD_FILE_LIST_ITEM: AddFileListItem(baf);break;
        case ComCommands.FILE_LIST_ITEM_START: FileList.removeAll();currentDir = baf.readUTFBytes(baf.bytesAvailable);if(nav.activeView.className != "MovieComanderHomeView" )nav.pushView(MovieComanderHomeView);break;
        case ComCommands.FILE_LIST_ITEM_STOP:CloseBusy();break;
        case ComCommands.SUB_LIST_START:SubList.removeAll();break;
        case ComCommands.ADD_SUB_LIST_ITEM:SubList.addItem(baf.readObject());break;
        case ComCommands.SUB_LIST_STOP:showSubList();break;
        case ComCommands.SEND_TXT:ProcesTxt(baf);break;
        case ComCommands.NOW_PLAYING:setNowPlaying(baf);break;
        case ComCommands.MPC_ON:mpc_on = baf.readBoolean();break;
        case ComCommands.MOVIE_LENGTH:MovieLen = baf.readInt();break;
        case ComCommands.MOVIE_QUIT:NowPlaying = ""; nav.pushView(MovieComanderHomeView);break;
        case ComCommands.GET_TIME: CurrentTime = baf.readInt();break;
      }
    }
    private function showSubList():void
    {
      CloseBusy();
      nav.popView();
      if(SubList.length > 0)
       nav.pushView(SubListSelector,SubList);
      else
      show(false,"NO_SUBS");
    }
    private function setNowPlaying(baf:ByteArray):void
    {
      var o:Object = baf.readObject();
      NowPlaying = o.file;
      nav.pushView(MoviePlaying);
      CloseBusy();

    }
    private function ProcesTxt(baf:ByteArray):void
    {
      var s:String = baf.readMultiByte(baf.bytesAvailable,"utf-8");
      nav.pushView(Intro,{title:NfoName,text:s,lb:"explicit"});
    }
    public final function show(available:Boolean,msg:String):void
    {
      if(err == null)err = new ErrorPop();
      if(available == false)
      {
        err.open(nav,true);
        err.ErrorMsg.text =  rm.getString('resources',msg)
        PopUpManager.centerPopUp(err);
        
      }
      else
      {
        err.close();
      }
    }
    override protected function fIOError(e:IOErrorEvent):void
    {
      CloseBusy();
      show(false,'CANNOT_CONN');
    }
    override protected function fClose(e:Event):void
    {
      mpc_on = false;
      if(nav != null)
      {
        nav.popAll();
        nav.pushView(Options);
      }
      try
      {
        PopUpManager.removePopUp(bi);
      }
      catch(er:Error)
      {
        trace(er.message + "  fClose");
      }
    }
    
  }
 
}
class SingletonEnforcer{};   