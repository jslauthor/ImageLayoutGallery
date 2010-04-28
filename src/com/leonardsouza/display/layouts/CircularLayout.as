package com.leonardsouza.display.layouts
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	public class CircularLayout extends LayoutBase
	{
		
		private var _radius:Number;
		
		public function get radius():Number
		{
			return _radius;
		}

		public function set radius(value:Number):void
		{
			_radius = value;
			
			if (!target)
				return;
			
			updateDisplayList(target.width, target.height);
		}

		override public function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			if (!target)
				return;
			
			var layoutElement:ILayoutElement;
			var count:uint = target.numElements;
			
			var w2:Number = target.width/2;
			var h2:Number = target.height/2;
			
			var angle:Number = 360/count; 
			var radius:Number = !isNaN(this.radius) ? this.radius : Math.min(w2, h2);
			
			for (var i:int = 0; i < count; i++)
			{
				layoutElement = target.getElementAt(i);
				
				if (!layoutElement || !layoutElement.includeInLayout)
					continue;
				
				var radAngle:Number = (angle * i) * (Math.PI / 180);
				var radDegree:Number = radAngle * 180 / Math.PI;
				
				var _x : Number = Math.sin( radAngle );
				var _y : Number = - Math.cos( radAngle );
				
				var matrix3D:Matrix3D = new Matrix3D();
				
				var elementWidth:Number = IVisualElement(layoutElement).width;
				var elementHeight:Number = IVisualElement(layoutElement).height;
				
				matrix3D.appendTranslation(-elementWidth/2, -elementHeight/2, 0);
				matrix3D.appendRotation(radDegree, Vector3D.Z_AXIS, new Vector3D((w2 + (_x * radius))-elementWidth/2, (h2 + (_y * radius))-elementHeight/2, 0));
				matrix3D.appendTranslation(elementWidth/2, elementHeight/2, 0);
				
				layoutElement.setLayoutMatrix3D(matrix3D, true);
			} 
		}

	}
}