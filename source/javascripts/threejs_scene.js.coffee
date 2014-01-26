#= require threejs/build/three.min
#= require zepto/zepto.min
#= require stats.js/build/stats.min.js
#= require event_debounce
#= require glsl_validator

default_vertex_source =
"""
void main() {
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);
}
"""

default_fragment_source =
"""
void main() {
  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
"""

class @ThreejsScene
  constructor: (@elem_root, @animate_camera = true, @lights = true, @animate_lights) ->
    @stats = new Stats()
    @init_root()
    @create_basic_scene()

    @on_validation_error = @_default_error_handler
    @on_validation_success = @_default_error_handler

  init_root: () ->
    width = $(@elem_root).width()
    height = $(@elem_root).height()
    console.log "Init ThreejsScene. Size: #{width}x#{height}"

    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera( 75, width / height, 0.1, 1000 )
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize( width, height )
    $(@elem_root).append( @renderer.domElement )

    @validator = new GLSLValidator(@renderer.getContext())

    @resize_debounce = new EventDebounce($(window), 'resize', @handle_resize, 250)

  handle_resize: (e) =>
    width = $(@elem_root).width()
    height = $(@elem_root).height()

    @camera.aspect = width / height
    @camera.updateProjectionMatrix()
    @renderer.setSize( width, height )

  update_shader: (shader_parameters) ->
    if @_validate_shader_parameters(shader_parameters)
      new_material = new THREE.ShaderMaterial(shader_parameters)
      @mesh.material = new_material
      @shader_material = new_material

  _default_error_handler: (e) =>
    console.error 'threejs_scene error', e

  _default_success_handler: (e) =>
    # Nothing

  _validate_shader_parameters: (parameters) ->
    valid = true
    valid &&= @_validate_vertex_shader(parameters.vertexShader)
    valid &&= @_validate_fragment_shader(parameters.fragmentShader)
    # TODO: Validate other shizz

    if valid then @on_validation_success({})

    return valid

  _validate_vertex_shader: (source) ->
    # Extracted from three.js buildProgram
    prefix = [
      "precision " + @renderer.getPrecision() + " float;",
      "precision " + @renderer.getPrecision() + " int;",

      "uniform mat4 modelMatrix;",
      "uniform mat4 modelViewMatrix;",
      "uniform mat4 projectionMatrix;",
      "uniform mat4 viewMatrix;",
      "uniform mat3 normalMatrix;",
      "uniform vec3 cameraPosition;",

      "attribute vec3 position;",
      "attribute vec3 normal;",
      "attribute vec2 uv;",
      "attribute vec2 uv2;",

      "",
    ]
    source = prefix.join('\n') + source
    [success, errors] = @validator.validate_vertex(source, -prefix.length)

    if not success then @on_validation_error({type: 'vertex', errors: errors})

    return success

  _validate_fragment_shader: (source) ->
    # Extracted from three.js buildProgram
    prefix = [
      "precision " + @renderer.getPrecision() + " float;",
      "precision " + @renderer.getPrecision() + " int;",

      "uniform mat4 viewMatrix;",
      "uniform vec3 cameraPosition;",

      "",
    ]
    source = prefix.join('\n') + source
    [success, errors] = @validator.validate_fragment(source, -prefix.length)

    if not success then @on_validation_error({type: 'fragment', errors: errors})

    return success

  get_vertex_source: () ->
    return @shader_material.vertexShader

  get_fragment_source: () ->
    return @shader_material.fragmentShader

  create_basic_scene: () ->
    shader_parameters =
      vertexShader: default_vertex_source
      fragmentShader: default_fragment_source
    @shader_material = new THREE.ShaderMaterial(shader_parameters)

    @geometry = new THREE.CubeGeometry(1,1,1)

    @mesh = new THREE.Mesh( @geometry, @shader_material )
    @scene.add( @mesh )

    @camera.position.z = 1.5

  render: (timestamp) =>
    @stats.begin()

    # Work out our time step. No
    # smoothing or max step size for
    # the moment
    if @last_timestamp?
        time_step = (timestamp - @last_timestamp) / 1000
    else
        time_step = 1/60

    @last_timestamp = timestamp

    # Do some animation
    requestAnimationFrame(@render);
    @mesh.rotation.x += 2 * time_step;
    @mesh.rotation.y += 2 * time_step;
    @renderer.render(@scene, @camera);

    @stats.end()
