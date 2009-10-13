package org.papervision3d.objects.primitives
{
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.geom.provider.LineGeometry;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * 
	 */ 
	public class Frustum extends DisplayObject3D
	{
		public var nc  :Vertex;
		public var fc  :Vertex;
		public var ntl :Vertex;
		/**
		 * 
		 */ 
		public function Frustum(name:String=null)
		{
			super(name);
			
			this.geometry = new LineGeometry();
		}
	}
}