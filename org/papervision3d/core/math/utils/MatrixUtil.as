package org.papervision3d.core.math.utils
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class MatrixUtil
	{
		private static var _f :Vector3D = new Vector3D();
		private static var _s :Vector3D = new Vector3D();
		private static var _u :Vector3D = new Vector3D();
		
		/**
		 * 
		 */ 
		public static function createLookAtMatrix(eye:Vector3D, target:Vector3D, up:Vector3D, resultMatrix:Matrix3D=null):Matrix3D
		{
			resultMatrix = resultMatrix || new Matrix3D();
			
			_f.x = target.x - eye.x;
			_f.y = target.y - eye.y;
			_f.z = target.z - eye.z;
			_f.normalize();
			
			_s.x = (up.y * _f.z) - (up.z * _f.y);
			_s.y = (up.z * _f.x) - (up.x * _f.z);
			_s.z = (up.x * _f.y) - (up.y * _f.x);
			_s.normalize();
			
			_u.x = (_s.y * _f.z) - (_s.z * _f.y);
			_u.y = (_s.z * _f.x) - (_s.x * _f.z);
			_u.z = (_s.x * _f.y) - (_s.y * _f.x);
			_u.normalize();
			
			resultMatrix.rawData = Vector.<Number>([
				_s.x, _s.y, _s.z, 0,
				_u.x, _u.y, _u.z, 0,
				-_f.x, -_f.y, -_f.z, 0,
				0, 0, 0, 1
			]);
			
			return resultMatrix;
		}
		
		/**
		 * Creates a projection matrix.
		 * 
		 * @param fovY
		 * @param aspectRatio
		 * @param near
		 * @param far
		 */
		public static function createProjectionMatrix(fovy:Number, aspect:Number, zNear:Number, zFar:Number):Matrix3D 
		{
			var sine :Number, cotangent :Number, deltaZ :Number;
    		var radians :Number = (fovy / 2) * (Math.PI / 180);
			
		    deltaZ = zFar - zNear;
		    sine = Math.sin(radians);
		    if ((deltaZ == 0) || (sine == 0) || (aspect == 0)) 
		    {
				return null;
		    }
		    cotangent = Math.cos(radians) / sine;
		    
			var v:Vector.<Number> = Vector.<Number>([
				cotangent / aspect, 0, 0, 0,
				0, cotangent, 0, 0,
				0, 0, -(zFar + zNear) / deltaZ, -1,
				0, 0, -(2 * zFar * zNear) / deltaZ, 0
			]);
			return new Matrix3D(v);
		}
		
		/**
		 * 
		 */ 
		public static function createOrthoMatrix(left:Number, right:Number, top:Number, bottom:Number, zNear:Number, zFar:Number) : Matrix3D {
			var tx :Number = (right + left) / (right - left);
			var ty :Number = (top + bottom) / (top - bottom);
			var tz :Number = (zFar+zNear) / (zFar-zNear);
			var v:Vector.<Number> = Vector.<Number>([
				2 / (right - left), 0, 0, 0,
				0, 2 / (top - bottom), 0, 0,
				0, 0, -2 / (zFar-zNear), 0,
				tx, ty, tz, 1
			]);
			return new Matrix3D(v);
		}

	}
}