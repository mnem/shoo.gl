module "Cosine generator tests"

test "Default values are as expected", () ->
  subject = new shoogl.scene.generators.standard.CosineGenerator()
  equal subject.in.value_f, 0.0
  equal subject.in.hertz_f, 1.0
  equal subject.out.result_f, 0.0

test "Cosine 0 is 1", () ->
  subject = new shoogl.scene.generators.standard.CosineGenerator()
  subject.in.value_f = 0
  subject.update()
  equal subject.out.result_f, 1.0
  subject.update()
  equal subject.out.result_f, 1.0, "Second update is wrong"

test "Cosine π is -1", () ->
  subject = new shoogl.scene.generators.standard.CosineGenerator()
  subject.in.value_f = Math.PI
  subject.update()
  equal subject.out.result_f, -1.0
  subject.update()
  equal subject.out.result_f, -1.0, "Second update is wrong"

test "Cosine π/2 is 0", () ->
  subject = new shoogl.scene.generators.standard.CosineGenerator()
  subject.in.value_f = Math.PI / 2
  subject.update()
  ok subject.out.result_f < 0.0000000000000001 and subject.out.result_f > -0.0000000000000001
