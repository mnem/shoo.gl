module 'Generator list tests'

test 'List dom is correct after creation', () ->
  subject = new shoogl.scene.generators.GeneratorList()
  subject.update()
  equal $(subject.dom).text(), ''

test 'List dom is correct after creation with title', () ->
  subject = new shoogl.scene.generators.GeneratorList('Uniforms')
  subject.update()
  equal $(subject.dom).text(), 'Uniforms'

test 'List dom is correct after adding 1 generator', () ->
  subject = new shoogl.scene.generators.GeneratorList('Uniforms')
  generator_a = new shoogl.scene.generators.standard.CosineGenerator()
  equal generator_a.out.result_f, 0.0
  subject.add "uCosine", generator_a, 'result_f'
  subject.update()
  equal generator_a.out.result_f, 1.0
  equal $(subject.dom).text(), 'UniformsuCosine1.0000'

test 'List dom is correct after adding 2 generators', () ->
  subject = new shoogl.scene.generators.GeneratorList('Uniforms')

  generator_a = new shoogl.scene.generators.standard.CosineGenerator()
  equal generator_a.out.result_f, 0.0
  subject.add "uCosine", generator_a, 'result_f'

  generator_b = new shoogl.scene.generators.standard.SineGenerator()
  equal generator_b.out.result_f, 0.0
  subject.add "uSine", generator_b, 'result_f'

  subject.update()

  equal generator_a.out.result_f, 1.0
  equal generator_b.out.result_f, 0.0
  equal $(subject.dom).text(), 'UniformsuCosine1.0000uSine0.0000'

test 'List dom is correct after adding 2 generators in reverse order', () ->
  subject = new shoogl.scene.generators.GeneratorList('Uniforms')

  generator_a = new shoogl.scene.generators.standard.SineGenerator()
  equal generator_a.out.result_f, 0.0
  subject.add "uSine", generator_a, 'result_f'

  generator_b = new shoogl.scene.generators.standard.CosineGenerator()
  equal generator_b.out.result_f, 0.0
  subject.add "uCosine", generator_b, 'result_f'

  subject.update()

  equal generator_a.out.result_f, 0.0
  equal generator_b.out.result_f, 1.0
  equal $(subject.dom).text(), 'UniformsuSine0.0000uCosine1.0000'

test 'List dom is correct after adding 1 generator chain', () ->
  clock = sinon.useFakeTimers(0)

  subject = new shoogl.scene.generators.GeneratorList('Uniforms')
  generator_a = new shoogl.scene.generators.standard.TimeGenerator()
  generator_b = new shoogl.scene.generators.standard.SineGenerator()
  subject.add "uTimeSine",
    generator_a, 'seconds_f:value_f',
    generator_b, 'result_f'

  subject.update()
  equal generator_b.out.result_f, 0.0
  equal $(subject.dom).text(), 'UniformsuTimeSine0.0000'

  clock.tick(1000 * 0.5 * Math.PI)

  subject.update()
  equal generator_b.out.result_f, 1.0
  equal $(subject.dom).text(), 'UniformsuTimeSine1.0000'

  clock.restore()

test 'List dom is correct after adding 2 generator chains', () ->
  clock = sinon.useFakeTimers(0)

  subject = new shoogl.scene.generators.GeneratorList('Uniforms')
  generator_a = new shoogl.scene.generators.standard.TimeGenerator()
  generator_b = new shoogl.scene.generators.standard.SineGenerator()
  subject.add "uTimeSine",
    generator_a, 'seconds_f:value_f',
    generator_b, 'result_f'

  generator_a = new shoogl.scene.generators.standard.TimeGenerator()
  generator_b = new shoogl.scene.generators.standard.SineGenerator()
  subject.add "uTimeSineTwo",
    generator_a, 'seconds_f:value_f',
    generator_b, 'result_f'

  subject.update()
  equal $(subject.dom).text(), 'UniformsuTimeSine0.0000uTimeSineTwo0.0000'

  clock.tick(1000 * 0.5 * Math.PI)

  subject.update()
  equal $(subject.dom).text(), 'UniformsuTimeSine1.0000uTimeSineTwo1.0000'

  clock.restore()

test 'Three type object is correct when empty', () ->
  subject = new shoogl.scene.generators.GeneratorList('Uniforms')
  three_object = subject.to_three_type_object()

  deepEqual three_object, {}

test 'Three type object is correct with float generator', () ->
  subject = new shoogl.scene.generators.GeneratorList('Uniforms')
  generator_a = new shoogl.scene.generators.standard.SineGenerator()
  subject.add "uSine", generator_a, 'result_f'
  subject.update()

  three_object = subject.to_three_type_object()

  deepEqual three_object,
    uSine:
      type: 'f'
      value: 0

test 'Three type object is correct with vec3 generator', () ->
  subject = new shoogl.scene.generators.GeneratorList('Uniforms')
  generator_a = new shoogl.scene.generators.standard.TextVector3Generator()
  generator_a.in.value_string = '1 2 3'
  subject.add "uPosition", generator_a, 'result_vec3'
  subject.update()

  three_object = subject.to_three_type_object()

  deepEqual three_object,
    uPosition:
      type: 'vec3'
      value: new THREE.Vector3(1, 2, 3)

test 'Three type object is correct with more than 1 generator', () ->
  subject = new shoogl.scene.generators.GeneratorList('Uniforms')
  generator_a = new shoogl.scene.generators.standard.TextVector3Generator()
  generator_a.in.value_string = '1 2 3'
  subject.add "uPosition", generator_a, 'result_vec3'
  generator_b = new shoogl.scene.generators.standard.SineGenerator()
  subject.add "uSine", generator_b, 'result_f'
  subject.update()

  three_object = subject.to_three_type_object()

  deepEqual three_object,
    uSine:
      type: 'f'
      value: 0
    uPosition:
      type: 'vec3'
      value: new THREE.Vector3(1, 2, 3)

test 'Three type object the same object each time it is requests', () ->
  subject = new shoogl.scene.generators.GeneratorList('Uniforms')

  generator_a = new shoogl.scene.generators.standard.TextVector3Generator()
  generator_a.in.value_string = '1 2 3'
  subject.add "uPosition", generator_a, 'result_vec3'
  subject.update()
  three_object_a = subject.to_three_type_object()

  generator_b = new shoogl.scene.generators.standard.SineGenerator()
  subject.add "uSine", generator_b, 'result_f'
  subject.update()
  three_object_b = subject.to_three_type_object()

  strictEqual three_object_a, three_object_b
  deepEqual three_object_a, three_object_b
