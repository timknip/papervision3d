package org.papervision3d.objects
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.proto.DisplayObjectContainer3D;
	import org.papervision3d.materials.AbstractMaterial;
	
	/**
	 * 
	 */ 
	public class DisplayObject3D extends DisplayObjectContainer3D
	{
		/**
		 * 
		 */ 
		public var material:AbstractMaterial;
		public var geometry:VertexGeometry;
		 
		public var viewVertexData :Vector.<Number>;
		public var screenVertexData :Vector.<Number>;
		
		/**
		 * 
		 */ 
		public function DisplayObject3D(name:String=null)
		{
			super(name);
			viewVertexData = new Vector.<Number>();
			screenVertexData = new Vector.<Number>();
		}
	}
}