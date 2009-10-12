package org.papervision3d.core.render.raster
{
	import __AS3__.vec.Vector;
	
	import flash.display.IGraphicsData;
	
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.core.render.draw.list.IDrawableList;
	import org.papervision3d.view.Viewport3D;
	
	public class DefaultRasterizer implements IRasterizer
	{
		public var drawArray:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
		
		public function DefaultRasterizer()
		{
		}

		public function rasterize(renderList:IDrawableList, viewport:Viewport3D):void{
			
			var hw :Number = viewport.viewportWidth / 2;
			var hh :Number = viewport.viewportHeight / 2;
			drawArray.length = 0;
			viewport.containerSprite.graphics.clear();	

				for each (var drawable :TriangleDrawable in renderList.drawables)
				{

					drawable.toViewportSpace(hw, -hh);
					drawArray.push(drawable.material.drawProperties, drawable.path, drawable.material.clear);

				}

			viewport.containerSprite.graphics.drawGraphicsData(drawArray);
			
		}
	}
}