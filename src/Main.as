package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import net.hires.debug.Stats;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.clipping.ClipFlags;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.data.RenderStats;
	import org.papervision3d.core.render.pipeline.BasicPipeline;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
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
		public var viewport :Viewport3D;
		public var scene :DisplayObject3D;
		public var renderData :RenderData;
		public var renderer :BasicRenderEngine;
		public var tf :TextField;
		
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

			tf = new TextField();
			addChild(tf);
			tf.x = 1;
			tf.y = 110;
			tf.width = 300;
			tf.height = 200;
			tf.defaultTextFormat = new TextFormat("Arial", 10, 0xff0000);
			tf.selectable = false;
			tf.multiline = true;
			tf.text = "Papervision3D - version 3.0";
			
			camera = new Camera3D(50, 400, 2300, "Camera01");
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
			
			viewport = new Viewport3D(0, 0, true);
			
			renderer = new BasicRenderEngine();
			renderer.clipFlags = ClipFlags.ALL;
			
			addChild(viewport);
			
			var plane :Plane = new Plane(new WireframeMaterial(0x0000FF), 400, 400, 1, 1, "Plane0");
			scene.addChild(plane);
		//	render();
			camera.y = 500;
			camera.lookAt(cube.getChildByName("red"));
			render();
			//camera.lookAt(cube.getChildByName("red"));
			render();
			render();
			addEventListener(Event.ENTER_FRAME, render);
		}
		
		private var _r :Number = 0;
		private var _s :Number = 0;
		
		private function render(event:Event=null):void
		{
			// rotation in global frame of reference : append
		//	cube.x ++;
			cube.rotationY--;
			
			//cube.getChildByName("blue").x += 0.1;
			//cube.getChildByName("blue").rotationZ--;
		//	cube.getChildByName("blue").lookAt( cube.getChildByName("red") );
			cube.getChildByName("blue").rotationZ += 4;
			
			cube.getChildByName("blue").transform.eulerAngles.y--;
			cube.getChildByName("green").lookAt( cube.getChildByName("red") );
			
			cube.getChildByName("red").transform.eulerAngles.z++;
		//	cube.getChildByName("red").transform.eulerAngles.y--;
			cube.getChildByName("red").transform.dirty = true;
		//	cube.getChildByName("red").rotateAround(_s++, new Vector3D(0, _s, _s));
		//	cube.getChildByName("red").scaleX = 2;
		//	cube.getChildByName("red").rotateAround(_s, new Vector3D(0, -_s, 0));
		//	cube.getChildByName("green").rotateAround(_r++, Vector3D.X_AXIS);
			
			camera.x = Math.sin(_r) * 950;
			camera.y = 500;
			camera.z = Math.cos(_r) * 950;
			_r += Math.PI / 180;
			
			camera.lookAt(cube);
			//camera.lookAt( cube.getChildByName("blue") );
			//trace(cube.getChildByName("red").transform.position);
			
			renderer.renderScene(scene, camera, viewport);	
			
			var stats :RenderStats = renderer.renderData.stats;
			
			tf.text = "Papervision3D - version 3.0\n" +
				"\ntotal objects: " + stats.totalObjects +
				"\nculled objects: " + stats.culledObjects +
				"\n\ntotal triangles: " + stats.totalTriangles +
				"\nculled triangles: " + stats.culledTriangles +
				"\nclipped triangles: " + stats.clippedTriangles;
			
		}
	}
}
