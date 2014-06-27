package com.cartoonsmart.other
{
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  
  public class ConfiHandler
  {
    private var handle:FileStream = new FileStream();
    private var file:File = File.applicationStorageDirectory.resolvePath("Config.xml");
    private var Fname:File = File.desktopDirectory.resolvePath(file.nativePath);
    private var XmlCfg:XML = null;
    
    public function ConfiHandler()
    {
			try
			{
			  handle.open(Fname, FileMode.READ);
			  XmlCfg = new XML(handle.readUTFBytes(handle.bytesAvailable));
			  handle.close();
			}
			catch(error:*)
			{
			  XmlCfg = null;
			}
    }
    public function Write(name:String, s:String):void
    {
      if(XmlCfg == null) 
        XmlCfg = new XML("<PROGRAM_CFG>\n\r</PROGRAM_CFG>\n\r");
      XmlCfg["PAR"][name] = s;
    }

    public function Read(name:String):String
    {
      if(XmlCfg == null) return "";
      return XmlCfg["PAR"][name];
    }
    public function Save():void
    {
      if(XmlCfg != null)
      {
        handle.open(Fname, FileMode.WRITE);
        handle.writeUTFBytes(XmlCfg.toXMLString());
        handle.close();
      }  
    }
  }
}