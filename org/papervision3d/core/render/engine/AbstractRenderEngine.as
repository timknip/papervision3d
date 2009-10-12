package org.papervision3d.core.render.engine
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.pipeline.IRenderPipeline;
	
	public class AbstractRenderEngine extends EventDispatcher implements IRenderEngine
	{
		public var pipeline :IRenderPipeline;
		
		public function AbstractRenderEngine(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function renderScene(renderData:RenderData):void
		{
			
		}
	}
}