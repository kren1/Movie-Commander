package com.cartoonsmart.Events
{
  import flash.events.Event;
  import flash.filesystem.File;
  
  
  public class SubtitleCompleteEvent extends Event
  {
    public static const SUB_COMPLETE:String = "sub_complete";
    public var subtitleFile:File;
    public var movieFile:String
    
    public function SubtitleCompleteEvent(type:String,subFile:File,movFile:String, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(type, bubbles, cancelable);
      subtitleFile = subFile;
      movieFile = movFile;
    }
    override public function clone():Event
    {
      return new SubtitleCompleteEvent(type,subtitleFile,movieFile);
    }
  }
}