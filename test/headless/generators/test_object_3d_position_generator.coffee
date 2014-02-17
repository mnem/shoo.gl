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

# test "Processes null string as expected", () ->
#   subject = new shoogl.scene.generators.standard.TextVector3Generator()
#   subject.in.value_string = null
#   subject.update()

#   expected = new THREE.Vector3(0, 0, 0)
#   ok expected.equals(subject.out.result_vec3), "Generator produced (#{subject.out.result_vec3.x}, #{subject.out.result_vec3.y}, #{subject.out.result_vec3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

# test "Processes empty string as expected", () ->
#   subject = new shoogl.scene.generators.standard.TextVector3Generator()
#   subject.in.value_string = ""
#   subject.update()

#   expected = new THREE.Vector3(0, 0, 0)
#   ok expected.equals(subject.out.result_vec3), "Generator produced (#{subject.out.result_vec3.x}, #{subject.out.result_vec3.y}, #{subject.out.result_vec3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

# test "Processes short string as expected", () ->
#   subject = new shoogl.scene.generators.standard.TextVector3Generator()
#   subject.in.value_string = "1 1"
#   subject.update()

#   expected = new THREE.Vector3(0, 0, 0)
#   ok expected.equals(subject.out.result_vec3), "Generator produced (#{subject.out.result_vec3.x}, #{subject.out.result_vec3.y}, #{subject.out.result_vec3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

# test "Processes long string as expected", () ->
#   subject = new shoogl.scene.generators.standard.TextVector3Generator()
#   subject.in.value_string = "1 1 1 1"
#   subject.update()

#   expected = new THREE.Vector3(0, 0, 0)
#   ok expected.equals(subject.out.result_vec3), "Generator produced (#{subject.out.result_vec3.x}, #{subject.out.result_vec3.y}, #{subject.out.result_vec3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

# test "Processes valid string as expected", () ->
#   subject = new shoogl.scene.generators.standard.TextVector3Generator()
#   subject.in.value_string = "1.23 4.56 7.89"
#   subject.update()

#   expected = new THREE.Vector3(1.23, 4.56, 7.89)
#   ok expected.equals(subject.out.result_vec3), "Generator produced (#{subject.out.result_vec3.x}, #{subject.out.result_vec3.y}, #{subject.out.result_vec3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"
