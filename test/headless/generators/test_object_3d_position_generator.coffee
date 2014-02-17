module "Object3D position generator tests"

test "Default values are as expected", () ->
  subject = new shoogl.scene.generators.standard.Object3DPositionGenerator()
  expected = new THREE.Vector3(0, 0, 0)
  ok expected.equals(subject.out.result_vec3), "Generator produced (#{subject.out.result_vec3.x}, #{subject.out.result_vec3.y}, #{subject.out.result_vec3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

test "Position of unmoved object", () ->
  subject = new shoogl.scene.generators.standard.Object3DPositionGenerator()
  subject.in.source_object3d = new THREE.Object3D()
  subject.in.source_object3d.translateX(1)
  subject.in.source_object3d.translateY(2)
  subject.in.source_object3d.translateZ(3)
  subject.in.source_object3d.updateMatrixWorld()
  subject.update()
  expected = new THREE.Vector3(1, 2, 3)
  ok expected.equals(subject.out.result_vec3), "Generator produced (#{subject.out.result_vec3.x}, #{subject.out.result_vec3.y}, #{subject.out.result_vec3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

test "Position of moved object", () ->
  subject = new shoogl.scene.generators.standard.Object3DPositionGenerator()
  subject.in.source_object3d = new THREE.Object3D()
  subject.in.source_object3d.translateX(1)
  subject.in.source_object3d.translateY(2)
  subject.in.source_object3d.translateZ(3)
  subject.in.source_object3d.updateMatrixWorld()
  subject.update()
  expected = new THREE.Vector3(1, 2, 3)
  ok expected.equals(subject.out.result_vec3), "Generator produced (#{subject.out.result_vec3.x}, #{subject.out.result_vec3.y}, #{subject.out.result_vec3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

  subject.in.source_object3d.translateX(1)
  subject.in.source_object3d.translateY(2)
  subject.in.source_object3d.translateZ(3)
  subject.in.source_object3d.updateMatrixWorld()
  subject.update()
  expected = new THREE.Vector3(2, 4, 6)
  ok expected.equals(subject.out.result_vec3), "Generator produced (#{subject.out.result_vec3.x}, #{subject.out.result_vec3.y}, #{subject.out.result_vec3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"
