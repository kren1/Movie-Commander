package com.cartoonsmart.other
{
  import mx.core.mx_internal;
  
  import spark.components.Button;


  

  
  use namespace mx_internal;
  
  public final class MyToogleButton extends Button
  {
    public function MyToogleButton()
    {
      super();
    }
    override protected function buttonReleased():void
    {
      keepDown(true);
    }
    public function dol(b:Boolean):void
    {
      keepDown(b);
    }
  }
}