package com.cartoonsmart.Events
{
  import flash.events.Event;

  public class TimeRecEvent extends PlayerStartedEvent
  {
    public static const TIME_REC:String = "rec_time";
    
    public function TimeRecEvent(type:String, sec:int, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(type, sec, bubbles, cancelable);
    }
    override public function clone():Event
    {
      return new TimeRecEvent(type,Seconds);
    }
  }
}