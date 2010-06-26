package com.leonardsouza.demos.imagelayout.views.mediators
{
	import com.leonardsouza.demos.imagelayout.events.LayoutEvent;
	import com.leonardsouza.demos.imagelayout.models.LayoutModel;
	import com.leonardsouza.demos.imagelayout.models.vo.AssetProvider;
	import com.leonardsouza.demos.imagelayout.views.components.ScratchPad;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.Group;
	import spark.primitives.Ellipse;
	import spark.skins.spark.HSliderSkin;
	
	public class ScratchPadMediator extends Mediator
	{
		
		[Inject]
		public var view:ScratchPad;
		
		[Inject]
		public var model:LayoutModel;
		
		[Inject]
		public var assetProvider:AssetProvider;
		
		private var lastMousePoint:Point;

		private var brushTipSize:int;
		
		override public function onRegister():void
		{
			eventMap.mapListener( view.bitmapImage, MouseEvent.MOUSE_MOVE, captureMouseInput );
			eventMap.mapListener( view.bitmapImage, MouseEvent.MOUSE_UP, changeLayout );
			eventMap.mapListener( view.bitmapImage, MouseEvent.MOUSE_OUT, changeLayout );
			eventMap.mapListener( view.tip1, MouseEvent.CLICK, changeToolSize );
			eventMap.mapListener( view.tip2, MouseEvent.CLICK, changeToolSize );
			eventMap.mapListener( view.tip3, MouseEvent.CLICK, changeToolSize );
			eventMap.mapListener( view.tip4, MouseEvent.CLICK, changeToolSize );
			eventMap.mapListener( view.tip5, MouseEvent.CLICK, changeToolSize );
			eventMap.mapListener( view.eraser, MouseEvent.CLICK, clearScratchPad );
			
			view.bitmap = new Bitmap(new BitmapData(view.bitmapImage.width, view.bitmapImage.height, false, 0x000000));
			view.tip1.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		protected function changeToolSize(event:MouseEvent):void
		{
			brushTipSize = Ellipse(event.currentTarget.getElementAt(x)).width;
			for (var x:int = 0; x < view.tools.numElements; x++)
			{
				if (event.currentTarget != view.tools.getElementAt(x))
					Ellipse(Group(view.tools.getElementAt(x)).getElementAt(0)).fill = new SolidColor(0x888888);
				else
					Ellipse(Group(view.tools.getElementAt(x)).getElementAt(0)).fill = new SolidColor(0xFFFFFF);
			}
		}
	
		protected function clearScratchPad(event:MouseEvent):void
		{
			view.bitmap.bitmapData.fillRect(new Rectangle(0, 0, view.bitmapImage.width, view.bitmapImage.height), 0x00000000);
			dispatch(new LayoutEvent(LayoutEvent.CHANGE_BITMAP, view.bitmap));
		}
		
		protected function captureMouseInput(event:MouseEvent):void
		{
			if (event.buttonDown)
			{
				//var bmd:BitmapData = new BitmapData(view.tip1.width, view.tip1.height);
				//bmd.draw(currentTip);
				
				var shape:Shape = new Shape();
				shape.width = view.bitmap.width;
				shape.height = view.bitmap.height;
				shape.graphics.lineStyle(brushTipSize, view.colorPicker.selectedColor, view.alphaSlider.value / 100);
				//shape.graphics.lineBitmapStyle(bmd);
				shape.graphics.moveTo(lastMousePoint.x, lastMousePoint.y); 
				shape.graphics.lineTo(event.localX, event.localY);
				shape.graphics.endFill();
				view.bitmap.bitmapData.draw(shape, new Matrix(1, 0, 0, 1, 0, 0));
				lastMousePoint = new Point(event.localX, event.localY);
				
				//bmd.dispose();
			}
			else
			{
				lastMousePoint = new Point(event.localX, event.localY);
			}
		}
		
		protected function changeLayout(event:MouseEvent):void
		{
			if (event.type == MouseEvent.MOUSE_OUT && !event.buttonDown)
				return;

			dispatch(new LayoutEvent(LayoutEvent.CHANGE_BITMAP, view.bitmap));
		}
		
	}
}