package com.cartoonsmart.subtitles
{
  import com.adobe.crypto.MD5;
  import com.adobe.crypto.SHC256;
  import com.ak33m.rpc.xmlrpc.XMLRPCObject;
  import com.cartoonsmart.Events.SubtitleCompleteEvent;
  import com.cartoonsmart.Events.SubtitleEvent;
  import com.cartoonsmart.Events.SubtitleWindowEvent;
  
  import deng.fzip.FZip;
  import deng.fzip.FZipFile;
  
  import flash.display.DisplayObject;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.HTTPStatusEvent;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.net.URLLoader;
  import flash.net.URLLoaderDataFormat;
  import flash.net.URLRequest;
  import flash.utils.ByteArray;
  
  import mx.collections.ArrayCollection;
  import mx.collections.XMLListCollection;
  import mx.managers.PopUpManager;
  import mx.rpc.events.FaultEvent;
  import mx.rpc.events.InvokeEvent;
  import mx.rpc.events.ResultEvent;
  import mx.rpc.http.HTTPService;
  import mx.utils.ArrayUtil;
  
  import spark.formatters.NumberFormatter;
  

  public class Subtitles extends EventDispatcher
  {
    
    [Bindable]
    private var returnedData:ArrayCollection;
    [Bindable] 
    private var Endpoint:String = "http://ssp.podnapisi.net:8000";
    private var service:XMLRPCObject;
    private var SubStatus:int = 0;
    
    private var SubWin:SubtitleSelector = new SubtitleSelector();
    private var parent:DisplayObject;
    
    private var nf:NumberFormatter = new NumberFormatter();
    private var subService:HTTPService = new HTTPService();
    
    private var SearchStr:String;
    private var season:String;
    private var episode:String;
    private var neededURL:String;
    private var multiPage:int = 1;    
    private var subList:XMLListCollection = new XMLListCollection();

    private var charSet:String = "x-Europa";
    private var DownloadStatus:int = 0;
    private var SubId:String;
    private var sesionId:String;
    private var downloader:URLLoader = new URLLoader();
    
    public var LangFilter:ArrayCollection= new ArrayCollection(["1","2","36","5","17","4","27"]);
    public var movieFile:String;
    
    public function Subtitles(parent:DisplayObject)
    {
      this.parent = parent;
      
      service = new XMLRPCObject();
      service.endpoint = Endpoint;
      service.destination = "/RPC2/";
      service.addEventListener(ResultEvent.RESULT,onResult);
      service.addEventListener(FaultEvent.FAULT,onFault);
      
      nf.leadingZero = false;
      nf.fractionalDigits = 0;
      
      subService.resultFormat = "e4x";
      subService.addEventListener(ResultEvent.RESULT,subServiceResoult);
      subService.addEventListener(FaultEvent.FAULT,subServiceFault);
      subService.addEventListener(InvokeEvent.INVOKE,test);
      subService.showBusyCursor = true;
    }
    public function StartSequence(fileName:String):void
    {
      SubWin.fileName = fileName;
      PopUpManager.addPopUp(SubWin,parent);
      PopUpManager.centerPopUp(SubWin);
      SubWin.addEventListener(SubtitleWindowEvent.SEARCH_SUBS,getSubs);
      movieFile = fileName;
    }
    private function test(e:InvokeEvent):void
    {
      if(subService.url == "http://www.podnapisi.eu/sl/ppodnapisi/set_filters")
      {
        subService.url = neededURL;
        subService.concurrency = "last"
        subService.send();
      }

    }
    private function getSubs(e:SubtitleWindowEvent):void
    {
      SubWin.removeEventListener(SubtitleWindowEvent.SEARCH_SUBS,getSubs);
      getSubtitle(e.name,e.season,e.episode);
    }
    public function getSubtitle(name:String,seasonp:String,episodep:String):void
    {
      SearchStr = name;
      season = nf.format(seasonp);
      episode = nf.format(episodep);
      subService.url = "http://www.podnapisi.eu/sl/ppodnapisi/set_filters";
      subService.method = "GET";
    //  subService.url = "http://www.podnapisi.eu/sl/ppodnapisi/set_filters?return_url=www.podnapisi.eu/sl/ppodnapisi/najnovejsi&filter[language][]=2&sXML=1";
      subList.removeAll();
      
      if(name != "" && season != null && episode != null)
      {
        neededURL  = "http://www.podnapisi.eu/sl/ppodnapisi/search?tbsl=3&asdp=0&page="+String(multiPage)+"&sK="+ format(name) +"&sM=0&sJ=0&sT=1&sY=&sAKA2=1&sR=&sTS="+ nf.format(season) +"&sTE="+ nf.format(episode) +"&sXML=1";
      }
      else if(name != "" && season == null && episode == null)
      {
        neededURL = "http://www.podnapisi.eu/sl/ppodnapisi/search?tbsl=2&asdp=0&sK="+ format(name)+"&sXML=1";
      }
      
     /* var o:Object = new Object();
      o.return_url = "%2Fsl%2Fppodnapisi%2Fnajnovejsi" ;*/
      subService.send();
    }
    private function subServiceResoult(e:ResultEvent):void
    {
      var subs:XML = e.result as XML;
      var LocalSubColection:XMLListCollection = new XMLListCollection(subs.elements());
      var a:ArrayCollection;
      var o:Object;
        
      subList.addAll(LocalSubColection);
      if(int(LocalSubColection[0].count.toString()) >= 1 && int(LocalSubColection[0].current.toString()) >= 1)
      {
        if(int(LocalSubColection[0].count.toString()) != int(LocalSubColection[0].current.toString()))
        {
          multiPage++;
          subService.url = "http://www.podnapisi.eu/sl/ppodnapisi/search?tbsl=3&asdp=0&page="+String(multiPage)+"&sK="+ format(SearchStr) +"&sM=0&sJ=0&sT=1&sY=&sAKA2=1&sR=&sTS="+ nf.format(season) +"&sTE="+ nf.format(episode) +"&sXML=1";
          subService.send();
          return;
        }
        else
          multiPage = 1;
        
      }
      a = new ArrayCollection();
      for(var i:int = 1;i<subList.length;i++)
      {
        if(i != 31 && i != 61 && i != 91 && i != 121 && i != 151 && i != 181)
        {
          o = new Object();
          o.languageId = subList[i].languageId.toString();
          if(LangFilter.contains(o.languageId))
          {
            o.id = subList[i].id.toString();
            o.tvSeason = subList[i].tvSeason.toString();;
            o.tvEpisode = subList[i].tvEpisode.toString();
            o.title = subList[i].title.toString();
            o.year = subList[i].year.toString();
            o.release = subList[i].release.toString();
            o.flags = subList[i].flags.toString();
            a.addItem(o);
          }

        }    
      }
      dispatchEvent(new SubtitleEvent(SubtitleEvent.SUB_LIST_COMPLETE,a));
    }
    private function subServiceFault(e:FaultEvent):void
    {
      if(e.fault.faultCode == "Server.Error.Request")
      {

      }
    }
    public function DownloadSub(id:String,chrSet:String):void
    {
      charSet = chrSet;
      SubId = id;
      Automat();
    }
    private function Automat():void
    {
      switch(SubStatus)
      {
        case 0:
          service.call("initiate","flex");
          SubStatus = 1;
          break;
        case 1: 
          sesionId =  returnedData[0].session;
          var s:String = SHC256.hash(MD5.hash("mim123") + returnedData[0].nonce );
          service.call("authenticate",sesionId,"LordSlem",s);
          SubStatus=2;
          break
        case 2: 
          service.call("download",sesionId,[SubId]);
          SubStatus=3;
          break;
        case 3: 
          download(returnedData[0].names[0].filename); 
          returnedData.removeAll();
          SubStatus=2;
          break;
      }
    }
    private function download(s:String):void
    {
      var u:URLRequest = new URLRequest("http://www.podnapisi.net/static/podnapisi/"+s);
      downloader.addEventListener(Event.COMPLETE, fileDownloaded);
      downloader.dataFormat = URLLoaderDataFormat.BINARY;
      downloader.load(u);
    }
    private function fileDownloaded(e:Event):void
    {
      var ba:ByteArray = new ByteArray();
      downloader.data.readBytes(ba);
      downloader.data.clear();
      downloader.removeEventListener(Event.COMPLETE, fileDownloaded);
      
      var fz:FZip = new FZip();
      fz.loadBytes(ba);
      var fzf:FZipFile = fz.getFileAt(0);
      
      //   var s:String = fzf.getContentAsString(false,"x-Europa");
      var s:String = fzf.getContentAsString(false,charSet);
      
      var f:File = File.desktopDirectory.resolvePath(File.applicationStorageDirectory.nativePath + "/AutoSub.srt");
      var fs:FileStream = new FileStream();
      try
      {
        f.deleteFile();
      }
      catch(er:Error){;}
      try
      {
        fs.open(f,FileMode.WRITE);
        fs.writeByte(0xEF);
        fs.writeByte(0xBB);
        fs.writeByte(0xBF);
        fs.writeUTFBytes(s);
        fs.close();
        dispatchEvent(new SubtitleCompleteEvent(SubtitleCompleteEvent.SUB_COMPLETE,f,movieFile));
        
      }
      catch(err:Error){;}  

    }
    private function onResult(e:ResultEvent):void
    {
      returnedData = new ArrayCollection(ArrayUtil.toArray(e.result));
      Automat();
    }
    private function onFault(e:FaultEvent):void
    {
      
    }
    private function format(s:String=""):String
    {
      return s.replace(" ","+");
    }
  }
}