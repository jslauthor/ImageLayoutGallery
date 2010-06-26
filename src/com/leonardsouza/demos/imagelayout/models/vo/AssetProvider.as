package com.leonardsouza.demos.imagelayout.models.vo
{
	import mx.collections.ArrayCollection;
	import mx.core.BitmapAsset;
	
	public class AssetProvider extends ArrayCollection
	{
		
		[Embed('assets/RobotLegsLogoSmallWeb.png')]
		public var rlLogoSmallPNG:Class; 
		
		[Embed('assets/fish.jpg')]
		public var fishJPG:Class; 
		
		[Embed('assets/smiley.jpg')]
		public var smileyJPG:Class; 
		
		[Embed('assets/walk_sign.jpg')]
		public var walkSignJPG:Class; 
		
		[Embed('assets/hello_world.png')]
		public var helloWorldPNG:Class; 
		
		public function AssetProvider()
		{
			addItem({bitmap : new rlLogoSmallPNG() as BitmapAsset, contrastThreshold : 40, itemName : "RobotLegs Logo"});
			addItem({bitmap : new fishJPG() as BitmapAsset, contrastThreshold : 10, itemName : "Fish"});
			addItem({bitmap : new smileyJPG() as BitmapAsset, contrastThreshold : 10, itemName : "Smiley Face"});
			addItem({bitmap : new walkSignJPG() as BitmapAsset, contrastThreshold : 10, itemName : "Walk Sign"});
			addItem({bitmap : new helloWorldPNG() as BitmapAsset, contrastThreshold : 10, itemName : "Hello World"});
		}
	}
}