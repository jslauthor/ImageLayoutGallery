package com.leonardsouza.demos.imagelayout
{
	import com.leonardsouza.demos.imagelayout.controller.*;
	import com.leonardsouza.demos.imagelayout.events.*;
	import com.leonardsouza.demos.imagelayout.models.*;
	import com.leonardsouza.demos.imagelayout.models.vo.AssetProvider;
	import com.leonardsouza.demos.imagelayout.views.components.*;
	import com.leonardsouza.demos.imagelayout.views.mediators.*;
	
	import flash.display.DisplayObjectContainer;
	
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Context;

	public class LayoutGalleryContext extends Context
	{
		public function LayoutGalleryContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true)
		{
			super(contextView, autoStartup);
		}
		
		override public function startup():void
		{
			//map controllers
			commandMap.mapEvent(ContextEvent.STARTUP, StartupCommand, ContextEvent, true);
			commandMap.mapEvent(LayoutEvent.CHANGE_BITMAP, ChangeBitmapCommand, LayoutEvent);
			
			//map models
			injector.mapSingleton( LayoutModel );
			injector.mapSingleton( AssetProvider );
			
			//map views
			mediatorMap.mapView(ImageLayoutView, ImageLayoutViewMediator);
			mediatorMap.mapView(ImageLayoutControlView, ImageLayoutControlViewMediator);
			mediatorMap.mapView(ScratchPad, ScratchPadMediator);
			
			dispatchEvent(new ContextEvent(ContextEvent.STARTUP));
		}
	}
}