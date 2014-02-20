base_time_ms = Date.now()
base_time_s = base_time_ms / 1000

module "Time generator tests"

test "Time is 0 after creation", () ->
  subject = new shoogl.scene.generators.standard.TimeGenerator()
  equal subject.out.seconds_f, 0.0

test "Time is #{base_time_s} after update", () ->
  clock = sinon.useFakeTimers(base_time_ms)

  subject = new shoogl.scene.generators.standard.TimeGenerator()
  subject.update()
  equal subject.out.seconds_f, base_time_s, "Unexpected time after update."

  clock.restore()

test "Time is #{base_time_s + 1} after 1000 ms passes", () ->
  clock = sinon.useFakeTimers(base_time_ms)

  subject = new shoogl.scene.generators.standard.TimeGenerator()
  subject.update()
  equal subject.out.seconds_f, base_time_s, "Unexpected time after update."

  clock.tick(1000)
  subject.update()
  equal subject.out.seconds_f, base_time_s + 1.0, "Unexpected time after update."

  clock.restore()
