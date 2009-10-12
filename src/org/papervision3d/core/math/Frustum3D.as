package org.papervision3d.core.math
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	
	public class Frustum3D
	{
		public static const WORLD_PLANES :uint = 0;
		public static const VIEW_PLANES :uint = 1;
		public static const SCREEN_PLANES :uint = 2;
		
		public static const NEAR :uint = 0;
		public static const FAR :uint = 1;
		public static const LEFT :uint = 2;
		public static const RIGHT :uint = 3;
		public static const TOP :uint = 4;
		public static const BOTTOM :uint = 5;
		
		public var camera :Camera3D;
		public var screenClippingPlanes :Vector.<Plane3D>;
		public var viewClippingPlanes :Vector.<Plane3D>;
		public var worldClippingPlanes :Vector.<Plane3D>;
		
		public var worldBoundingSphere :BoundingSphere3D;
		
		/**
		 * 
		 */ 
		public function Frustum3D(camera:Camera3D)
		{
			this.camera = camera;
			this.worldBoundingSphere = new BoundingSphere3D();
			initPlanes();
		}
		
		/**
		 * 
		 */ 
		protected function initPlanes():void 
		{
			var i :int;
			
			this.screenClippingPlanes = new Vector.<Plane3D>(6, true);
			this.viewClippingPlanes = new Vector.<Plane3D>(6, true);
			this.worldClippingPlanes = new Vector.<Plane3D>(6, true);
			
			for (i = 0; i < 6;  i++)
			{
				this.screenClippingPlanes[i] = Plane3D.fromCoefficients(0, 0, 1, 0);
				this.viewClippingPlanes[i] = Plane3D.fromCoefficients(0, 0, 1, 0);
				this.worldClippingPlanes[i] = Plane3D.fromCoefficients(0, 0, 1, 0);
			}	
			
			this.screenClippingPlanes[ NEAR ].setCoefficients(0, 0, -1, 1);
			this.screenClippingPlanes[ FAR ].setCoefficients(0, 0, 1, 1);
			this.screenClippingPlanes[ LEFT ].setCoefficients(1, 0, 0, 1);
			this.screenClippingPlanes[ RIGHT ].setCoefficients(-1, 0, 0, 1);
			this.screenClippingPlanes[ TOP ].setCoefficients(0, -1, 0, 1);
			this.screenClippingPlanes[ BOTTOM ].setCoefficients(0, 1, 0, 1);
		}
		
		/**
		 * Extract frustum planes.
		 * 
		 * @param matrix		The matrix to extract the planes from (P for eye-space, M*P for world-space).
		 * @param planes		The planes to extract to.
		 * @param normalize		Whether to normalize the planes. Default is true.
		 * @param flipNormals	Whether to flip the plane normals. Default is true.
		 * 						NDC is lefthanded (looking down +Z), eye-space is righthanded (looking down -Z).
		 * 						Setting @flipNormals to true makes the frustum looking down +Z.
		 */
		public function extractPlanes(matrix:Matrix3D, planes:Vector.<Plane3D>, normalize:Boolean=true, 
									  flipNormals:Boolean=false) : void {
			var m :Vector.<Number> = matrix.rawData;
			var i :int;
			
			planes[TOP].setCoefficients(
				-m[1] + m[3],
				-m[5] + m[7],
				-m[9] + m[11],
				-m[13] + m[15]
			);
			
			planes[BOTTOM].setCoefficients(
				m[1] + m[3],
				m[5] + m[7],
				m[9] + m[11],
			 	m[13] + m[15]
			);
			
			planes[LEFT].setCoefficients(
				m[0] + m[3],
				m[4] + m[7],
				m[8] + m[11],
				m[12] + m[15]
			);
			
			planes[RIGHT].setCoefficients(
				-m[0] + m[3],
				-m[4] + m[7],
				-m[8] + m[11],
				-m[12] + m[15]
			);
			
			planes[NEAR].setCoefficients(
				m[2] + m[3],
				m[6] + m[7],
				m[10] + m[11],
				m[14] + m[15]
			);
			
			planes[FAR].setCoefficients(
				-m[2] + m[3],
				-m[6] + m[7],
				-m[10] + m[11],
				-m[14] + m[15]
			);
			
			if(normalize) 
			{
				for (i = 0; i < 6; i++)
				{
					planes[i].normalize();
				}
			}
			
			if(flipNormals) 
			{
				for (i = 0; i < 6; i++)
				{
					planes[i].normal.negate();
				}
			}
		}
	}
}