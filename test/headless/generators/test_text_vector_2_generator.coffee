module "Text Vector2 generator tests"

test "Default values are as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector2Generator()
  expected = new THREE.Vector2(0, 0)
  ok expected.equals(subject.out.result_vec2), "Generator produced (#{subject.out.result_vec2.x}, #{subject.out.result_vec2.y}) but expected (#{expected.x}, #{expected.y})"

test "Processes null string as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector2Generator()
  subject.in.value_string = null
  subject.update()

  expected = new THREE.Vector2(0, 0)
  ok expected.equals(subject.out.result_vec2), "Generator produced (#{subject.out.result_vec2.x}, #{subject.out.result_vec2.y}) but expected (#{expected.x}, #{expected.y})"

test "Processes empty string as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector2Generator()
  subject.in.value_string = ""
  subject.update()

  expected = new THREE.Vector2(0, 0)
  ok expected.equals(subject.out.result_vec2), "Generator produced (#{subject.out.result_vec2.x}, #{subject.out.result_vec2.y}) but expected (#{expected.x}, #{expected.y})"

test "Processes short string as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector2Generator()
  subject.in.value_string = "1"
  subject.update()

  expected = new THREE.Vector2(0, 0)
  ok expected.equals(subject.out.result_vec2), "Generator produced (#{subject.out.result_vec2.x}, #{subject.out.result_vec2.y}) but expected (#{expected.x}, #{expected.y})"

test "Processes long string as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector2Generator()
  subject.in.value_string = "1 1 1 1"
  subject.update()

  expected = new THREE.Vector2(0, 0)
  ok expected.equals(subject.out.result_vec2), "Generator produced (#{subject.out.result_vec2.x}, #{subject.out.result_vec2.y}) but expected (#{expected.x}, #{expected.y})"

test "Processes valid string as expected", () ->
  subject = new shoogl.scene.generators.standard.TextVector2Generator()
  subject.in.value_string = "1.23 4.56"
  subject.update()

  expected = new THREE.Vector2(1.23, 4.56)
  ok expected.equals(subject.out.result_vec2), "Generator produced (#{subject.out.result_vec2.x}, #{subject.out.result_vec2.y}) but expected (#{expected.x}, #{expected.y})"
