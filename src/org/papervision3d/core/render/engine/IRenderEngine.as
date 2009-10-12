package org.papervision3d.core.render.engine
{
	import org.papervision3d.core.render.data.RenderData;
	
	public interface IRenderEngine
	{
		function renderScene(renderData:RenderData):void;
	}
}