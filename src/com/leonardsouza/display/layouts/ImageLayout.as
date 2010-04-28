package com.leonardsouza.display.layouts
{
	import flash.display.Bitmap;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	public class ImageLayout extends LayoutBase
	{

		/*
		** Variable declarations
		*/
		
		private var _brightnessScale:uint;
		
		private var _granularity:uint;
		private var _requestedRowCount:uint;
		private var _requestedColumnCount:uint;
		
		protected var _layoutVector:Vector.<Vector3D>;

		/*
		** Constructor
		*/

		public function ImageLayout(bitmap:Bitmap = null):void { super(); arrangeByBitmap(bitmap); }

		/*
		** Getter & Setters
		*/
		
		public function get brightnessScale():uint
		{
			return _brightnessScale;
		}

		[Inspectable(category="Layout Constraints", defaultValue=200)]
		public function get granularity():uint
		{
			return _granularity;
		}
		
		public function set granularity(value:uint):void
		{
			_granularity = value;
		}
		
		[Inspectable(category="Layout Constraints", defaultValue=100)]
		public function set brightnessScale(value:uint):void
		{
			_brightnessScale = value;
		}

		public function get requestedRowCount():uint
		{
			return _requestedRowCount;
		}
		
		[Inspectable(category="Layout Contraints", defaultValue=10)]
		public function set requestedRowCount(value:uint):void
		{
			_requestedRowCount = value;
		}
		
		public function get requestedColumnCount():uint
		{
			return _requestedColumnCount;
		}
		
		[Inspectable(category="Layout Contraints", defaultValue=10)]
		public function set requestedColumnCount(value:uint):void
		{
			_requestedColumnCount = value;
		}
		
		/*
		** Public functions
		*/
		
		public function arrangeByBitmap(bitmap:Bitmap):void
		{
			if (!target) return;
			
			if (bitmap != null)
			{
				
			}
			else
			{
				_layoutVector = new Vector.<Vector3D>();
				for (var i:int = 0; i <= requestedRowCount; i++)
				{
					for (var j:int = 0; j <= requestedColumnCount; j++)
					{
						_layoutVector[j + i] = new Vector3D(i, j, i+j);
					}
				}
			}
			
			updateDisplayList(target.width, target.height);
		}

		/*
		** Overrides
		*/
		
		override public function updateDisplayList(w:Number, h:Number):void
		{
			if (!target) return;
			super.updateDisplayList(w, h);
			
			var el:ILayoutElement;
			var numElements:uint = target.numElements;
			
			for (var i:int = 0; i < numElements; i++);
			{
				el = target.getElementAt(i);
				if (!el || !el.includeInLayout || _layoutVector[i] != null) continue;

				var matrix:Matrix3D = new Matrix3D(_layoutVector[i]);
				el.setLayoutMatrix3D(matrix, false);
			}
		}
		
		/*
		** Utility Methods
		*/
		
		private function averageColor(source:BitmapData):uint
		{
			var red:Number = 0;
			var green:Number = 0;
			var blue:Number = 0;
			
			var count:Number = 0;
			var pixel:Number;
			
			for (var x:int = 0; x < source.width; x++)
			{
				for (var y:int = 0; y < source.height; y++)
				{
					pixel = source.getPixel(x, y);
					
					red += pixel >> 16 & 0xFF;
					green += pixel >> 8 & 0xFF;
					blue += pixel & 0xFF;
					
					count++
				}
			}
			
			red /= count;
			green /= count;
			blue /= count;
			
			return red << 16 | green << 8 | blue;
		}

	}
}