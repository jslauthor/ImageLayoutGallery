/*
	Inversion of Control/Dependency Injection Using Robotlegs
	Image Gallery
	
	Any portion of this demonstration may be reused for any purpose where not 
	licensed by another party restricting such use. Please leave the credits intact.
	
	Joel Hooks
	http://joelhooks.com
	joelhooks@gmail.com 
*/
package com.leonardsouza.demos.imagelayout.events
{
	import flash.display.Bitmap;
	import flash.events.Event;
	
	public class LayoutEvent extends Event
	{
		public static const CHANGE_BITMAP:String = "changeBitmap";
		public static const BITMAP_CHANGED:String = "bitmapChanged";
		public static const LAYOUT_PROPERTY_CHANGED:String = "layoutPropertyChanged";
		
		public var bitmap:Bitmap;
		public var layoutObject:Object;
		
		public function LayoutEvent(type:String, bitmap:Bitmap = null, layoutObject:Object = null)
		{
			this.bitmap = bitmap;
			this.layoutObject = layoutObject;
			super(type, true, true);
		}
		
		override public function clone() : Event
		{
			return new LayoutEvent(type, bitmap);
		}
	}
}