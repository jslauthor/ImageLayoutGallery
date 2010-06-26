package com.leonardsouza.demos.imagelayout.models
{
	import flash.display.Bitmap;
	
	import org.robotlegs.mvcs.*;

	public class LayoutModel extends Actor
	{
		private var _currentImage:Bitmap;
		
		public function LayoutModel()
		{
		}
		
		public function get currentImage():Bitmap
		{
			return _currentImage;
		}
		
		public function set currentImage(v:Bitmap):void
		{
			_currentImage = v;
			
		}
		
		
	}
}