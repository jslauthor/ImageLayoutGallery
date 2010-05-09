package com.leonardsouza.display.layouts
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import mx.controls.Image;
	import mx.core.FlexGlobals;
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import org.flexunit.internals.namespaces.classInternal;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class ImageLayout extends LayoutBase
	{

		/*
		** Variable declarations
		*/
		
		private var _contrastThreshold:uint = 50;
		private var _gridInterval:uint = 10;
		private var _source:Bitmap;
		private var _requiredElements:int;
		private var _depthFactor:int = 10;
		
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
		
		public function get contrastThreshold():uint
		{
			return _contrastThreshold;
		}

		[Inspectable(category="Layout Constraints", defaultValue=50)]
		public function set contrastThreshold(value:uint):void
		{
			_contrastThreshold = value;
			if (target) target.invalidateDisplayList();
		}
		
		[Inspectable(category="Layout Constraints", defaultValue=10)]
		public function get gridInterval():uint
		{
			return _gridInterval;
		}
		
		public function set gridInterval(value:uint):void
		{
			_gridInterval = value < 1 ? 1 : value;
			
			if (target) target.invalidateDisplayList();
		}

		[Inspectable(category="Layout Constraints", defaultValue=10)]
		public function get depthFactor():int
		{
			return _depthFactor;
		}
		
		public function set depthFactor(value:int):void
		{
			_depthFactor = value;
		}
		
		public function get requiredElements():int
		{
			return _requiredElements;
		}
		
		public function set requiredElements(value:int):void
		{
			_requiredElements = value;
		}
		
		/*
		** Protected functions
		*/
		
		protected function arrangeByImage():void
		{
			if (!target || !_source) return;
			
			_layoutVector = new Vector.<Vector3D>();
			
			// scale the image to the width and height of the target to interpolate the points
			var nonScaledWidth:int = _source.width / _source.scaleX;
			var nonScaledHeight:int = _source.height / _source.scaleY;

			_source.scaleX = target.width / nonScaledWidth;
			_source.scaleY = target.height / nonScaledHeight;
			
			var scaledSource:BitmapData = new BitmapData(_source.width, _source.height, true, 0x000000);
			scaledSource.draw(_source, _source.transform.matrix);

			var rectWidth:Number = _source.width / gridInterval;
			var rectHeight:Number = _source.height / gridInterval;
			
			var columnCount:Number = _source.width / rectWidth;
			var rowCount:Number = _source.height / rectHeight;
			
			var i:Number;
			var j:Number;
			
			var reqElements:int = 0;
			
			for (i = 0; i < rowCount; i++)
			{
				for (j = 0; j < columnCount; j++)
				{
					var rect:Rectangle = new Rectangle(j * rectWidth, i * rectHeight, rectWidth, rectHeight);
					var bm:BitmapData = new BitmapData(rectWidth, rectHeight, false, 0x000000);
					bm.copyPixels(scaledSource, rect, new Point(0, 0));

					var brightnessPercentage:Number = averageColor(bm)/0xFFFFFF;
					if (brightnessPercentage * 100 >= contrastThreshold)
					{
						_layoutVector.push(new Vector3D(j * rectWidth, i * rectHeight, brightnessPercentage * depthFactor));	
						reqElements++;
					}
					else
					{
						_layoutVector.push(null);
					}
					
					bm.dispose();
				}
			}
			
			requiredElements = reqElements;
			scaledSource.dispose();
		}
		
		/*
		** Overrides
		*/
		
		override public function updateDisplayList(w:Number, h:Number):void
		{
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
			var elementCounter:int = 0;
			for (i = 0; i < _layoutVector.length; i++)
			{
				try
				{
					el = target.getElementAt(elementCounter);
					if (elementCounter >= numElements) throw RangeError("Not enough elements");
					vec3D = _layoutVector[i];
					if (vec3D != null)
					{
						if (!el || !el.includeInLayout) continue;
						
						UIComponent(el).visible = true;
						matrix = el.getLayoutMatrix3D();
						var newVector:Vector.<Vector3D> = matrix.decompose();
						newVector[0] = vec3D;
						matrix.recompose(newVector);
						el.setLayoutMatrix3D(matrix, false);	
						elementCounter++;
					}
					else
					{
						UIComponent(el).visible = false;
					}
				}
				catch (error:RangeError)
				{
					//trace(error.message);
				}
			}
			
			// Remove any remaining elements from the grid
			if (elementCounter < numElements)
			{
				for (var v:int = elementCounter; v < numElements; v++)
				{
					el = target.getElementAt(v);
					UIComponent(el).visible = false;
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