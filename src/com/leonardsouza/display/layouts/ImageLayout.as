package com.leonardsouza.display.layouts
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Back;
	import com.gskinner.motion.easing.Sine;
	import com.leonardsouza.display.layouts.events.ImageLayoutElementEvent;
	
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
		
		public static var ANIMATION_EXPLODE:String = "explosionAnimation";
		
		private var _contrastThreshold:uint = 50;
		private var _gridInterval:uint = 10;
		private var _source:Bitmap;
		private var _requiredElements:int;
		private var _depthFactor:int = 10;
		
		private var _animate:Boolean = false;
		private var _animationType:String = ANIMATION_EXPLODE;
		private var _animationDuration:int = 1;
		private var _animationStrength:int = 400;
		private var _animationEase:Function = Back.easeInOut;
		
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
			if (target) target.invalidateDisplayList();
		}
		
		public function get requiredElements():int
		{
			return _requiredElements;
		}
		
		public function set requiredElements(value:int):void
		{
			_requiredElements = value;
		}

		public function get animate():Boolean
		{
			return _animate;
		}
		
		public function set animate(value:Boolean):void
		{
			_animate = value;
		}

		public function get animationType():String
		{
			return _animationType;
		}
		
		public function set animationType(value:String):void
		{
			_animationType = value;
		}

		public function get animationEase():Function
		{
			return _animationEase;
		}
		
		public function set animationEase(value:Function):void
		{
			_animationEase = value;
		}
		
		public function get animationStrength():int
		{
			return _animationStrength;
		}
		
		public function set animationStrength(value:int):void
		{
			_animationStrength = value;
		}
		
		public function get animationDuration():int
		{
			return _animationDuration;
		}
		
		public function set animationDuration(value:int):void
		{
			_animationDuration = value;
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
			dispatchEvent(new ImageLayoutElementEvent(ImageLayoutElementEvent.ELEMENT_CHANGE, requiredElements, target.numElements));
			scaledSource.dispose();
		}
		
		/*
		** Overrides
		*/
		
		override public function updateDisplayList(w:Number, h:Number):void
		{
			if (!target || !_source || _source.height + _source.width < 2) return;
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
						
						if (animate)
						{
							var originVector:Vector.<Vector3D> = matrix.decompose();
							//originVector[0] = new Vector3D(Math.random()*animationStrength, Math.random()*animationStrength, randNeg()*Math.random()*animationStrength);
							originVector[0] = new Vector3D(vec3D.x, vec3D.y, randNeg()*Math.random()*animationStrength);
							var tweenProxyObject:Object = {x:originVector[0].x, y:originVector[0].y, z:originVector[0].z};
							matrix.recompose(originVector);
							el.setLayoutMatrix3D(matrix, false);
							
							var tween:GTween = new GTween();
							tween.autoPlay = false;
							tween.target = tweenProxyObject;
							tween.data = {element:el, origin:originVector};
							tween.setValues({x:vec3D.x, y:vec3D.y, z:vec3D.z});
							tween.ease = animationEase;
							tween.duration = animationDuration;
							tween.onChange = function f():void
							{
								var el:ILayoutElement = ILayoutElement(this.data.element);
								var mtx:Matrix3D = el.getLayoutMatrix3D();
								Vector.<Vector3D>(this.data.origin)[0] = new Vector3D(this.target.x, this.target.y, this.target.z);
								mtx.recompose(Vector.<Vector3D>(this.data.origin));
								el.setLayoutMatrix3D(mtx, false);
							}
							tween.paused = false;
						}
						else
						{
							var newVector:Vector.<Vector3D> = matrix.decompose();
							newVector[0] = vec3D;
							matrix.recompose(newVector);
							el.setLayoutMatrix3D(matrix, false);	
						}
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

		private function randNeg():int
		{
			return Math.random() >= .5 ? 1 : -1;
		}
		
	}
}