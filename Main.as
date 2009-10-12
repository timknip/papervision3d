package {
	import __AS3__.vec.Vector;
	
	import flash.display.Graphics;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import net.hires.debug.Stats;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.clipping.SutherlandHodgmanClipper;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.core.render.draw.list.DrawableList;
	import org.papervision3d.core.render.pipeline.BasicPipeline;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;

	[SWF (backgroundColor="#000000")]
	
	public class Main extends Sprite
	{
		use namespace pv3d;
		
		public var container :Sprite;
		public var vertexGeometry :VertexGeometry;
		public var cube :Cube;
		public var camera :Camera3D;
		public var pipeline :BasicPipeline;
		public var viewport :Rectangle;
		public var scene :DisplayObject3D;
		public var renderData :RenderData;
		public var renderer :BasicRenderEngine;
	
		
		public function Main()
		{
			init();
		}
		
		private function init():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW;
			
			var aspect :Number = stage.stageWidth / stage.stageHeight;
		
			container = new Sprite();
			addChild(container);
			container.x = stage.stageWidth / 2;
			container.y = stage.stageHeight / 2;

			addChild(new Stats());

			camera = new Camera3D(20, 400, 2300, aspect, "Camera01");
			pipeline = new BasicPipeline();
			
			cube = new Cube(new WireframeMaterial(), 100, "Cube");
			
			var cubeChild0 :Cube = new Cube(new WireframeMaterial(0xFF0000), 100, "red");
			cube.addChild( cubeChild0 );
			cubeChild0.x = 300;
			//cubeChild0.z = -500;
			
			var cubeChild1 :Cube = new Cube(new WireframeMaterial(0x00FF00), 100, "blue");
			cube.addChild( cubeChild1 );
			cubeChild1.z = 200;

			
			var cubeChild2 :Cube = new Cube(new WireframeMaterial(0x0000FF), 100, "green");
			cube.addChild( cubeChild2 );
			cubeChild2.y = 200;
			cubeChild2.z = 10;
			
			scene = new DisplayObject3D("Scene");
			scene.addChild( camera );
			scene.addChild( cube );
				
			camera.z = 800;
			
			renderData = new RenderData();
			renderData.camera = camera;
			renderData.scene = scene;
			renderData.drawlist = new DrawableList();
			
			renderData.viewport = new Viewport3D(0, 0, true);
			
			renderer = new BasicRenderEngine();
			
			addChild(renderData.viewport);
			
		//	render();
			
			var clipper:SutherlandHodgmanClipper;
			
			addEventListener(Event.ENTER_FRAME, render);
		}
		
		private var _r :Number = 0;
		private var _s :Number = 0;
		
		private function render(event:Event=null):void
		{
			// rotation in global frame of reference : append
		//	cube.x ++;
		//	cube.rotationY--;
			
			//cube.getChildByName("blue").x += 0.1;
			//cube.getChildByName("blue").rotationZ--;
			//cube.getChildByName("blue").lookAt( cube.getChildByName("red") );
			
			cube.getChildByName("green").lookAt( cube.getChildByName("red") );
			
			cube.getChildByName("red").rotateAround(_s++, new Vector3D(0, 0, _s));
		//	cube.getChildByName("red").scaleX = 2;
			cube.getChildByName("red").rotationX += 3;
		//	cube.getChildByName("green").rotateAround(_r++, Vector3D.X_AXIS);
			
			camera.x = Math.sin(_r) * 950;
			camera.y = 500;
			camera.z = Math.cos(_r) * 950;
			_r += Math.PI / 180;
			
			camera.lookAt(cube);
			//camera.lookAt( cube.getChildByName("blue") );
			//trace(cube.getChildByName("red").transform.position);
			
			renderer.renderScene(renderData);	
			
			
			
			//renderScene(renderData.viewport.containerSprite.graphics, scene);
			//trace((drawArray[1] as GraphicsTrianglePath).vertices);
			
		}
		
	
	}
}
