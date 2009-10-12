package org.papervision3d.core.render.draw.list
{
	import org.papervision3d.core.render.draw.items.IDrawable;

	public class AbstractDrawableList implements IDrawableList
	{
		public function AbstractDrawableList()
		{
		}

		public function addDrawable(drawable:IDrawable):void
		{
		}
		
		public function clear():void
		{
		}
		
		public function get drawables():Vector.<IDrawable>
		{
			return null;
		}
		
	}
}