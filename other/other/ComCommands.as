package other
{
  public class ComCommands
  {
    public static const LANGS_REQUESTED:int = 0x70;
    // FILE LIST
    public static const ADD_FILE_LIST_ITEM:int = 0x71;
    public static const DIR_BACK:int = 0x72;
    public static const FILE_LIST_ITEM_START:int = 0x73;
    public static const FILE_LIST_ITEM_STOP:int = 0x74;
    public static const NAVIGATE:int = 0x75;
    //SUBS
    public static const REQUEST_SUB:int = 0x76;
    public static const SUB_LIST_START:int = 0x77;
    public static const SUB_LIST_STOP:int = 0x78;
    public static const ADD_SUB_LIST_ITEM:int = 0x79;
    public static const PLAY_WITH_SUBS:int = 0x69;
    public static const PLAY_WITOUT_SUBS:int = 0x68;
    public static const SET_PLAYER:int = 0x67;
    // PLAYER COMMANDS
    public static const CLOSE_PLAYER:int = 0x66;
    public static const PAUSE_MOVIE:int = 0x65;
    public static const SUB_MINUS:int = 0x64;
    public static const SUB_PLUS:int = 0x63;
    public static const LONG_FORWARD:int = 0x55;
    public static const SHORT_FORWARD:int = 0x54;
    public static const LONG_BACKWARD:int = 0x53;
    public static const SHORT_BACKWARD:int = 0x52;
    public static const MEDIUM_FORWARD:int = 0x51;
    public static const MEDIUM_BACKWARD:int = 0x50;
    
    // DVD
    public static const PLAY_DVD:int = 0x62;
    public static const UP:int = 0x61;
    public static const DOWN:int = 0x60;
    public static const LEFT:int = 0x59;
    public static const RIGHT:int = 0x58;
    public static const ENTER:int = 0x57;
    
    //MOUSE
    public static const MOUSE:int = 0x56;
    
    public static const GET_TXT:int = 0x49;
    public static const SEND_TXT:int = 0x48;
    public static const NOW_PLAYING:int = 0x47;

    public static const SHUTDOWN:int = 0x46;
    
    public static const GET_TIME:int = 0x45;
    public static const SEEK:int = 0x44;
    
    public static const MPC_ON:int = 0x43;
    public static const MOVIE_LENGTH:int = 0x42;
    public static const MOVIE_QUIT:int = 0x41;
    
    public function ComCommands()
    {
    }
  }
}