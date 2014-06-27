package renderers
{
  import mx.core.BitmapAsset;
  import mx.core.UIComponent;
  import mx.events.FlexEvent;
  import mx.resources.IResourceManager;
  import mx.resources.ResourceManager;
  
  import spark.components.IconItemRenderer;
  import spark.components.supportClasses.StyleableTextField;


  
  public final class SubRenderer extends IconItemRenderer
  {
    [Embed(source="slike/1.gif")]
    [Bindable]
    private var slo:Class;
    [Embed(source="slike/2.gif")]
    [Bindable]
    private var ang:Class;
    [Embed(source="slike/36.gif")]
    [Bindable]
    private var ser:Class;
    [Embed(source="slike/5.gif")]
    [Bindable]
    private var ger:Class;
    [Embed(source="slike/8.gif")]
    [Bindable]
    private var fra:Class;
    [Embed(source="slike/9.gif")]
    [Bindable]
    private var ita:Class;
    [Embed(source="slike/38.gif")]
    [Bindable]
    private var hr:Class;
    [Embed(source="slike/28.gif")]
    [Bindable]
    private var spa:Class;
    [Embed(source="slike/27.gif")]
    [Bindable]
    private var ru:Class;
    [Embed(source="slike/17.gif")]
    [Bindable]
    private var chi:Class;
    [Embed(source="slike/4.gif")]
    [Bindable]
    private var kor:Class;
    [Embed(source="slike/23.gif")]
    [Bindable]
    private var ned:Class;
    [Embed(source="slike/16.gif")]
    [Bindable]
    private var gre:Class;
    
    [Embed(source="slike/n.png")]
    [Bindable]
    private var naglusn:Class;
    
    private var rm:IResourceManager = ResourceManager.getInstance();
    
    public function SubRenderer()
    {
      super();
      this.addEventListener(FlexEvent.DATA_CHANGE,dataChange);
    }
    private function dataChange(e:FlexEvent):void
    {
      var s:String;
      if(data.tvSeason != null && data.tvEpisode != "")
        s = rm.getString("resources","SEASON")+":" + data.tvSeason + "  "+rm.getString("resources","EPISODE")+":" + data.tvEpisode;
      label = data.title + " (" + data.year + ") " + s;
      //data.title data.release data.tvEpisode data.tvSeason data.year data.languageId data.flags
      messageField = "release";
      
     
      iconFunction = getIcon;
      if(String(data.flags).search("h")!= -1)
      {
        decorator = new naglusn();
      }
      
    }
    private function getIcon(d:Object):Object
    {
      var img:BitmapAsset;
      
      switch(d.languageId.toString())
      {
        case "1":img = new slo()  as BitmapAsset;data.chrSet = "x-Europa";break;
        case "2":img = new ang()  as BitmapAsset;data.chrSet = "x-Europa";break;
        case "36":img = new ser() as BitmapAsset;data.chrSet = "x-Europa";break;
        case "5":img = new ger()  as BitmapAsset;data.chrSet = "x-Europa";break;
        case "8":img = new fra()  as BitmapAsset;data.chrSet = "x-Europa";break;
        case "9":img = new ita()  as BitmapAsset;data.chrSet = "x-Europa";break;
        case "38":img = new hr()  as BitmapAsset;data.chrSet = "x-Europa";break;
        case "28":img = new spa() as BitmapAsset;data.chrSet = "x-Europa";break;
        case "27":img = new ru()  as BitmapAsset;data.chrSet = "iso-8859-5";break;
        case "17":img = new chi() as BitmapAsset;data.chrSet = "big5";break;
        case "4":img = new kor()  as BitmapAsset;data.chrSet = "ks_c_5601-1987";break;
        case "23":img = new ned() as BitmapAsset;data.chrSet = "x-Europa";break;
        case "16":img = new gre() as BitmapAsset;data.chrSet = "x-Europa";break;
      }
      return img;
    }
  }
}