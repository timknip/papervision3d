package org.papervision3d.core.geom.provider
{
	import org.papervision3d.core.geom.Triangle;
	
	public class TriangleGeometry extends VertexGeometry
	{
		/** */
		public var triangles :Vector.<Triangle>; 
		/**
		 * 
		 */ 
		public function TriangleGeometry(name:String=null)
		{
			super(name);
			
			this.triangles = new Vector.<Triangle>();
		}
		
		/**
		 * Adds a triangle.
		 * 
		 * @param	triangle
		 * 
		 * @return The added triangle.
		 */ 
		public function addTriangle(triangle:Triangle):Triangle
		{
			var index :int = triangles.indexOf(triangle);
			
			if (index < 0)
			{
				triangle.v0 = addVertex(triangle.v0);
				triangle.v1 = addVertex(triangle.v1);
				triangle.v2 = addVertex(triangle.v2);
				
				triangles.push(triangle);
				
				return triangle;	
			}
			else
			{
				return triangles[index];
			}
		}
	}
}