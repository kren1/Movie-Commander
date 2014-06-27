package com.casrtoonsmart.Camera_Tutorial
{
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.net.Socket;
  import flash.utils.ByteArray;
  
  //import mx.controls.Alert;
  
  public class MySocket
  {
    [Bindable]
    public var socket:Socket = new Socket();
    public var CloseFunction:Function = null;
    public var ReciveFunction:Function = null;
    public var OpenFunction:Function = null;
    private var Fifo:ByteArray = new ByteArray();
    private var mode:Boolean = false;
    private var RBuff:ByteArray = new ByteArray();
    private var Char84:Boolean = false;
    private var st:int=0;
    
    public function MySocket()
    {
    }
    public function OpenSocket(host:String, port:int):void
    {
      socket.connect(host,port);
      
    }
    public function addEvents(soc1:Socket):void
    {
      soc1.addEventListener(Event.CONNECT,fCon);
      soc1.addEventListener(IOErrorEvent.IO_ERROR, fIOError);
      soc1.addEventListener(ProgressEvent.SOCKET_DATA,fData);
      soc1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,fSecError);
      soc1.addEventListener(Event.CLOSE,fClose);
    }   
    public function Send(message:ByteArray):void
    {
      var outbuff:ByteArray = new ByteArray;
      
      outbuff.writeByte(0x82);
      outbuff.writeBytes(Converter.Convert(message));
      outbuff.writeByte(0x83);
      try
      {
        socket.writeBytes(outbuff);
        socket.flush();
      }
      catch(e:Error)
      {
        trace(e.message);
      }
    }
    protected function fClose(e:Event):void
    {
      if(CloseFunction != null)
        CloseFunction();
    }
    
    protected function fCon(e:Event):void
    {

        if(OpenFunction != null)
          OpenFunction();
    }
    protected function fIOError(e:IOErrorEvent):void
    {
 //     Alert.show("IOError","IOError" );
	  
    }
    private function fData(e:ProgressEvent):void
    {
      Fifo.clear();
      socket.readBytes(Fifo,0,e.bytesLoaded);
      st+= e.bytesLoaded;
      for(var i:uint=0;i<Fifo.length;i++)
      {
        if(mode == false)
        {
          if(Fifo[i] == 0x82)
          {
            mode = true;
            RBuff.clear();
          }
        }
        else
        {
          if(Fifo[i] == 0x83)
          {
            mode = false;
            ReciveFunction(RBuff);
            st=0;
          }
          else
          {
            if(Fifo[i] == 0x84)
            {
              Char84 = true;
            }
            else
            {
              if(Char84 == false) RBuff.writeByte(Fifo[i]);
              else
              {
              
                switch(Fifo[i])
                {
                 
                  case 0x32: RBuff.writeByte(0x82); break;
                  case 0x33: RBuff.writeByte(0x83); break;
                  case 0x34: RBuff.writeByte(0x84); break;
                }
                Char84 = false;
              }
            }
          }
        }
      }
    }
    protected function fSecError(e:SecurityErrorEvent):void
    {
  //    Alert.show("Security Error","Security Error"); 
    }
  }
}