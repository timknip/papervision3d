package org.papervision3d.objects
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.math.Plane3D;
	
	public class Frustum3D extends DisplayObject3D
	{
		public var worldPlanes :Vector.<Plane3D>;
		
		private var _xAxis :Vector3D;
		private var _yAxis :Vector3D;
		private var _zAxis :Vector3D;
		
		private var _MP :Matrix3D;
		
		/**
		 * 
		 */ 
		public function Frustum3D(name:String=null)
		{
			super(name);
			
			this.worldPlanes = new Vector.<Plane3D>(6, true);
			for (var i:int = 0; i < 6; i++)
			{
				this.worldPlanes[i] = Plane3D.fromCoefficients(0, 0, 1, 0);
			}
			
			_xAxis = new Vector3D();
			_yAxis = new Vector3D();
			_zAxis = new Vector3D();
			
			_MP = new Matrix3D();
		}
		
		/**
		 * 
		 */ 
		public function update(camera:Camera3D):void
		{
			//this.transform.worldTransform.rawData = camera.transform.viewTransform.rawData;
			//this.transform.worldTransform.invert();
			
			var v :Vector.<Number> = camera.transform.viewTransform.rawData;
			
			_xAxis.x = v[0];
			_xAxis.y = v[1];
			_xAxis.z = v[2];
			_yAxis.x = v[4];
			_yAxis.y = v[5];
			_yAxis.z = v[6];
			_zAxis.x = v[8];
			_zAxis.y = v[9];
			_zAxis.z = v[10];
			
			_xAxis.normalize();
			_yAxis.normalize();
			_zAxis.normalize();
			
			var zNeg :Vector3D = _zAxis.clone();
			zNeg.negate();
		
			_MP.rawData = camera.transform.worldTransform.rawData;
			
		//	_MP.prepend(camera.projectionMatrix);
			//_MP.invert();
			
			//this.worldPlanes[0].normalize();
			
			Plane3D(this.worldPlanes[0]).setNormalAndPoint(_zAxis, new Vector3D());
			
			//trace(this.worldPlanes[0]);
			//extractPlanes(_MP, this.worldPlanes);
		}
		
		/**
		 * Extract planes.
		 * 
		 * @param	matrix
		 * @param	planes
		 */ 
		public function extractPlanes(matrix:Matrix3D, planes:Vector.<Plane3D> ):void
		{	
			var m :Vector.<Number> = matrix.rawData;
			 
			planes[0].setCoefficients(
				m[2] + m[3],
				m[6] + m[7],
				m[10] + m[11],
				m[14] + m[15]
			);
			
			planes[1].setCoefficients(
				-m[2] + m[3],
				-m[6] + m[7],
				-m[10] + m[11],
				-m[14] + m[15]
			);
			
			planes[2].setCoefficients(
				m[0] + m[3],
				m[4] + m[7],
				m[8] + m[11],
				m[12] + m[15]
			);
			
			planes[3].setCoefficients(
				-m[0] + m[3],
				-m[4] + m[7],
				-m[8] + m[11],
				-m[12] + m[15]
			);	
			
			planes[4].setCoefficients(
				-m[1] + m[3],
				-m[5] + m[7],
				-m[9] + m[11],
				-m[13] + m[15]
			);
			
			planes[5].setCoefficients(
				m[1] + m[3],
				m[5] + m[7],
				m[9] + m[11],
			 	m[13] + m[15]
			);
		}
	}
}