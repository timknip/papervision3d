package org.papervision3d.core.render.draw.list
{
	import org.papervision3d.core.render.draw.items.IDrawable;
	
	public interface IDrawableList
	{
		function addDrawable(drawable:IDrawable):void;
		function clear():void;
		function get drawables():Vector.<IDrawable>; 
	}
}