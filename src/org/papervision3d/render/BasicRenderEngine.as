package org.papervision3d.render
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.clipping.ClipFlags;
	import org.papervision3d.core.render.clipping.IPolygonClipper;
	import org.papervision3d.core.render.clipping.SutherlandHodgmanClipper;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.core.render.draw.list.DrawableList;
	import org.papervision3d.core.render.draw.list.IDrawableList;
	import org.papervision3d.core.render.engine.AbstractRenderEngine;
	import org.papervision3d.core.render.pipeline.BasicPipeline;
	import org.papervision3d.core.render.raster.DefaultRasterizer;
	import org.papervision3d.core.render.raster.IRasterizer;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;

	public class BasicRenderEngine extends AbstractRenderEngine
	{
		use namespace pv3d;
		
		public var renderList :IDrawableList;
		public var clipper :IPolygonClipper;
		public var viewport :Viewport3D;
		public var rasterizer : IRasterizer;
		
		public function BasicRenderEngine()
		{
			super();
			init();
		}
		
		protected function init():void
		{
			pipeline = new BasicPipeline();
			renderList = new DrawableList();
			clipper = new SutherlandHodgmanClipper();
			rasterizer = new DefaultRasterizer();
		}
		
		override public function renderScene(renderData:RenderData):void
		{
			var scene :DisplayObject3D = renderData.scene;
			var camera :Camera3D = renderData.camera;
			renderList = renderData.drawlist;
			this.viewport = renderData.viewport;
			
			camera.rotationX = camera.rotationX;
			camera.update(renderData.viewport.sizeRectangle);
						
			pipeline.execute(renderData);
 
 			renderList.clear();
			test(camera, scene);
			rasterizer.rasterize(renderList, renderData.viewport);
		}
		
		/**
		 * Get rid of triangles behind the near plane, clip straddling triangles if needed.
		 * 
		 * @param	camera
		 * @param	object
		 */ 
		private function test(camera:Camera3D, object:DisplayObject3D):void 
		{
			var child :DisplayObject3D;
			var v0 :Vector3D = new Vector3D();
			var v1 :Vector3D = new Vector3D();
			var v2 :Vector3D = new Vector3D();
			
			if (object.geometry is TriangleGeometry)
			{
				var geom :TriangleGeometry = object.geometry as TriangleGeometry;
				var triangle :Triangle;
				var inside :Boolean;
				var flags :int = 0;
				
				for each (triangle in geom.triangles)
				{
					//trace("got a triangle");
					triangle.clipFlags = 0;
					triangle.visible = false;
					
					// get vertices in view / camera space
					v0.x = geom.viewVertexData[ triangle.v0.vectorIndexX ];	
					v0.y = geom.viewVertexData[ triangle.v0.vectorIndexY ];
					v0.z = geom.viewVertexData[ triangle.v0.vectorIndexZ ];
					v1.x = geom.viewVertexData[ triangle.v1.vectorIndexX ];	
					v1.y = geom.viewVertexData[ triangle.v1.vectorIndexY ];
					v1.z = geom.viewVertexData[ triangle.v1.vectorIndexZ ];
					v2.x = geom.viewVertexData[ triangle.v2.vectorIndexX ];	
					v2.y = geom.viewVertexData[ triangle.v2.vectorIndexY ];
					v2.z = geom.viewVertexData[ triangle.v2.vectorIndexZ ];
					
					flags = 0;
					if (v0.z >= -camera.near) flags |= 1;
					if (v1.z >= -camera.near) flags |= 2;
					if (v2.z >= -camera.near) flags |= 4;

					if (flags == 7 )
					{
						// behind near plane
						continue;
					}
					else if (flags)
					{
						// clip candidate
						triangle.clipFlags |= ClipFlags.NEAR;
					}
					
					flags = 0;
					if (v0.z <= -camera.far) flags |= 1;
					if (v1.z <= -camera.far) flags |= 2;
					if (v2.z <= -camera.far) flags |= 4;
					
					if (flags == 7 )
					{
						// behind far plane
						continue;
					}
					else if (flags)
					{
						// clip candidate
						triangle.clipFlags |= ClipFlags.FAR;
					}
					
					triangle.visible = (triangle.clipFlags == 0);
					
					if (triangle.visible)
					{	
						// select screen vertex data
						v0.x = geom.screenVertexData[ triangle.v0.screenIndexX ];	
						v0.y = geom.screenVertexData[ triangle.v0.screenIndexY ];
						v1.x = geom.screenVertexData[ triangle.v1.screenIndexX ];	
						v1.y = geom.screenVertexData[ triangle.v1.screenIndexY ];
						v2.x = geom.screenVertexData[ triangle.v2.screenIndexX ];	
						v2.y = geom.screenVertexData[ triangle.v2.screenIndexY ];
						
						var left :int = 0;
						var right :int = 0;
						var top :int = 0;
						var bottom :int = 0;
						
						if (v0.x < -1) left++;
						if (v1.x < -1) left++;
						if (v2.x < -1) left++;
						if (v0.x > 1) right++;
						if (v1.x > 1) right++;
						if (v2.x > 1) right++;
						if (v0.y > 1) top++;
						if (v1.y > 1) top++;
						if (v2.y > 1) top++;
						if (v0.y < -1) bottom++;
						if (v1.y < -1) bottom++;
						if (v2.y < -1) bottom++;
						
						if (left == 0 && right == 0 && top == 0 && bottom == 0)
						{
							var drawable :TriangleDrawable = triangle.drawable as TriangleDrawable || new TriangleDrawable();
							drawable.screenZ = (v0.z + v1.z + v2.z) / 3;
							drawable.x0 = v0.x;
							drawable.y0 = v0.y;
							drawable.x1 = v1.x;
							drawable.y1 = v1.y;
							drawable.x2 = v2.x;
							drawable.y2 = v2.y;
							drawable.material = object.material;

							renderList.addDrawable(drawable);
						}
						else if (left == 3 || right == 3 || top == 3 || bottom == 3)
						{
							triangle.visible = false;
						}
						else
						{
							if (left > 0) flags |= ClipFlags.LEFT;
							if (right > 0) flags |= ClipFlags.RIGHT;
							if (top > 0) flags |= ClipFlags.TOP;
							if (bottom > 0) flags |= ClipFlags.BOTTOM;
							
							//f( right > 0)
							clipTriangle(camera, triangle, v0, v1, v2, flags, object.material);
						}
					}
				}
			}
			
			for each (child in object._children)
			{
				test(camera, child);
			}
		}
		
		private function clipTriangle(camera:Camera3D, triangle:Triangle, v0:Vector3D, v1:Vector3D, v2:Vector3D, clipFlags:int, material:AbstractMaterial):void
		{
			var inV :Vector.<Number> = Vector.<Number>([v0.x, v0.y, 0, v1.x, v1.y, 0, v2.x, v2.y, 0]);
			var inUVT :Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 0, 0, 0, 0, 0]);
			var outV :Vector.<Number> = new Vector.<Number>();
			var outUVT :Vector.<Number> = new Vector.<Number>();
			var svd :Vector.<Number> = new Vector.<Number>();
			
			var plane :Plane3D = Plane3D.fromCoefficients(1, 0, 0, -1);
		
			if (clipFlags & ClipFlags.LEFT)
			{
				plane.setCoefficients(-1, 0, 0, 1);
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}

			if (clipFlags & ClipFlags.RIGHT)
			{
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				plane.setCoefficients(1, 0, 0, 1);
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}

			if (clipFlags & ClipFlags.TOP)
			{
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				plane.setCoefficients(0, -1, 0, 1);
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (clipFlags & ClipFlags.BOTTOM)
			{
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				plane.setCoefficients(0, 1, 0, 1);
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			svd = inV;
			
			var numTriangles : int = 1 + ((inV.length / 3)-3);
			var i :int, i2 :int, i3 :int;
			
			for(i = 0; i < numTriangles; i++)
			{
				i2 = i * 2;
				i3 = i * 3; 
				
				var drawable :TriangleDrawable = new TriangleDrawable();
							
				drawable.x0 = svd[0];
				drawable.y0 = svd[1];
				
				drawable.x1 = svd[i3+3];
				drawable.y1 = svd[i3+4];
				
				drawable.x2 = svd[i3+6];
				drawable.y2 = svd[i3+7];
				drawable.material = material; 
				drawable.screenZ = (v0.z + v1.z + v2.z) / 3;
				
				renderList.addDrawable(drawable);
			}
		}
	}
}