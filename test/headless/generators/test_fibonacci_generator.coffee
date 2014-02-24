module "Fibonacci generator tests"

test "Default values are as expected", () ->
  subject = new shoogl.scene.generators.standard.FibonacciGenerator()
  equal subject.in.index_i, 0
  equal subject.in.maximum_index_i, 46
  equal subject.out.value_i, 0

test "First few values are correct", () ->
  subject = new shoogl.scene.generators.standard.FibonacciGenerator()

  subject.in.index_i = 0
  subject.update()
  equal subject.out.value_i, 0

  subject.in.index_i = 1
  subject.update()
  equal subject.out.value_i, 1

  subject.in.index_i = 2
  subject.update()
  equal subject.out.value_i, 1

  subject.in.index_i = 3
  subject.update()
  equal subject.out.value_i, 2

  subject.in.index_i = 4
  subject.update()
  equal subject.out.value_i, 3

  subject.in.index_i = 5
  subject.update()
  equal subject.out.value_i, 5

  subject.in.index_i = 6
  subject.update()
  equal subject.out.value_i, 8

  subject.in.index_i = 7
  subject.update()
  equal subject.out.value_i, 13

  subject.in.index_i = 8
  subject.update()
  equal subject.out.value_i, 21

  subject.in.index_i = 9
  subject.update()
  equal subject.out.value_i, 34


test "Value wraps correctly", () ->
  subject = new shoogl.scene.generators.standard.FibonacciGenerator()
  subject.in.maximum_index_i = 3

  subject.in.index_i = 0
  subject.update()
  equal subject.out.value_i, 0

  subject.in.index_i = 1
  subject.update()
  equal subject.out.value_i, 1

  subject.in.index_i = 2
  subject.update()
  equal subject.out.value_i, 1

  subject.in.index_i = 3
  subject.update()
  equal subject.out.value_i, 2

  subject.in.index_i = 4
  subject.update()
  equal subject.out.value_i, 0
