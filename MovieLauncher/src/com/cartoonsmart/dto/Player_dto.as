package com.cartoonsmart.dto
{
	import com.cartoonsmart.other.NativeAppsHandler;

	public class Player_dto 
	{
		private var _player:Boolean = false;
		public function Player_dto()
		{
		}
		public function get PlayerBool():Boolean
		{
			return _player;
		}
		public function set PlayerBool(b:Boolean):void
		{
			_player = b;
		}
		public function get PlayerString():String
		{
			if(_player == true)
				return NativeAppsHandler.MPC_PLAYER;
			else 
				return NativeAppsHandler.VLC_PLAYER;
		}
		public function set PlayerString(s:String):void
		{
			if(s == NativeAppsHandler.MPC_PLAYER)
				_player = true;
			else
				_player = false;
		}
	}
}