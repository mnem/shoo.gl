module "Text Vector3 generator tests"

test "Default values are as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector3Generator()
  expected = new THREE.Vector3(0, 0, 0)
  ok expected.equals(subject.out.result_v3), "Generator produced (#{subject.out.result_v3.x}, #{subject.out.result_v3.y}, #{subject.out.result_v3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

test "Processes null string as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector3Generator()
  subject.in.value_string = null
  subject.update()

  expected = new THREE.Vector3(0, 0, 0)
  ok expected.equals(subject.out.result_v3), "Generator produced (#{subject.out.result_v3.x}, #{subject.out.result_v3.y}, #{subject.out.result_v3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

test "Processes empty string as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector3Generator()
  subject.in.value_string = ""
  subject.update()

  expected = new THREE.Vector3(0, 0, 0)
  ok expected.equals(subject.out.result_v3), "Generator produced (#{subject.out.result_v3.x}, #{subject.out.result_v3.y}, #{subject.out.result_v3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

test "Processes short string as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector3Generator()
  subject.in.value_string = "1 1"
  subject.update()

  expected = new THREE.Vector3(0, 0, 0)
  ok expected.equals(subject.out.result_v3), "Generator produced (#{subject.out.result_v3.x}, #{subject.out.result_v3.y}, #{subject.out.result_v3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

test "Processes long string as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector3Generator()
  subject.in.value_string = "1 1 1 1"
  subject.update()

  expected = new THREE.Vector3(0, 0, 0)
  ok expected.equals(subject.out.result_v3), "Generator produced (#{subject.out.result_v3.x}, #{subject.out.result_v3.y}, #{subject.out.result_v3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"

test "Processes valid string as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector3Generator()
  subject.in.value_string = "1.23 4.56 7.89"
  subject.update()

  expected = new THREE.Vector3(1.23, 4.56, 7.89)
  ok expected.equals(subject.out.result_v3), "Generator produced (#{subject.out.result_v3.x}, #{subject.out.result_v3.y}, #{subject.out.result_v3.z}) but expected (#{expected.x}, #{expected.y}, #{expected.z})"
