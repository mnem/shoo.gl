module "Generator connection tests"

class MockGenerator
  constructor: (initial_input_f = 0, initial_input_i = 0) ->
    @description = @name = 'MockGenerator'
    @in =
      value_f: initial_input_f
      value_i: initial_input_i
    @out =
      value_f: 0
      value_i: 0
    @update_called = false

  update: () ->
    @out.value_f = @in.value_f
    @out.value_i = @in.value_i
    @update_called = true

class MockGeneratorDifferentTypes
  constructor: (initial_input_i = 0) ->
    @description = @name = 'MockGeneratorDifferentTypes'
    @in =
      value_i: initial_input_i
    @out =
      value_f: 0
    @update_called = false

  update: () ->
    @out.value_f = @in.value_i
    @update_called = true

test "Empty connection can update", () ->
  subject = new shoogl.scene.generators.faux.Connection()
  subject.update()
  ok true, "Nothing exploded"

test "Connection with only output can update", () ->
  mock_a = new MockGenerator(0)
  subject = new shoogl.scene.generators.faux.Connection(mock_a)
  subject.update()
  ok mock_a.update_called, "Mock update was not called"

test "Connection with only input can update", () ->
  mock_a = null
  mock_b = new MockGenerator(0)
  subject = new shoogl.scene.generators.faux.Connection(mock_a, mock_b)
  subject.update()
  ok mock_b.update_called, "Mock update was not called"

test "Connection updates and copies data", () ->
  mock_a = new MockGenerator(1)
  mock_b = new MockGenerator(0)

  subject = new shoogl.scene.generators.faux.Connection(mock_a, mock_b)
  subject.update()

  ok mock_a.update_called, "Mock a update was not called"
  ok mock_b.update_called, "Mock b update was not called"

  equal mock_a.out.value_f, 1, "Mock a output value is wrong"
  equal mock_b.out.value_f, 1, "Mock b output value is wrong"

test "Connection updates but does not copy different data types", () ->
  mock_a = new MockGeneratorDifferentTypes(1)
  mock_b = new MockGeneratorDifferentTypes(0)

  subject = new shoogl.scene.generators.faux.Connection(mock_a, mock_b)
  subject.update()

  ok mock_a.update_called, "Mock a update was not called"
  ok mock_b.update_called, "Mock b update was not called"

  equal mock_a.out.value_f, 1, "Mock a output value is wrong"
  equal mock_b.out.value_f, 0, "Mock b output value is wrong"
