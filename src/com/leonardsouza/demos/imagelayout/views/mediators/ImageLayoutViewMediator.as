package com.leonardsouza.demos.imagelayout.views.mediators
{

	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweenTimeline;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Back;
	import com.gskinner.motion.easing.Bounce;
	import com.gskinner.motion.easing.Sine;
	import com.leonardsouza.demos.imagelayout.events.LayoutEvent;
	import com.leonardsouza.demos.imagelayout.models.LayoutModel;
	import com.leonardsouza.demos.imagelayout.views.components.ImageLayoutView;
	import com.leonardsouza.display.layouts.events.ImageLayoutElementEvent;
	
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
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.BitmapAsset;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.graphics.SolidColor;
	import mx.managers.PopUpManager;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.Group;
	import spark.effects.Rotate3D;
	import spark.primitives.Rect;

	public class ImageLayoutViewMediator extends Mediator
	{

		[Inject]
		public var view:ImageLayoutView;
		
		[Inject]
		public var model:LayoutModel;
		
		override public function onRegister():void
		{
			eventMap.mapListener( eventDispatcher, LayoutEvent.BITMAP_CHANGED, onChangeBitmap );
			eventMap.mapListener( eventDispatcher, LayoutEvent.LAYOUT_PROPERTY_CHANGED, onLayoutPropertyChange )
			
			eventMap.mapListener( view, MouseEvent.MOUSE_MOVE, onContainerMouseMove );
			eventMap.mapListener( view, MouseEvent.ROLL_OUT, onContainerRollOut );
			eventMap.mapListener( view.imageLayout, ImageLayoutElementEvent.ELEMENT_CHANGE, function f(event:ImageLayoutElementEvent):void { dispatch(event); });
			
			// Define the number of elements for the layout
			var ac:ArrayCollection = new ArrayCollection();
			for (var p:int = 0; p < 1500; p++)
			{
				var rect:Rect = new Rect();
				rect.width = 15;
				rect.height = 10;
				rect.fill = new SolidColor(0xFFFFFF, 1);
				var grp:Group = new Group();
				grp.alpha = .5
				grp.addElement(rect);
				ac.addItem(grp);
			}
			view.dataProvider = ac;
			view.dgThumbnails.invalidateDisplayList();
			
			onChangeBitmap();
			dispatch(new LayoutEvent(LayoutEvent.LAYOUT_PROPERTY_CHANGED, null, {gridInterval : 35, contrastThreshold : 30, depthFactor : -15}));
		}

		protected function onChangeBitmap(event:LayoutEvent = null):void
		{
			view.imageLayout.source = new Bitmap(model.currentImage.bitmapData);
		}
		
		protected function onContainerRollOut(event:MouseEvent):void
		{
			var tween:GTween = new GTween(view.dgContainer, .25, {rotationX:0, rotationY:0}, {ease:Sine.easeIn});
		}
		
		protected function onContainerMouseMove(event:MouseEvent):void
		{
			var mousePoint:Point = new Point(FlexGlobals.topLevelApplication.mouseX, FlexGlobals.topLevelApplication.mouseY); 
			var point:Point = view.globalToLocal(mousePoint);
			view.dgContainer.rotationX = -1*((view.height - point.y*2)*.1);
			view.dgContainer.rotationY = (view.width - point.x*2)*.1;
		}
		
		protected function onLayoutPropertyChange(event:LayoutEvent):void
		{
			if (event.layoutObject.hasOwnProperty("gridInterval")) view.imageLayout.gridInterval = event.layoutObject.gridInterval;
			if (event.layoutObject.hasOwnProperty("contrastThreshold")) view.imageLayout.contrastThreshold = event.layoutObject.contrastThreshold;
			if (event.layoutObject.hasOwnProperty("depthFactor")) view.imageLayout.depthFactor = event.layoutObject.depthFactor;
			if (event.layoutObject.hasOwnProperty("animate")) view.imageLayout.animate = event.layoutObject.animate;
		}
		
	}
}