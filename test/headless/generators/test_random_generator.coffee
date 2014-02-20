module "Random generator tests"

test "Value is 0 after creation", () ->
  subject = new shoogl.scene.generators.standard.RandomGenerator()
  equal subject.out.result_f, 0.0

test "Value is not 1 after update", () ->
  subject = new shoogl.scene.generators.standard.RandomGenerator()
  equal subject.out.result_f, 0.0
  subject.out.result_f = 1.0
  equal subject.out.result_f, 1.0
  subject.update()
  notEqual subject.out.result_f, 1.0
