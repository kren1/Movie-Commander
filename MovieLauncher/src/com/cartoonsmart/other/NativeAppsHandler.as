package com.cartoonsmart.other
{
	import com.cartoonsmart.Events.PlayerStartedEvent;
	import com.cartoonsmart.Events.TimeRecEvent;
	import com.cartoonsmart.dto.Player_dto;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.Socket;

	public class NativeAppsHandler extends Socket
	{
		private static const KEYBOARD:File = File.desktopDirectory.resolvePath(File.applicationDirectory.nativePath + "/keyboard.exe");
    private static const MOUSE:File = File.desktopDirectory.resolvePath(File.applicationDirectory.nativePath + "/mouse.exe");
    private const SHUT_DOWN:File = File.desktopDirectory.resolvePath("C:/Windows/System32/shutdown.exe")
		
		public static const VLC_PLAYER:String = "vlc";
		public static const MPC_PLAYER:String= "mpc";
		
		public static const CLOSE_PLAYER:int = 0;
		public static const PAUSE_MOVIE:int = 1;
    public static const SUB_MINUS:int = 2;
		public static const SUB_PLUS:int = 3;
    public static const UP:int = 4;
    public static const DOWN:int = 5;
    public static const LEFT:int = 6;
    public static const RIGHT:int = 7;
    public static const ENTER:int = 8;
    public static const LONG_FORWARD:int = 9;
    public static const SHORT_FORWARD:int = 10;
    public static const LONG_BACKWARD:int = 11;
    public static const SHORT_BACKWARD:int = 12;
    public static const MEDIUM_FORWARD:int = 13;
    public static const MEDIUM_BACKWARD:int = 14;
    
    public static const PLAYER_EXITED:String = "player_exit";
    
    private var shutdownStarted:Boolean = false;
    private var playerInstance:NativeProcess = new NativeProcess();
    
    
    private static var quee:Array = new Array();
    private static var runing:Boolean = false;
    private var Answer:String = "";
    private var status:int = 0;
    private var mpc:Boolean = false;
    private var NumOfRecall:int = 0;//NUmber of times get length was requested
    
		private static const cmd_array:Array = [{vlc:["7","11","q"],mpc:["7","A4","x"]},//close
										 {vlc:["20","7","krneki"],mpc:["20","7","krneki"]},//pause
                     {vlc:["7","7","g"],mpc:["70","7","krneki"]},//sub -
                     {vlc:["7","7","h"],mpc:["71","7","krneki"]},// sub +
                     {vlc:["26","7","krneki"],mpc:["26","7","krneki"]},//up
                     {vlc:["7","7","28"],mpc:["7","7","28"]},//down							 
                     {vlc:["25","7","krneki"],mpc:["25","7","krneki"]},//left
                     {vlc:["27","7","krneki"],mpc:["27","7","krneki"]},//right
                     {vlc:["0D","7","krneki"],mpc:["0D","7","krneki"]},//enter
                     {vlc:["11","12","27"],mpc:["12","27","krneki"]},//long forward
                     {vlc:["12","27","krneki"],mpc:["11","27","krneki"]},//short forward
                     {vlc:["11","12","25"],mpc:["12","25","krneki"]},//long backward		 
                     {vlc:["12","25","krneki"],mpc:["11","25","krneki"]},//short backward
                     {vlc:["11","27","krneki"],mpc:["11","27","krneki"]},//medium forward
                     {vlc:["11","25","krneki"],mpc:["11","25","krneki"]}];//medium backward
    
    
    public static const GET_LENGTH:int = 1000;
    public static const QUIT:int = 1001;
    public static const PAUSE:int = 1002;
    public static const SUB_DELAY_UP:int = 1003;
    public static const SUB_DELAY_DOWN:int = 1004;
    public static const LONG_FWD:int = 1005;
    public static const SHORT_FWD:int = 1006;
    public static const LONG_BCK:int = 1007;
    public static const SHORT_BCK:int = 1008;
    public static const MEDIUM_FWD:int = 1009;
    public static const MEDIUM_BCK:int = 1010;
    public static const UPs:int = 1011;
    public static const DOWNs:int = 1012;
    public static const LEFTs:int = 1013;
    public static const RIGHTs:int = 1014;
    public static const ENTERs:int = 1015;
    public static const GET_TIME:int = 1016;
    public static const SEEK:int = 1017;
    
    private static const ukazi:Array = [
      {status:1000,cmd:"get_length"},
      {status:1001,cmd:"quit"},
      {status:1002,cmd:"pause"},
      {status:1003,cmd:"key key-subdelay-up"},
      {status:1004,cmd:"key key-subdelay-down"},
      {status:1005,cmd:"key key-jump+long"},
      {status:1006,cmd:"key key-jump+short"},
      {status:1007,cmd:"key key-jump-long"},
      {status:1008,cmd:"key key-jump-short"},
      {status:1009,cmd:"key key-jump+medium"},
      {status:1010,cmd:"key key-jump-medium"},
      {status:1011,cmd:"key key-nav-up"},
      {status:1012,cmd:"key key-nav-down"},
      {status:1013,cmd:"key key-nav-left"},
      {status:1014,cmd:"key key-nav-right"},
      {status:1015,cmd:"key key-nav-activate"},
      {status:1016,cmd:"get_time"},
      {status:1017,cmd:"seek"}
       
    ];
    
		public function NativeAppsHandler()
		{
      addEventListener(Event.CONNECT,fCon);
      addEventListener(IOErrorEvent.IO_ERROR, fIOError);
      addEventListener(ProgressEvent.SOCKET_DATA,fData);
      addEventListener(SecurityErrorEvent.SECURITY_ERROR,fSecError);
      addEventListener(Event.CLOSE,fClose);
		}
    public function shutdown():void
    {
      if(shutdownStarted == false)
      {
        StartProcess(SHUT_DOWN,["/s"]);
        shutdownStarted = true;
      }
      else
      {
        StartProcess(SHUT_DOWN,["/a"]);
        shutdownStarted = false;
      }
        
    }
		public  function ExecuteKeyboardCommand(cmd:int,mpc:String):void
		{
        if(cmd < cmd_array.length)
          StartProcess(KEYBOARD,cmd_array[cmd][mpc]);

		}
    public function ExecuteMouse(x:int,y:int, click:Boolean = true):void
    {
      StartProcess(MOUSE,[x,y,int(click)]);
    }
    public function runPlayer(exe:File,args:Array,VLC:Boolean):void
    {
      if(playerInstance.running == true) return;
      var Info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
      var arg:Vector.<String> = new Vector.<String>();      
      playerInstance.addEventListener(NativeProcessExitEvent.EXIT,AppExit);
      mpc = !VLC;
      for (var s:String in args)
      {
        arg.push(args[s]); 
      }
      if(VLC == true)
      {

        arg.push("--rc-host");
        arg.push("localhost:4444");
        arg.push("--rc-quiet");
        arg.push("--extraintf=rc");
      }
      try
      {
        Info.executable = exe;
        Info.arguments = arg;
        playerInstance.start(Info);
        makeLog(String(VLC)+"\r\n");
        if(VLC == true)
          Connect();
      }
      catch(e:Error)
      {
        trace("player started error:  " + e.message);
        return;
      }
      if(mpc == true)
       dispatchEvent(new PlayerStartedEvent(PlayerStartedEvent.PLAYER_STARTED,-1));
    }
    protected function Connect():void
    {
      this.connect("localhost",4444);
      makeLog("connecting to player \r\n");
    }
    private function AppExit(e:NativeProcessExitEvent):void
    {
      playerInstance.removeEventListener(NativeProcessExitEvent.EXIT,AppExit);
      dispatchEvent(new Event(PLAYER_EXITED));

    }
    protected function fClose(e:Event):void
    {
      makeLog("close Player conection\r\n");
    }   
    protected function fCon(e:Event):void
    {
      sendCommand(GET_LENGTH);
      makeLog("player connected\r\n");
    }
    protected function fIOError(e:IOErrorEvent):void
    {
      //     Alert.show("IOError","IOError" );
     // dispatchEvent(new PlayerStartedEvent(PlayerStartedEvent.PLAYER_STARTED,4000));
      makeLog(String(e.errorID));
      
    }
    private function fData(e:ProgressEvent):void
    {
      Answer += this.readUTFBytes(e.bytesLoaded);
      
      ParseAnswer();
      
    }
    protected function ParseAnswer():void
    {
      
      var s:String = getLastLine(Answer);
      var i:int = int(s);
      
      switch(status)
      {
        /*case GET_LENGTH:if(int(s) == 0)break; dispatchEvent(new PlayerStartedEvent(PlayerStartedEvent.PLAYER_STARTED,int(s)));break;
        case GET_TIME:if(int(s) == 0)break; dispatchEvent(new TimeRecEvent(TimeRecEvent.TIME_REC,int(s)));break;*/
        case GET_LENGTH:
          if(i == 0 && NumOfRecall < 3 && this.connected && mpc == false)
          {
            this.writeUTFBytes(ukazi[status-1000].cmd+"\n\r");
            this.flush();
            NumOfRecall++;   
            break;
          }
          dispatchEvent(new PlayerStartedEvent(PlayerStartedEvent.PLAYER_STARTED,i));
          break;
        case GET_TIME: dispatchEvent(new TimeRecEvent(TimeRecEvent.TIME_REC,i));break;
      }
      
      
      makeLog("attempt: " + String(NumOfRecall)+"\n");
      NumOfRecall = 0;
      makeLog(Answer);
      Answer = "";
    }
    private function getLastLine(s:String):String
    {
      var a:Array = s.split("\r\n");
      return a[a.length-2];
    }
    public function sendCommand(cmd:int,args:String = ""):void
    {
      if(cmd >-1 && cmd-1000 < ukazi.length)
      {
        status = cmd;
        if(this.connected && mpc == false)
        {
          this.writeUTFBytes(ukazi[cmd-1000].cmd+args+"\n\r");
          this.flush();
          NumOfRecall = 0;
        }
        else
        {
          var dto:Player_dto = new Player_dto();
          dto.PlayerBool = mpc;
          switch(cmd)
          {
            case GET_LENGTH:break;
            case QUIT:ExecuteKeyboardCommand(CLOSE_PLAYER,dto.PlayerString);break;
            case PAUSE:ExecuteKeyboardCommand(PAUSE_MOVIE,dto.PlayerString);break;
            case SUB_DELAY_UP:ExecuteKeyboardCommand(SUB_PLUS,dto.PlayerString);break;
            case SUB_DELAY_DOWN:ExecuteKeyboardCommand(SUB_MINUS,dto.PlayerString);break;
            case LONG_FWD:ExecuteKeyboardCommand(LONG_FORWARD,dto.PlayerString);break;
            case SHORT_FWD:ExecuteKeyboardCommand(SHORT_FORWARD,dto.PlayerString);break;
            case LONG_BCK:ExecuteKeyboardCommand(LONG_BACKWARD,dto.PlayerString);break;
            case SHORT_BCK:ExecuteKeyboardCommand(SHORT_BACKWARD,dto.PlayerString);break;
            case MEDIUM_FWD:ExecuteKeyboardCommand(MEDIUM_FORWARD,dto.PlayerString);break;
            case MEDIUM_BCK:ExecuteKeyboardCommand(MEDIUM_BACKWARD,dto.PlayerString);break;
            case UPs:ExecuteKeyboardCommand(UP,dto.PlayerString);break;
            case DOWNs:ExecuteKeyboardCommand(DOWN,dto.PlayerString);break;
            case LEFTs:ExecuteKeyboardCommand(LEFT,dto.PlayerString);break;
            case RIGHTs:ExecuteKeyboardCommand(RIGHT,dto.PlayerString);break;
            case ENTERs:ExecuteKeyboardCommand(ENTER,dto.PlayerString);break;
            case GET_TIME:break;
            case SEEK:break;
          }
          makeLog("key cmd "+String(cmd)+"\r\n");
        }

      }
    }
    protected function fSecError(e:SecurityErrorEvent):void
    {
      //    Alert.show("Security Error","Security Error"); 
      makeLog(String(e.errorID));
    }
    public static function makeLog(s:String):void
    {
      var f:File = File.desktopDirectory.resolvePath(File.applicationDirectory.nativePath + "/log.txt");
      var fs:FileStream = new FileStream();
      
      fs.open(f,FileMode.APPEND);
      fs.writeUTFBytes(s);
      fs.close();
    }
		public static function StartProcess(exe:File,args:Array):void
		{
      var o:Object;
      var process:NativeProcess;
      if(exe == KEYBOARD || exe == MOUSE)
      {
        if(runing == false)
        {
           run(exe,args);
        }
        else
        {
          o = new Object();
          o.exe = exe;
          o.args = args;
          quee.push(o);
        }
      }
      else
      {
        run(exe,args);
        process.removeEventListener(NativeProcessExitEvent.EXIT,AppExit);
        runing == false;
      }
      function AppExit(e:NativeProcessExitEvent):void
      {
        if(e.currentTarget.hasEventListener(NativeProcessExitEvent.EXIT))
          e.currentTarget.removeEventListener(NativeProcessExitEvent.EXIT,AppExit);
        if(quee.length > 0)
        {
          o = quee.shift();
          StartProcess(o.exe,o.args);
        }
        runing = false
      }
      function run(exer:File,argsr:Array):void
      {
        process = new NativeProcess();
        var Info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var arg:Vector.<String> = new Vector.<String>();
        
        process.addEventListener(NativeProcessExitEvent.EXIT,AppExit);
        
        for (var s:String in argsr)
        {
          arg.push(args[s]); 
        }
        
        try
        {
          Info.executable = exer;
          Info.arguments = arg;
          process.start(Info);
          runing = true;
        }
        catch(e:Error)
        {
          
        }
      }
		}
	}
}