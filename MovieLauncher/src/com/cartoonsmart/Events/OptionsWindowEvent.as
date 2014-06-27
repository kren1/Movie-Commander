package com.cartoonsmart.Events
{
	import com.cartoonsmart.dto.Player_dto;
	
	import flash.events.Event;
	
	public class OptionsWindowEvent extends Event
	{
		public var VLCPath:String;
		public var MPCPath:String;
		public var player:Player_dto = new Player_dto;
    public var subs:Boolean;
		public static const WINDOW_CLOSED:String = "win_close";
		
		public function OptionsWindowEvent(type:String,VLCpath:String,MPCpath:String,playerArg:Boolean,subs:Boolean,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.VLCPath = VLCpath;
			this.MPCPath = MPCpath;
      this.subs = subs;
			this.player.PlayerBool = playerArg;
		}
		override public function clone():Event
		{
			return new OptionsWindowEvent(type,VLCPath,MPCPath,player.PlayerBool,subs);
		}
	}
}