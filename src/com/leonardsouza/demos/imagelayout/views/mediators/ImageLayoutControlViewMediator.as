package com.leonardsouza.demos.imagelayout.views.mediators
{

	import com.leonardsouza.demos.imagelayout.events.LayoutEvent;
	import com.leonardsouza.demos.imagelayout.models.LayoutModel;
	import com.leonardsouza.demos.imagelayout.models.vo.AssetProvider;
	import com.leonardsouza.demos.imagelayout.views.components.ImageLayoutControlView;
	import com.leonardsouza.display.layouts.events.ImageLayoutElementEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.BitmapAsset;
	import mx.events.FlexEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.IndexChangeEvent;

	public class ImageLayoutControlViewMediator extends Mediator
	{
		[Inject]
		public var view:ImageLayoutControlView;
		
		[Inject]
		public var model:LayoutModel;

		[Inject]
		public var assetProvider:AssetProvider;
		
		override public function onRegister():void
		{
			eventMap.mapListener( eventDispatcher, LayoutEvent.BITMAP_CHANGED, onChangeBitmap );
			eventMap.mapListener( view.imageDropDown, IndexChangeEvent.CHANGE, onDataChange );
			eventMap.mapListener( view.loadImageButton, MouseEvent.CLICK, onLoadImageClick );
			eventMap.mapListener( view.loadImageInput, MouseEvent.CLICK, onLoadImageInputClick );
			eventMap.mapListener( view.fileRef, Event.SELECT, onImageSelected);
			eventMap.mapListener( view.fileRef, Event.COMPLETE, onFileLoaded);
			eventMap.mapListener( view.depthFactor, Event.CHANGE, onSliderUpdate);
			eventMap.mapListener( view.gridInterval, Event.CHANGE, onSliderUpdate);
			eventMap.mapListener( view.contrastThreshold, Event.CHANGE, onSliderUpdate);
			eventMap.mapListener( view.animate, Event.CHANGE, onAnimateSelect);
			eventMap.mapListener( eventDispatcher, LayoutEvent.LAYOUT_PROPERTY_CHANGED, onLayoutPropertyChange);
			eventMap.mapListener( eventDispatcher, ImageLayoutElementEvent.ELEMENT_CHANGE, onElementChange);
			
			onChangeBitmap();
			view.imageDropDown.dataProvider = assetProvider;
		}
	
		protected function onChangeBitmap(event:LayoutEvent = null):void
		{
			view.previewImage.visible = false;
			view.previewImage.source = new Bitmap(model.currentImage.bitmapData);
			
			view.previewImage.addEventListener(FlexEvent.UPDATE_COMPLETE, function f():void 
			{
				view.previewImage.x = view.imageGroup.width / 2 - view.previewImage.contentWidth / 2;
				view.previewImage.y = view.imageGroup.height / 2 - view.previewImage.contentHeight / 2;
				view.previewImage.visible = true;
				view.previewImage.removeEventListener(FlexEvent.UPDATE_COMPLETE, f);
			});
		}
		
		protected function onDataChange(event:IndexChangeEvent):void
		{
			dispatch(new LayoutEvent(LayoutEvent.CHANGE_BITMAP, view.imageDropDown.dataProvider[event.newIndex]["bitmap"]));
		}
		
		protected function onImageSelected(event:Event):void
		{
			view.loadImageInput.text = view.fileRef.name;
		}
		
		protected function onLoadImageInputClick(event:MouseEvent):void
		{
			var arr:Array = [];
			arr.push(new FileFilter("Images", ".gif;*.jpeg;*.jpg;*.png"));
			view.fileRef.browse(arr);
		}
		
		protected function onLoadImageClick(event:MouseEvent):void
		{
			view.fileRef.load();
		}
		
		protected function onFileLoaded(event:Event):void
		{
			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function f():void 
			{
				Alert.show("There was an error loading the image! Please try another, thank you and have a nice day.", "Error Loading Image")
			});
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function f():void
			{
				var bmd:BitmapData = new BitmapData(loader.width, loader.height);
				bmd.draw(loader);
				var bm:BitmapAsset = new BitmapAsset(bmd);

				assetProvider.addItemAt({bitmap : bm, contrastThreshold : 30, itemName : view.fileRef.name}, 0);
				assetProvider.refresh();
				view.imageDropDown.selectedIndex = 0;
				if (view.imageDropDown.selectedIndex == 0)
					view.imageDropDown.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE, false, false, 0, 0));
				
				view.loadImageInput.text = "";					
			});
			loader.loadBytes(view.fileRef.data);
		}
		
		protected function onSliderUpdate(event:Event):void
		{
			switch (event.currentTarget)
			{
				case view.gridInterval:
					dispatch(new LayoutEvent(LayoutEvent.LAYOUT_PROPERTY_CHANGED, null, {gridInterval : view.gridInterval.value}));
					break;
				case view.depthFactor:
					dispatch(new LayoutEvent(LayoutEvent.LAYOUT_PROPERTY_CHANGED, null, {depthFactor : view.depthFactor.value}));
					break;
				case view.contrastThreshold:
					dispatch(new LayoutEvent(LayoutEvent.LAYOUT_PROPERTY_CHANGED, null, {contrastThreshold : view.contrastThreshold.value}));
					break;
				default:
					break;
			}
		}
	
		protected function onAnimateSelect(event:Event):void
		{
			dispatch(new LayoutEvent(LayoutEvent.LAYOUT_PROPERTY_CHANGED, null, {animate : view.animate.selected}));
		}
		
		protected function onLayoutPropertyChange(event:LayoutEvent):void
		{
			if (event.layoutObject.hasOwnProperty("gridInterval")) view.gridInterval.value = event.layoutObject.gridInterval;
			if (event.layoutObject.hasOwnProperty("contrastThreshold")) view.contrastThreshold.value = event.layoutObject.contrastThreshold;
			if (event.layoutObject.hasOwnProperty("depthFactor")) view.depthFactor.value = event.layoutObject.depthFactor;
		}
		
		protected function onElementChange(event:ImageLayoutElementEvent):void
		{
			view.requiredElements = event.requiredElements;
			view.totalElements = event.totalElements;
		}
		
	}
}