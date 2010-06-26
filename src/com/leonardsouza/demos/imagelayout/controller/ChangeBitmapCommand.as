package com.leonardsouza.demos.imagelayout.controller
{
	import com.leonardsouza.demos.imagelayout.events.LayoutEvent;
	import com.leonardsouza.demos.imagelayout.models.LayoutModel;
	
	import flash.display.Bitmap;
	
	import mx.core.BitmapAsset;
	
	import org.robotlegs.mvcs.Command;

	public class ChangeBitmapCommand extends Command
	{
		
		[Inject]
		public var model:LayoutModel;
		
		[Inject]
		public var event:LayoutEvent
		
		override public function execute():void
		{
			model.currentImage = new Bitmap(event.bitmap.bitmapData.clone());
			eventDispatcher.dispatchEvent(new LayoutEvent(LayoutEvent.BITMAP_CHANGED));
		}
	}
}