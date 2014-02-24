module "Time to sine generator tests"

test "Initial value is 0", () ->
  time_gen = new shoogl.scene.generators.standard.TimeGenerator()
  sine_gen = new shoogl.scene.generators.standard.SineGenerator()
  subject = new shoogl.scene.generators.faux.Connection(time_gen, sine_gen)

  equal subject.out.result_f, 0.0

test "After π/2 seconds, result is 1", () ->
  time_gen = new shoogl.scene.generators.standard.TimeGenerator()
  sine_gen = new shoogl.scene.generators.standard.SineGenerator()
  subject = new shoogl.scene.generators.faux.Connection(time_gen, sine_gen, ':value_f')

  clock = sinon.useFakeTimers(1000 * 0.5 * Math.PI)

  subject.update()
  equal subject.out.result_f, 1.0

  subject.update()
  equal subject.out.result_f, 1.0, "Second update is wrong"

  clock.restore()

test "After advancing π seconds from π/2 seconds, result is -1", () ->
  time_gen = new shoogl.scene.generators.standard.TimeGenerator()
  sine_gen = new shoogl.scene.generators.standard.SineGenerator()
  subject = new shoogl.scene.generators.faux.Connection(time_gen, sine_gen, ':value_f')

  clock = sinon.useFakeTimers(1000 * 0.5 * Math.PI)

  subject.update()
  equal subject.out.result_f, 1.0

  clock.tick(1000 * Math.PI)
  subject.update()
  equal subject.out.result_f, -1.0

  clock.restore()
