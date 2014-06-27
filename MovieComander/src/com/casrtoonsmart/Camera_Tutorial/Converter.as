package com.casrtoonsmart.Camera_Tutorial
{
  import flash.display.BitmapData;
  import flash.utils.ByteArray;
  
  public final class Converter
  {
    public function Converter()
    {
    }
    public static function ToBmpd(ba:ByteArray,wid:uint = 0,hig:uint = 0):BitmapData
    {
      var bmpd:BitmapData;
      var i:uint;
      
      ba.position = 1;
      if(wid == 0 && hig == 0)
      {
        wid = ba.readInt();
        hig = ba.readInt();
      }
      bmpd = new BitmapData(wid,hig);
      
      for(var y:int = 0;y<hig;y++)
      {
        for(var x:int = 0;x<wid;x++)
        {
          i = ba.readUnsignedInt();
          bmpd.setPixel(x,y,i);
        }
      }
      return bmpd;
    }
    public static function TBa(bmpd:BitmapData):ByteArray
    {
      var i:uint;
      var ba:ByteArray = new ByteArray();
      
      ba.writeInt(bmpd.width);
      ba.writeInt(bmpd.height);
      
      for(var y:uint = 0;y<bmpd.height;y++)
      {
        for(var x:uint = 0;x<bmpd.width;x++)
        {
          i = bmpd.getPixel(x,y);
          ba.writeUnsignedInt(i);
        }
      }
      return ba;
    }
    public static function Convert(buff:ByteArray):ByteArray
    {
      var OutBuff:ByteArray = new ByteArray();
      
      for(var i:int = 0;i<buff.length;i++)
      {
        switch(buff[i])
        {
          case 0x82: OutBuff.writeByte(0x84); OutBuff.writeByte(0x32); break;
          case 0x83: OutBuff.writeByte(0x84); OutBuff.writeByte(0x33); break;
          case 0x84: OutBuff.writeByte(0x84); OutBuff.writeByte(0x34); break;
          default: OutBuff.writeByte(buff[i]);
        }
      }
      
      return OutBuff;
    }
  }
}