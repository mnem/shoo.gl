NS = namespace('shoogl.scene.generators.standard')
class NS.TextVector3Generator
  constructor: () ->
    @in =
      value_string: '0 0 0'
    @out =
      result_vec3: new THREE.Vector3(0, 0, 0)
    @name = "Vector3 generator"
    @description = "Generates a Vector3 "

  update: () ->
    return unless @in.value_string?

    parts = @in.value_string.split ' '

    return unless parts.length == 3

    x = Number(parts[0]) || 0
    y = Number(parts[1]) || 0
    z = Number(parts[2]) || 0

    @out.result_vec3.set(x, y, z)
