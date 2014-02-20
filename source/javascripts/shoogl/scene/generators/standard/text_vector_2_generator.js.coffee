NS = namespace('shoogl.scene.generators.standard')
class NS.TextVector2Generator
  constructor: () ->
    @in =
      value_string: '0 0'
    @out =
      result_v2: new THREE.Vector2(0, 0)
    @name = "Vector2 generator"
    @description = "Generates a Vector3 "

  update: () ->
    return unless @in.value_string?

    parts = @in.value_string.split ' '

    return unless parts.length == 2

    x = Number(parts[0]) || 0
    y = Number(parts[1]) || 0

    @out.result_v2.set(x, y)
