package org.papervision3d.cameras
{
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	
	import org.papervision3d.core.math.utils.MatrixUtil;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.Frustum3D;

	/**
	 * 
	 */ 
	public class Camera3D extends DisplayObject3D
	{
		use namespace pv3d;
		
		public var projectionMatrix :Matrix3D;
		public var viewMatrix :Matrix3D;
		
		private var _dirty:Boolean;
		private var _aspectRatio:Number;
		private var _fov:Number;
		private var _far:Number;
		private var _near:Number;
		private var _ortho:Boolean;
		private var _orthoScale:Number;
		pv3d var _frustum :Frustum3D;
		
		/**
		 * Constructor.
		 * 
		 * @param 	fov
		 * @param 	near
		 * @param 	far
		 * @param 	aspectRatio
		 * @param	name
		 */
		public function Camera3D(fov:Number=60, near:Number=1, far:Number=10000, aspectRatio:Number=1.375, name:String=null)
		{
			super(name);
			
			_fov = fov;
			_near = near;
			_far = far;
			_aspectRatio = aspectRatio;
			_dirty = true;
			_ortho = false;
			_orthoScale = 1;
			_frustum = new Frustum3D("Frustum3D_For_" + name);
			
			addChild(_frustum);
			
			viewMatrix = new Matrix3D();
		}
		
		/**
		 * 
		 */
		public function update(viewport:Rectangle) : void 
		{
			viewMatrix.rawData = transform.worldTransform.rawData;
			viewMatrix.invert();
			
			if(_dirty) 
			{
				_dirty = false;
				
				if(_ortho) 
				{
					projectionMatrix = MatrixUtil.createOrthoMatrix(viewport.width, -viewport.width, -viewport.height, viewport.height, -_far, _far);
				} 
				else 
				{
					_aspectRatio = viewport.width / viewport.height;
					projectionMatrix = MatrixUtil.createProjectionMatrix(_fov, _aspectRatio, _near, _far);
				}
			}
			
			//_frustum.update(this);
		}
		
		/**
		 * 
		 */
		public function get aspectRatio():Number
		{
			return _aspectRatio;
		}
		
		/**
		 * 
		 */
		public function get far():Number
		{
			return _far;
		}
		
		/**
		 * 
		 */
		public function get fov():Number
		{
			return _fov;
		}
		
		/**
		 * 
		 */
		public function get near():Number
		{
			return _near;
		} 
	}
}