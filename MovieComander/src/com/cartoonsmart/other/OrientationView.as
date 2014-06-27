package com.cartoonsmart.other
{
 // import mx.core.mx_internal;
  
  import flash.system.Capabilities;
  
  import mx.core.FlexGlobals;
  
  import spark.components.View;

  //use namespace mx_internal;
  public class OrientationView extends View
  {
    public function OrientationView()
    {
      super();
    } 
    override public function getCurrentViewState():String
    {
      var aspectRatio:String = FlexGlobals.topLevelApplication.aspectRatio;
      var s:String;
      
      var n:Number = Number(Capabilities.screenResolutionX)*Number(Capabilities.screenResolutionY);
      
      switch(n)
      {
        case 1024*768: s = "Ipad_";break;
        case 480*800: s = "Desire_";break;
        case 640*960: s = "Iphone_";break;
        default: s = "Desire_";
      }      
      s = s + aspectRatio;    
      if (hasState(s))
        return s;

      
      // If the appropriate state for the orientation of the device
      // isn't defined, return the current state
      return currentState;
    }
 /*   override mx_internal function updateOrientationState():void
    {
      var s:String = FlexGlobals.topLevelApplication.aspectRatio;;
      
      setCurrentState(s,false);
    }*/
  }
}