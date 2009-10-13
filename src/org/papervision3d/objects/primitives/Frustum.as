package org.papervision3d.objects.primitives
{
	import org.papervision3d.core.geom.Line;
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
		public var nbl :Vertex;
		public var nbr :Vertex;
		public var ntr :Vertex;
		public var ftl :Vertex;
		public var fbl :Vertex;
		public var fbr :Vertex;
		public var ftr :Vertex;
		
		/**
		 * 
		 */ 
		public function Frustum(material:AbstractMaterial, name:String=null)
		{
			super(name);
			
			this.material = material;	
			this.geometry = new LineGeometry();
			
			init();
		}
		
		/**
		 * 
		 */
		protected function init():void
		{
			var lineGeometry :LineGeometry = geometry as lineGeometry;
			
			nc = geometry.addVertex(new Vertex());
			fc = geometry.addVertex(new Vertex());
			
			ntl = geometry.addVertex(new Vertex());
			nbl = geometry.addVertex(new Vertex());
			nbr = geometry.addVertex(new Vertex());
			ntr = geometry.addVertex(new Vertex());
			
			ftl = geometry.addVertex(new Vertex());
			fbl = geometry.addVertex(new Vertex());
			fbr = geometry.addVertex(new Vertex());
			ftr = geometry.addVertex(new Vertex());
			
			lineGeometry.addLine( new Line(material, ntl, nbl) );
			lineGeometry.addLine( new Line(material, nbl, nbr) );
			lineGeometry.addLine( new Line(material, nbr, ntr) );
			lineGeometry.addLine( new Line(material, ntr, ntl) );
			
			lineGeometry.addLine( new Line(material, ftl, fbl) );
			lineGeometry.addLine( new Line(material, fbl, fbr) );
			lineGeometry.addLine( new Line(material, fbr, ftr) );
			lineGeometry.addLine( new Line(material, ftr, ftl) );
			
			lineGeometry.addLine( new Line(material, ntl, ftl) );
			lineGeometry.addLine( new Line(material, nbl, fbl) );
			lineGeometry.addLine( new Line(material, nbr, fbr) );
			lineGeometry.addLine( new Line(material, ntr, ftr) );
		} 
	}
}