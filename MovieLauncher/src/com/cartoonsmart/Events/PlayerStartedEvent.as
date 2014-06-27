package com.cartoonsmart.Events
{
  import flash.events.Event;
  
  public class PlayerStartedEvent extends Event
  {
    public static const PLAYER_STARTED:String = "player_start";
    public var Seconds:int;
    public function PlayerStartedEvent(type:String,sec:int, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(type, bubbles, cancelable);
      Seconds = sec;
    }
    override public function clone():Event
    {
      return new PlayerStartedEvent(type,Seconds);
    }
  }
}