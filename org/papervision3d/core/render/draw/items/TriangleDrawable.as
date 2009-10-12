package org.papervision3d.core.render.draw.items
{
	import __AS3__.vec.Vector;
	
	import flash.display.GraphicsTrianglePath;
	
	public class TriangleDrawable extends AbstractDrawable
	{
		public var screenZ :Number;
		public var x0 :Number;
		public var y0 :Number;
		public var x1 :Number;
		public var y1 :Number;
		public var x2 :Number;
		public var y2 :Number;
		
		private var _path:GraphicsTrianglePath;
		
		public function TriangleDrawable()
		{
			this.screenZ = 0;
			_path = new GraphicsTrianglePath()
			
		}

		
		public function toViewportSpace(hw:Number, hh:Number):void{
			x0 *= hw;	
			y0 *= hh;
			x1 *= hw;
			y1 *= hh;
			x2 *= hw;
			y2 *= hh;
			
		}
		
		public function get path():GraphicsTrianglePath{
			_path.vertices = new Vector.<Number>();
			_path.vertices.push(x0, y0, x1, y1, x2, y2);
			return _path;
			
		}

	}
}