package com.leonardsouza.display.layouts
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import mx.controls.Image;
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import org.flexunit.internals.namespaces.classInternal;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	public class ImageLayout extends LayoutBase
	{

		/*
		** Variable declarations
		*/
		
		private var _brightnessScale:uint = 100;
		private var _granularity:uint = 200;
		private var _source:Bitmap;
		
		protected var _layoutVector:Vector.<Vector3D>;

		/*
		** Constructor and Initialization
		*/

		public function ImageLayout():void { super(); }
		
		/*
		** Getter & Setters
		*/
		
		public function get source():Bitmap
		{
			return _source;
		}
		
		public function set source(value:Bitmap):void
		{
			_source = value;
			if (target) target.invalidateDisplayList();
		}
		
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
		
		/*
		** Public functions
		*/
		
		public function arrangeByImage():void
		{
			if (!target || !_source) return;
			
			var columnCount:Number = _source.width / granularity;
			var rowCount:Number = _source.height / granularity;
			var rectWidth:Number = _source.width / columnCount;
			var rectHeight:Number = _source.height / rowCount;
			
			trace(_source.height, _source.width, columnCount, rowCount, rectWidth, rectHeight);
			
			var i:int;
			var j:int;
			
			for (i = 0; i <= rowCount; i++)
			{
				for (j = 0; j <= columnCount; j++)
				{
					
				}
			}
		}

		/*
		** Overrides
		*/
		
		override public function updateDisplayList(w:Number, h:Number):void
		{
			trace("Update Display");
			if (!target || !_source) return;
			super.updateDisplayList(w, h);

			arrangeByImage();
			
			var el:ILayoutElement;
			var numElements:uint = target.numElements;
			var matrix:Matrix3D;
			var i:int = 0;
			
			if (!_layoutVector)
			{
				for (i = 0; i < numElements; i++)
				{
					el = target.getElementAt(i);
					if (!el || !el.includeInLayout) continue;
						
					matrix = new Matrix3D();
					matrix.appendTranslation(0, 0, 0);
					el.setLayoutMatrix3D(matrix, false);					
				}			
				return;
			}
			
			var vec3D:Vector3D;
			
			for (i = 0; i < numElements; i++)
			{
				try
				{
					el = target.getElementAt(i);
					vec3D = _layoutVector[i];
					
					if (!el || !el.includeInLayout) continue;
					
					matrix = new Matrix3D();
					matrix.appendTranslation(vec3D.x, vec3D.y, vec3D.z);
					el.setLayoutMatrix3D(matrix, false);					
				}
				catch (error:RangeError)
				{
					break;
				}
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