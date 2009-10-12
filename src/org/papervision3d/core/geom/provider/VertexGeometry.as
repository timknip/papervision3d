package org.papervision3d.core.geom.provider
{
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.ns.pv3d;
	
	public class VertexGeometry
	{
		
		
		public var vertices :Vector.<Vertex>;
		
		public var uvtData :Vector.<Number>;
		public var vertexData :Vector.<Number>;
		public var viewVertexData :Vector.<Number>;
		public var screenVertexData :Vector.<Number>;
		
		
		/**
		 * Constructor
		 */ 
		public function VertexGeometry(name:String=null)
		{
			
			
			vertices = new Vector.<Vertex>();
			
			vertexData = new Vector.<Number>();
			viewVertexData = new Vector.<Number>();
			screenVertexData = new Vector.<Number>();
			uvtData = new Vector.<Number>();
		}
		
		/**
		 * Adds a new Vertex.
		 * 
		 * @param	vertex
		 * 
		 * @return The added vertex.
		 * 
		 * @see org.papervision3d.core.geom.Vertex
		 */ 
		public function addVertex(vertex:Vertex):Vertex 
		{
			var index :int = vertices.indexOf(vertex);
			
			if (index >= 0)
			{
				return vertices[index];
			}
			else
			{
				vertex.vertexGeometry = this;
				
				vertex.vectorIndexX = vertexData.push(vertex.x) - 1;
				vertex.vectorIndexY = vertexData.push(vertex.y) - 1;
				vertex.vectorIndexZ = vertexData.push(vertex.z) - 1;
				vertex.screenIndexX = screenVertexData.push(vertex.x) - 1;
				vertex.screenIndexY = screenVertexData.push(vertex.y) - 1;
				viewVertexData.push(vertex.x, vertex.y, vertex.z);
				uvtData.push(0, 0, 0);
				vertices.push(vertex);
				
				return vertex;
			}
		}
		
		/**
		 * Removes a new Vertex.
		 * 
		 * @param	vertex	The vertex to remove.
		 * 
		 * @return The removed vertex or null on failure.
		 * 
		 * @see org.papervision3d.core.geom.Vertex
		 */ 
		public function removeVertex(vertex:Vertex):Vertex 
		{
			var index :int = vertices.indexOf(vertex);
			
			if (index < 0)
			{
				return null;
			}
			else
			{
				vertices.splice(index, 1);
				
				vertex.vertexGeometry = null;
				vertex.vectorIndexX = vertex.vectorIndexY = vertex.vectorIndexZ = -1;
				vertex.screenIndexX = vertex.screenIndexY = -1;
				
				updateIndices();
				
				return vertex;
			}
		}
		
		/**
		 * 
		 */ 
		public function updateIndices():void
		{
			var vertex :Vertex;
			
			vertexData.length = 0;
			viewVertexData.length = 0;
			screenVertexData.length = 0;
			uvtData.length = 0;
			
			for each (vertex in vertices)
			{
				vertex.vectorIndexX = vertexData.push(vertex.x) - 1;
				vertex.vectorIndexY = vertexData.push(vertex.y) - 1;
				vertex.vectorIndexZ = vertexData.push(vertex.z) - 1;
				vertex.screenIndexX = screenVertexData.push(vertex.x) - 1;
				vertex.screenIndexY = screenVertexData.push(vertex.y) - 1;
				viewVertexData.push(vertex.x, vertex.y, vertex.z);
				uvtData.push(0, 0, 0);
			}
		}
	}
}