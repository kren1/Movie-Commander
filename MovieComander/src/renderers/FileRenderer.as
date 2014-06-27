package renderers
{
  import flash.system.Capabilities;
  
  import mx.events.FlexEvent;
  
  import slike.dir;
  
  import spark.components.IconItemRenderer;
  
  public final class FileRenderer extends IconItemRenderer
  {
    public function FileRenderer()
    {
      super();
      labelField = "name";
      iconField = "dirIcon"
       // this.height = Capabilities.screenDPI/5;
     // this.addEventListener(FlexEvent.DATA_CHANGE,onChange);
       
    }
  /*  private function onChange(e:FlexEvent):void
    {
      if(data.dir == true)
      {
        i = slike.dir;
      }
    }*/

  }
}