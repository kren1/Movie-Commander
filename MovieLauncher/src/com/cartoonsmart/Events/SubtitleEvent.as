package com.cartoonsmart.Events
{
  import flash.events.Event;
  
  import mx.collections.ArrayCollection;
  
  public class SubtitleEvent extends Event
  {
    public static const SUB_LIST_COMPLETE:String = "sub_list_complete";
    public var ac:ArrayCollection;
    
    public function SubtitleEvent(type:String,a:ArrayCollection, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(type, bubbles, cancelable);
      ac = a;
    }
    override public function clone():Event
    {
      return new SubtitleEvent(type,ac);
    }
  }
}