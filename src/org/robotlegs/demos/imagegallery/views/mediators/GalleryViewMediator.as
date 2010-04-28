/*
	Inversion of Control/Dependency Injection Using Robotlegs
	Image Gallery
	
	Any portion of this demonstration may be reused for any purpose where not 
	licensed by another party restricting such use. Please leave the credits intact.
	
	Joel Hooks
	http://joelhooks.com
	joelhooks@gmail.com 
*/
package org.robotlegs.demos.imagegallery.views.mediators
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweenTimeline;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Back;
	import com.gskinner.motion.easing.Bounce;
	import com.gskinner.motion.easing.Sine;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.managers.PopUpManager;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	import org.robotlegs.demos.imagegallery.events.GalleryEvent;
	import org.robotlegs.demos.imagegallery.events.GalleryImageEvent;
	import org.robotlegs.demos.imagegallery.events.GallerySearchEvent;
	import org.robotlegs.demos.imagegallery.models.GalleryModel;
	import org.robotlegs.demos.imagegallery.models.vo.Gallery;
	import org.robotlegs.demos.imagegallery.models.vo.GalleryImage;
	import org.robotlegs.demos.imagegallery.views.components.GallerySearchProgress;
	import org.robotlegs.demos.imagegallery.views.components.GalleryView;
	import org.robotlegs.mvcs.Mediator;
	
	import spark.effects.Rotate3D;

	public class GalleryViewMediator extends Mediator
	{
		[Inject]
		public var galleryView:GalleryView;
		
		[Inject]
		public var proxy:GalleryModel;
		
		private var progress:GallerySearchProgress = new GallerySearchProgress();
		private var selectedImageVector:Vector.<BitmapData>;

		override public function onRegister():void
		{
			eventMap.mapListener( galleryView, GalleryImageEvent.SELECT_GALLERY_IMAGE, onImageSelected )
			eventMap.mapListener( eventDispatcher, GalleryEvent.GALLERY_LOADED, onGalleryLoaded )
			
			eventMap.mapListener( galleryView.dgContainer, MouseEvent.MOUSE_MOVE, onContainerMouseMove )
			eventMap.mapListener( galleryView.dgContainer, MouseEvent.ROLL_OUT, onContainerRollOut )
			
			eventDispatcher.dispatchEvent( new GalleryEvent( GalleryEvent.LOAD_GALLERY ) );
			
			var filter:Rotate3D = new Rotate3D();
			filter.autoCenterProjection = true;
			filter.autoCenterTransform = true;
			galleryView.rotateFilter = filter;
		}
		
		protected function onContainerRollOut(event:MouseEvent):void
		{
			var tween:GTween = new GTween(galleryView.dgContainer, .25, {rotationX:0, rotationY:0}, {ease:Sine.easeIn});
		}
		
		protected function onContainerMouseMove(event:MouseEvent):void
		{
			var mousePoint:Point = new Point(FlexGlobals.topLevelApplication.mouseX, FlexGlobals.topLevelApplication.mouseY); 
			var point:Point = galleryView.dgContainer.globalToLocal(mousePoint);
			galleryView.dgContainer.rotationX = -1*((galleryView.dgContainer.height - point.y*2)*.05);
			galleryView.dgContainer.rotationY = (galleryView.dgContainer.width - point.x*2)*.01;
		}
		
		protected function selectImage(image:GalleryImage):void
		{

		}
		
		protected function onGalleryLoaded(event:GalleryEvent):void
		{
			galleryView.dataProvider = event.gallery.photos;
			galleryView.dgThumbnails.invalidateDisplayList();
		}
		
		protected function onImageSelected(event:GalleryImageEvent):void
		{
			selectImage(event.image);
		}
	}
}