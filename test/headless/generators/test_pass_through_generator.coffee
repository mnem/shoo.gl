module "Copy generator tests"

test "Default values are as expected", () ->
  subject = new shoogl.scene.generators.standard.CopyGenerator()
  equal subject.in.value_f, 0
  equal subject.out.value_f, 0

test "Value is copied", () ->
  subject = new shoogl.scene.generators.standard.CopyGenerator()
  subject.in.value_f = 15
  subject.update()
  equal subject.out.value_f, 15
