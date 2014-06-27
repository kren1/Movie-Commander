package com.cartoonsmart.Events
{
  import flash.events.Event;
  
  public class SubtitleWindowEvent extends Event
  {
    public static const SEARCH_SUBS:String = "search_subs";
    public var name:String;
    public var season:String;
    public var episode:String
    
    public function SubtitleWindowEvent(type:String,name:String,season:String,episode:String, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(type, bubbles, cancelable);
      this.name = name;
      this.season = season;
      this.episode = episode;
    }
    override public function clone():Event
    {
      return new SubtitleWindowEvent(type,name,season,episode);
    }
  }
}