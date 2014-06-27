package com.cartoonsmart.other
{
  import com.cartoonsmart.Camera_Tutorial.MySocket;
  import com.cartoonsmart.Events.PlayerStartedEvent;
  import com.cartoonsmart.Events.SubtitleEvent;
  import com.cartoonsmart.Events.TimeRecEvent;
  import com.cartoonsmart.dto.Player_dto;
  import com.cartoonsmart.subtitles.Subtitles;
  
  import flash.errors.IOError;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.FileListEvent;
  import flash.events.ServerSocketConnectEvent;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.net.NetworkInfo;
  import flash.net.NetworkInterface;
  import flash.net.ServerSocket;
  import flash.system.Capabilities;
  import flash.utils.ByteArray;
  
  import mx.collections.ArrayCollection;
  import mx.controls.FileSystemList;
  import mx.events.FileEvent;
  import mx.utils.ArrayUtil;
  
  import other.ComCommands;
  
  import spark.collections.Sort;
  import spark.collections.SortField;
  
  
  public final class MovieComunicator extends MySocket
  {
    private var serverSocket:ServerSocket = new ServerSocket();
    private var subCenterRef:Subtitles;
    private var fileList:FileSystemList;
    private var P_dto_Ref:Player_dto;
    public var nativeHandler:NativeAppsHandler = new NativeAppsHandler();
    private var currentlzPlayin:String = "";
    
    public var Dvd:Boolean = false;
    
    public function MovieComunicator(subref:Subtitles, fl:FileSystemList,player_select:Player_dto)
    {
      super();
      ReciveFunction = allDataRecived;
      subCenterRef = subref;
      fileList = fl;
      P_dto_Ref = player_select; 
      AddEventListneres();
    }
    protected function AddEventListneres():void
    {
      nativeHandler.addEventListener(NativeAppsHandler.PLAYER_EXITED,player_quit);
      nativeHandler.addEventListener(PlayerStartedEvent.PLAYER_STARTED,player_started);
      nativeHandler.addEventListener(TimeRecEvent.TIME_REC,time_rec);
    }
    public function InitateSeqence():void
    {
      serverSocket  = new ServerSocket();
      serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT,Connected)
      try
      {
        serverSocket.bind(8000);
        serverSocket.listen();
      }
      catch(e:IOError)
      {
        trace(e.message);
      }
      
    }
    private function Connected(e:ServerSocketConnectEvent):void
    {
      socket = e.socket;
      addEvents(socket);
      serverSocket.close();
      serverSocket.removeEventListener(ServerSocketConnectEvent.CONNECT,Connected);
      serverSocket = null;
      SendFileList(fileList.dataProvider as ArrayCollection);
      
    }
    // ================================================================== SWITCH ====================================================================================
    //===============================================================================================================================================================
    private function allDataRecived(ba:ByteArray):void
    {
      if(ba.length > 0)
      {
        ba.position = 0;
        var cmd:int = ba.readByte();
        
        switch(cmd)
        {
          case ComCommands.LANGS_REQUESTED: ParseLangsReq(ba);break;
          case ComCommands.DIR_BACK:if(fileList.canNavigateUp)fileList.navigateUp();fileList.refresh();SendFileList(fileList.dataProvider as ArrayCollection);break;
          case ComCommands.NAVIGATE:navigate(ba);break;
          case ComCommands.REQUEST_SUB:handleSubReq(ba);break;
          case ComCommands.PLAY_WITH_SUBS: PlayWithSubs(ba);break;
          case ComCommands.PLAY_WITOUT_SUBS: PlayWithOutSubs(ba);break;
          case ComCommands.SET_PLAYER: P_dto_Ref.PlayerBool = ba.readBoolean(); break;
          case ComCommands.PLAY_DVD:PlayWithOutSubs(ba);Dvd = true;nativeHandler.dispatchEvent(new PlayerStartedEvent(PlayerStartedEvent.PLAYER_STARTED,-1));break;
          case ComCommands.MOUSE:MoveMouse(ba);break;
          case ComCommands.GET_TXT: StreamText(ba);break;
          case ComCommands.PAUSE_MOVIE:nativeHandler.sendCommand(NativeAppsHandler.PAUSE); break;
          case ComCommands.CLOSE_PLAYER:nativeHandler.sendCommand(NativeAppsHandler.QUIT); break;
          case ComCommands.SUB_MINUS:nativeHandler.sendCommand(NativeAppsHandler.SUB_DELAY_DOWN); break;
          case ComCommands.SUB_PLUS:nativeHandler.sendCommand(NativeAppsHandler.SUB_DELAY_UP); break;
          case ComCommands.UP: nativeHandler.sendCommand(NativeAppsHandler.UPs); break;
          case ComCommands.DOWN: nativeHandler.sendCommand(NativeAppsHandler.DOWNs); break;
          case ComCommands.LEFT: nativeHandler.sendCommand(NativeAppsHandler.LEFTs); break;
          case ComCommands.RIGHT: nativeHandler.sendCommand(NativeAppsHandler.RIGHTs); break;
          case ComCommands.ENTER: nativeHandler.sendCommand(NativeAppsHandler.ENTERs);if(Dvd)nativeHandler.sendCommand(NativeAppsHandler.GET_LENGTH); break;
          case ComCommands.LONG_BACKWARD: nativeHandler.sendCommand(NativeAppsHandler.LONG_BCK); break;
          case ComCommands.MEDIUM_BACKWARD: nativeHandler.sendCommand(NativeAppsHandler.MEDIUM_BCK); break;
          case ComCommands.SHORT_BACKWARD: nativeHandler.sendCommand(NativeAppsHandler.SHORT_BCK); break;
          case ComCommands.LONG_FORWARD: nativeHandler.sendCommand(NativeAppsHandler.LONG_FWD); break;
          case ComCommands.MEDIUM_FORWARD: nativeHandler.sendCommand(NativeAppsHandler.MEDIUM_FWD); break;
          case ComCommands.SHORT_FORWARD: nativeHandler.sendCommand(NativeAppsHandler.SHORT_FWD); break;
          case ComCommands.SHUTDOWN:nativeHandler.shutdown();break;
          case ComCommands.SEEK: Seek(ba);break;
          case ComCommands.GET_TIME: nativeHandler.sendCommand(NativeAppsHandler.GET_TIME); break;
        }
      }
     
    }
    protected function player_quit(e:Event):void
    {
      Dvd = false;
      var ba:ByteArray = new ByteArray();
      ba.writeByte(ComCommands.MOVIE_QUIT);
      Send(ba);
    }
    protected function player_started(e:PlayerStartedEvent):void
    {
      var ba:ByteArray = new ByteArray();
      ba.writeByte(ComCommands.MOVIE_LENGTH);
      ba.writeInt(e.Seconds);
      Send(ba);
      
      NowPlaying(currentlzPlayin);
    }
    protected function time_rec(e:TimeRecEvent):void
    {
      var ba:ByteArray = new ByteArray();
      ba.writeByte(ComCommands.GET_TIME);
      ba.writeInt(e.Seconds);
      Send(ba);
    }
    protected function Seek(ba:ByteArray):void
    {
      var sec:int = ba.readInt();
      nativeHandler.sendCommand(NativeAppsHandler.SEEK," "+String(sec));
    }
    private function StreamText(ba:ByteArray):void
    {
      var o:Object = ba.readObject();
      var f:File = File.desktopDirectory.resolvePath(o.nativePath);
      var fs:FileStream = new FileStream();
     try
     {
       fs.open(f,FileMode.READ);
       var s:String = fs.readMultiByte(fs.bytesAvailable,"utf-8");
       fs.close();
     }
     catch(e:Error){}

      
      var ba:ByteArray = new ByteArray();
      ba.writeByte(ComCommands.SEND_TXT);
      ba.writeMultiByte(s,"utf-8");
      Send(ba);
      
    }
    private function MoveMouse(ba:ByteArray):void
    {
      var o:Object = ba.readObject();
      nativeHandler.ExecuteMouse(o.x,o.y,o.click);
    }
    private function PlayWithOutSubs(ba:ByteArray):void
    {
      var o:Object = ba.readObject();
      currentlzPlayin = o.nativePath;
      fileList.dispatchEvent(new FileEvent(FileEvent.FILE_CHOOSE,false,false,File.desktopDirectory.resolvePath(o.nativePath)));
    }
    private function PlayWithSubs(ba:ByteArray):void
    {
      var o:Object = ba.readObject();
      subCenterRef.DownloadSub(o.id,o.chrSet);
    }
    private function handleSubReq(ba:ByteArray):void
    {
      var o:Object = ba.readObject();
      
      subCenterRef.movieFile = o.nativePath;
      subCenterRef.addEventListener(SubtitleEvent.SUB_LIST_COMPLETE,sendSubList,false,4);
      subCenterRef.getSubtitle(o.name,o.sez,o.epiz);
      currentlzPlayin = o.nativePath;
    }
    private function sendSubList(e:SubtitleEvent):void
    {
      e.stopImmediatePropagation();
      var ba:ByteArray = new ByteArray();
      ba.writeByte(ComCommands.SUB_LIST_START);
      Send(ba);
      
      for(var s:String in e.ac)
      { 
        ba.clear();
        ba.writeByte(ComCommands.ADD_SUB_LIST_ITEM);
        ba.writeObject(e.ac[s]);
        Send(ba);
      }
      ba.clear();
      ba.writeByte(ComCommands.SUB_LIST_STOP);
      Send(ba);
      subCenterRef.removeEventListener(SubtitleEvent.SUB_LIST_COMPLETE,sendSubList,true);
    }
    private function navigate(ba:ByteArray):void
    {
      var o:Object = ba.readObject();
      if(o.dir == true)
      {
        var f:File = File.desktopDirectory.resolvePath(o.nativePath);
        fileList.navigateTo(f);
        fileList.refresh();
      }
      /*else if(o.dir == false)  
      {
        subCenterRef.StartSequence(o.nativePath);
      }*/
      SendFileList(fileList.dataProvider as ArrayCollection);
    }
    private function NowPlaying(f:String):void
    {
      var ba:ByteArray = new ByteArray();
      ba.writeByte(ComCommands.NOW_PLAYING);
      ba.writeObject({file:f});
      Send(ba);
    }
    public function SendFileList(list:ArrayCollection):void
    {
      /*var ds:SortField = new SortField();
      ds.name = "directory";*/
      var sr:Sort = new Sort();
      sr.fields = [new SortField("isDirectory",true),new SortField("nativePath")];
      list.sort = sr;
      list.refresh();
        
      var o:Object = new Object();
      var a:Array;
      var ba:ByteArray = new ByteArray();
      ba.writeByte(ComCommands.MPC_ON);
      if(Capabilities.os.search("Windows") != -1) ba.writeBoolean(true);
      else ba.writeBoolean(false);
      Send(ba);
      
      ba.clear();
      ba.writeByte(ComCommands.FILE_LIST_ITEM_START);
      if(fileList.directory.nativePath.search("root$:") != -1)
        ba.writeUTFBytes(fileList.directory.name);
      else
        ba.writeUTFBytes(fileList.directory.nativePath);
      Send(ba);
      for(var s:String in list)
      {
        a = String(list[s].nativePath).split("\\");
        o.name = a[a.length-1];
        if(o.name == "")
          o.name = a[a.length-2];
        o.nativePath = list[s].nativePath;
        o.dir = list[s].isDirectory;
        a = String(o.name).split(".");
        o.end = a[a.length-1];
        
        ba.clear();
        ba.writeByte(ComCommands.ADD_FILE_LIST_ITEM);
        ba.writeObject(o);
        Send(ba);
      }
      ba.clear();
      ba.writeByte(ComCommands.FILE_LIST_ITEM_STOP);
      Send(ba);
    }
    private function ParseLangsReq(ba:ByteArray):void
    {
      var ac:ArrayCollection = new ArrayCollection();
      var o:Object;
      while(ba.bytesAvailable != 0)
      {
        o = ba.readObject();
        ac.addItem(o);
      }
      subCenterRef.LangFilter = ac;
    }
    public static function getLocalIp():String
    {
      var my_ip:String = "";
      var i:int = 0;
      var interfaces:Vector.<NetworkInterface> = new Vector.<NetworkInterface>();
      interfaces =  NetworkInfo.networkInfo.findInterfaces();
      //active
      while(my_ip == "")
      {
        if(interfaces[i].active == true)
        {
          my_ip = interfaces[i].addresses[0].address;
        }
        i++;
      }
      return my_ip;
    }
    override protected function fClose(e:Event):void
    {
      InitateSeqence();
    }
  }
}