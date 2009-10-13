package org.papervision3d.render
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.math.Frustum3D;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.clipping.ClipFlags;
	import org.papervision3d.core.render.clipping.IPolygonClipper;
	import org.papervision3d.core.render.clipping.SutherlandHodgmanClipper;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.data.RenderStats;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.core.render.draw.list.DrawableList;
	import org.papervision3d.core.render.draw.list.IDrawableList;
	import org.papervision3d.core.render.engine.AbstractRenderEngine;
	import org.papervision3d.core.render.object.ObjectRenderer;
	import org.papervision3d.core.render.pipeline.BasicPipeline;
	import org.papervision3d.core.render.raster.DefaultRasterizer;
	import org.papervision3d.core.render.raster.IRasterizer;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;

	/**
	 * 
	 */ 
	public class BasicRenderEngine extends AbstractRenderEngine
	{
		use namespace pv3d;
		
		public var renderList :IDrawableList;
		public var clipper :IPolygonClipper;
		public var viewport :Viewport3D;
		public var rasterizer : IRasterizer;
		public var geometry :TriangleGeometry;
		public var renderData :RenderData;
		public var stats :RenderStats;
		
		private var _clipFlags :uint;
		
		private var _v0 :Vector3D;
		private var _v1 :Vector3D;
		private var _v2 :Vector3D;
		private var _sv0 :Vector3D;
		private var _sv1 :Vector3D;
		private var _sv2 :Vector3D;
		
		/**
		 * 
		 */ 	
		public function BasicRenderEngine()
		{
			super();
			init();
		}
		
		/**
		 * 
		 */ 
		protected function init():void
		{
			pipeline = new BasicPipeline();
			renderList = new DrawableList();
			clipper = new SutherlandHodgmanClipper();
			rasterizer = new DefaultRasterizer();
			renderData = new RenderData();
			stats = new RenderStats();
			
			_clipFlags = ClipFlags.NEAR;
			
			_v0 = new Vector3D();
			_v1 = new Vector3D();
			_v2 = new Vector3D();
			_sv0 = new Vector3D();
			_sv1 = new Vector3D();
			_sv2 = new Vector3D();
		}
		
		/**
		 * 
		 */ 
		override public function renderScene(scene:DisplayObject3D, camera:Camera3D, viewport:Viewport3D):void
		{	
			renderData.scene = scene;
			renderData.camera = camera;
			renderData.viewport = viewport;
			renderData.stats = stats;
			
			camera.update(renderData.viewport.sizeRectangle);
						
			pipeline.execute(renderData);
 
 			renderList.clear();
 			stats.clear();
 			
			fillRenderList(camera, scene);
			
			rasterizer.rasterize(renderList, renderData.viewport);
		}
		
		/**
		 * Fills our renderlist.
		 * <p>Get rid of triangles behind the near plane, clip straddling triangles if needed.</p>
		 * 
		 * @param	camera
		 * @param	object
		 */ 
		private function fillRenderList(camera:Camera3D, object:DisplayObject3D):void 
		{
			var child :DisplayObject3D;
			var clipPlanes :Vector.<Plane3D> = camera.frustum.viewClippingPlanes;
			var v0 :Vector3D = new Vector3D();
			var v1 :Vector3D = new Vector3D();
			var v2 :Vector3D = new Vector3D();
			var _sv0 :Vector3D = new Vector3D();
			var _sv1 :Vector3D = new Vector3D();
			var _sv2 :Vector3D = new Vector3D();
			
			stats.totalObjects++;
			
			if (object.cullingState == 0 && object.renderer.geometry is TriangleGeometry)
			{
				var triangle :Triangle;
				var inside :Boolean;
				var flags :int = 0;
				
				geometry = object.renderer.geometry as TriangleGeometry;
				var renderer : ObjectRenderer = object.renderer;
				
				for each (triangle in geometry.triangles)
				{
					triangle.clipFlags = 0;
					triangle.visible = false;
					
					stats.totalTriangles++;
					
					// get vertices in view / camera space
					v0.x = renderer.viewVertexData[ triangle.v0.vectorIndexX ];	
					v0.y = renderer.viewVertexData[ triangle.v0.vectorIndexY ];
					v0.z = renderer.viewVertexData[ triangle.v0.vectorIndexZ ];
					v1.x = renderer.viewVertexData[ triangle.v1.vectorIndexX ];	
					v1.y = renderer.viewVertexData[ triangle.v1.vectorIndexY ];
					v1.z = renderer.viewVertexData[ triangle.v1.vectorIndexZ ];
					v2.x = renderer.viewVertexData[ triangle.v2.vectorIndexX ];	
					v2.y = renderer.viewVertexData[ triangle.v2.vectorIndexY ];
					v2.z = renderer.viewVertexData[ triangle.v2.vectorIndexZ ];
					
					// setup clipflags
					// first test the near plane as verts behind near project to infinity.
					if (_clipFlags & ClipFlags.NEAR)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.NEAR], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.NEAR; }
					}
					
					// passed the near test loosely, verts may have projected to infinity
					// we do it here, cause - paranoia - even these array accesses may cost us
					_sv0.x = renderer.screenVertexData[ triangle.v0.screenIndexX ];	
					_sv0.y = renderer.screenVertexData[ triangle.v0.screenIndexY ];
					_sv1.x = renderer.screenVertexData[ triangle.v1.screenIndexX ];	
					_sv1.y = renderer.screenVertexData[ triangle.v1.screenIndexY ];
					_sv2.x = renderer.screenVertexData[ triangle.v2.screenIndexX ];	
					_sv2.y = renderer.screenVertexData[ triangle.v2.screenIndexY ];
					
					// when *not* straddling the near plane we can safely test for backfaces
					// ie: lets not clip backfacing triangles!
					if (triangle.clipFlags != ClipFlags.NEAR)
					{
						// Simple backface culling.
						if ((_sv2.x - _sv0.x) * (_sv1.y - _sv0.y) - (_sv2.y - _sv0.y) * (_sv1.x - _sv0.x) > 0)
						{
							stats.culledTriangles ++;
							continue;
						}
					}
					
					// okay, continue setting up clipflags
					if (_clipFlags & ClipFlags.FAR)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.FAR], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.FAR; }
					}
					
					if (_clipFlags & ClipFlags.LEFT)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.LEFT], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.LEFT; }
					}
					
					if (_clipFlags & ClipFlags.RIGHT)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.RIGHT], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.RIGHT; }
					}
					
					if (_clipFlags & ClipFlags.TOP)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.TOP], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.TOP; }
					}
					
					if (_clipFlags & ClipFlags.BOTTOM)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.BOTTOM], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.BOTTOM };
					}
						
					if (triangle.clipFlags == 0)
					{
						// triangle completely in view
						var drawable :TriangleDrawable = triangle.drawable as TriangleDrawable || new TriangleDrawable();
						drawable.screenZ = (v0.z + v1.z + v2.z) / 3;
						drawable.x0 = _sv0.x;
						drawable.y0 = _sv0.y;
						drawable.x1 = _sv1.x;
						drawable.y1 = _sv1.y;
						drawable.x2 = _sv2.x;
						drawable.y2 = _sv2.y;
						drawable.material = triangle.material;
						
						renderList.addDrawable(drawable);
						
						triangle.drawable = drawable;
					}
					else
					{
						clipViewTriangle(camera, triangle, v0, v1, v2);
					}	
				}
			}
			
			for each (child in object._children)
			{
				fillRenderList(camera, child);
			}
		}
		
		/**
		 * Clips a triangle in view / camera space. Typically used for the near and far planes.
		 * 
		 * @param	camera
		 * @param	triangle
		 * @param	v0
		 * @param	v1
		 * @param 	v2
		 */ 
		private function clipViewTriangle(camera:Camera3D, triangle:Triangle, v0:Vector3D, v1:Vector3D, v2:Vector3D):void
		{		
			var plane :Plane3D = camera.frustum.viewClippingPlanes[ Frustum3D.NEAR ];
			var inV :Vector.<Number> = Vector.<Number>([v0.x, v0.y, v0.z, v1.x, v1.y, v1.z, v2.x, v2.y, v2.z]);
			var inUVT :Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 0, 0, 0, 0, 0]);
			var outV :Vector.<Number> = new Vector.<Number>();
			var outUVT :Vector.<Number> = new Vector.<Number>();
			
			stats.clippedTriangles++;
			
			if (triangle.clipFlags & ClipFlags.NEAR)
			{
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.FAR)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.FAR ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.LEFT)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.LEFT ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.RIGHT)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.RIGHT ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.TOP)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.TOP ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.BOTTOM)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.BOTTOM ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			Utils3D.projectVectors(camera.projectionMatrix, inV, outV, inUVT);
			
			var numTriangles : int = 1 + ((inV.length / 3)-3);
			var i:int, i2 :int, i3 :int;

			stats.totalTriangles += numTriangles - 1;
			
			for(i = 0; i < numTriangles; i++)
			{
				i2 = i * 2;
				i3 = i * 3; 
				
				v0.x = outV[0];
				v0.y = outV[1];
				v1.x = outV[i2+2];
				v1.y = outV[i2+3];
				v2.x = outV[i2+4];
				v2.y = outV[i2+5];
				
				if ((v2.x - v0.x) * (v1.y - v0.y) - (v2.y - v0.y) * (v1.x - v0.x) > 0)
				{
					stats.culledTriangles ++;
					continue;
				}
				
				var drawable :TriangleDrawable = new TriangleDrawable();
							
				drawable.x0 = v0.x;
				drawable.y0 = v0.y;
				
				drawable.x1 = v1.x;
				drawable.y1 = v1.y;
				
				drawable.x2 = v2.x;
				drawable.y2 = v2.y;	
				drawable.screenZ = (inV[2]+inV[i3+5]+inV[i3+8])/3;
				drawable.material = triangle.material;
				
				renderList.addDrawable(drawable);
			}
		}
		
		/**
		 * 
		 */ 
		private function getClipFlags(plane:Plane3D, v0:Vector3D, v1:Vector3D, v2:Vector3D):int
		{
			var flags :int = 0;
			if ( plane.distance(v0) < 0 ) flags |= 1;
			if ( plane.distance(v1) < 0 ) flags |= 2;
			if ( plane.distance(v2) < 0 ) flags |= 4;
			return flags;
		}
		
		/**
		 * Clip flags.
		 * 
		 * @see org.papervision3d.core.render.clipping.ClipFlags
		 */
		public function get clipFlags():int
		{
			return _clipFlags;
		}
		
		public function set clipFlags(value:int):void
		{
			if (value >= 0 && value <= ClipFlags.ALL)
			{
				_clipFlags = value;
			}
			else
			{
				throw new IllegalOperationError("clipFlags should be a value between 0 and " + ClipFlags.ALL + "\nsee org.papervision3d.core.render.clipping.ClipFlags");
			}
		}
	}
}