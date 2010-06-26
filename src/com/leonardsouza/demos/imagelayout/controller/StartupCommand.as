package com.leonardsouza.demos.imagelayout.controller
{
	import com.leonardsouza.demos.imagelayout.events.LayoutEvent;
	import com.leonardsouza.demos.imagelayout.models.LayoutModel;
	import com.leonardsouza.demos.imagelayout.models.vo.AssetProvider;
	
	import mx.core.BitmapAsset;
	
	import org.robotlegs.mvcs.Command;

	public class StartupCommand extends Command
	{
		
		[Inject]
		public var model:LayoutModel;
		
		[Inject]
		public var assetProvider:AssetProvider;
				
		override public function execute():void
		{
			dispatch(new LayoutEvent(LayoutEvent.CHANGE_BITMAP, assetProvider.getItemAt(0)["bitmap"]));
		}
	}
}