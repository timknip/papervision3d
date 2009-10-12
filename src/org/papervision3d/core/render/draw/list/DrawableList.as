package org.papervision3d.core.render.draw.list
{
	import org.papervision3d.core.render.draw.items.IDrawable;
	
	public class DrawableList extends AbstractDrawableList implements IDrawableList
	{
		private var _drawables :Vector.<IDrawable>;
		
		public function DrawableList()
		{
			_drawables = new Vector.<IDrawable>();
		}

		public override function addDrawable(drawable:IDrawable):void
		{
			_drawables.push(drawable);
		}
		
		public override function clear():void
		{
			_drawables.length = 0;
		}
		
		public override function get drawables():Vector.<IDrawable>
		{
			return _drawables;
		}
	}
}