package com.leonardsouza.display.layouts.events
{
	import flash.events.Event;
	
	public class ImageLayoutElementEvent extends Event
	{
		
		public static const ELEMENT_CHANGE:String = "elementChange";
		
		public var requiredElements:uint;
		public var totalElements:uint;
		
		public function ImageLayoutElementEvent(type:String, requiredElements:uint, totalElements:uint)
		{
			this.requiredElements = requiredElements;
			this.totalElements = totalElements;
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new ImageLayoutElementEvent(type, requiredElements, totalElements); 
		}
	}
}