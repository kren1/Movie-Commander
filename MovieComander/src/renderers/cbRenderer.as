package renderers
{
  import flash.events.Event;
  
  import mx.events.FlexEvent;
  
  import spark.components.CheckBox;
  import spark.components.LabelItemRenderer;
  import spark.skins.mobile.CheckBoxSkin;
  
  public final class cbRenderer extends LabelItemRenderer
  {
    private var cb:CheckBox;
    
    public function cbRenderer()
    {
      super();
      this.addEventListener(FlexEvent.DATA_CHANGE,onChange);
    }
    override protected function createChildren():void
    {
      super.createChildren(); 
      if(!cb)
      {
        createCb();
      }
    }
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
      var cbHeight:Number = 0;
      var paddingLeft:Number   = getStyle("paddingLeft"); 
      var paddingRight:Number  = getStyle("paddingRight");
      var paddingTop:Number    = getStyle("paddingTop");
      var paddingBottom:Number = getStyle("paddingBottom");
      var verticalAlign:String = getStyle("verticalAlign");
      
      var viewWidth:Number  = unscaledWidth  - paddingLeft - paddingRight;
      var viewHeight:Number = unscaledHeight - paddingTop  - paddingBottom;
      
      var vAlign:Number;
      if (verticalAlign == "top")
        vAlign = 0;
      else if (verticalAlign == "bottom")
        vAlign = 1;
      else // if (verticalAlign == "middle")
        vAlign = 0.5;
      
      super.layoutContents(unscaledWidth,unscaledHeight);
      cbHeight = getElementPreferredHeight(cb);
      setElementSize(cb,getElementPreferredWidth(cb),cbHeight);
      
      var cbY:Number = Math.round(vAlign * (viewHeight - cbHeight))  + paddingTop;
      
      setElementPosition(cb,labelDisplay.x,cbY);
      setElementPosition(labelDisplay,labelDisplay.x + 10 + cb.width + cb.x,labelDisplay.y);
    }
    private function createCb():void
    {
      cb = new CheckBox();
      cb.selected = false;
      addChild(cb);
      cb.addEventListener(Event.CHANGE,cbChange);
    }
    private function onChange(e:FlexEvent):void
    {
      try
      {
        cb.selected = Boolean(data.Status);
        label = data.lang;
      }
      catch(e:Error){}
    }
    private function cbChange(e:Event):void
    {
      data.Status = cb.selected;
    }
  }
}