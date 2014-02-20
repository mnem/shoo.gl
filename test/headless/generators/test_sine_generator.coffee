module "Sine generator tests"

test "Default values are as expected", () ->
  subject = new shoogl.scene.generators.standard.SineGenerator()
  equal subject.in.value_f, 0.0
  equal subject.in.hertz_f, 1.0
  equal subject.out.result_f, 0.0

test "Sine π/2 is 1", () ->
  subject = new shoogl.scene.generators.standard.SineGenerator()
  subject.in.value_f = Math.PI / 2
  subject.update()
  equal subject.out.result_f, 1.0
  subject.update()
  equal subject.out.result_f, 1.0, "Second update is wrong"

test "Sine π/2 + π is -1", () ->
  subject = new shoogl.scene.generators.standard.SineGenerator()
  subject.in.value_f = (Math.PI / 2) + Math.PI
  subject.update()
  equal subject.out.result_f, -1.0
