#= require threejs/build/three.min
#= require zepto/zepto.min
#= require stats.js/build/stats.min.js
#= require event_debounce
#= require glsl_validator

default_vertex_source =
"""
//uniform vec3 light;
//varying vec3 vNormal;

void main() {
//  vNormal = normal;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);
}

"""

default_fragment_source =
"""
//uniform vec3 light;
//varying vec3 vNormal;

void main() {
//  vec3 light_norm = normalize(light);
//  float dProd = max(0.0, dot(vNormal, light));
//  gl_FragColor = vec4(dProd, 0.0, 0.0, 1.0);
  gl_FragColor = vec4(0.5, 0.5, 0.5, 1.0);
}

"""

class @ThreejsScene
  constructor: (@elem_root, @animate = true, @light = true) ->
    @_stats = new Stats()

    @_uniforms = {}

    @_init_root()
    @_create_basic_scene()

    $(@elem_root).append(@_stats.domElement)

    @on_validation_error = @_default_error_handler
    @on_validation_success = @_default_error_handler

  get_vertex_source: () ->
    return @shader_material.vertexShader

  get_fragment_source: () ->
    return @shader_material.fragmentShader

  update_shader: (shader_parameters) ->
    if @_validate_shader_parameters(shader_parameters)
      shader_parameters.uniforms = @_uniforms
      new_material = new THREE.ShaderMaterial(shader_parameters)
      @mesh.material = new_material
      @shader_material = new_material

  render: (timestamp) =>
    @_stats.begin()

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

    @_update(time_step)

    @renderer.render(@scene, @camera);

    @_stats.end()

  _update: (time_step) ->
    @_directional_light.visible = @light

    if @animate
      @mesh.rotation.x += 2 * time_step;
      @mesh.rotation.y += 2 * time_step;

  _init_root: () ->
    width = $(@elem_root).width()
    height = $(@elem_root).height()
    console.log "Init ThreejsScene. Size: #{width}x#{height}"

    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera( 75, width / height, 0.1, 1000 )
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize( width, height )
    $(@elem_root).append( @renderer.domElement )

    @validator = new GLSLValidator(@renderer.getContext())

    @resize_debounce = new EventDebounce($(window), 'resize', @_handle_resize, 250)

  _handle_resize: (e) =>
    width = $(@elem_root).width()
    height = $(@elem_root).height()

    @camera.aspect = width / height
    @camera.updateProjectionMatrix()
    @renderer.setSize( width, height )

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

  _create_basic_scene: () ->
    # Cameras!
    @camera.position.z = 2

    # Light!
    @_directional_light = new THREE.DirectionalLight( 0xffffff, 0.75 )
    @_directional_light.position.set(1,1,2)
    @scene.add( @_directional_light )
    @_directional_light.visible = @light

    @_uniforms =
      light =
        type: 'v3'
        value: THREE.Vector3(1,1,2)

    # Models!
    shader_parameters =
      uniforms: @_uniforms
      vertexShader: default_vertex_source
      fragmentShader: default_fragment_source
    @shader_material = new THREE.ShaderMaterial(shader_parameters)
    # @shader_material = new THREE.MeshPhongMaterial()

    @geometry = new THREE.CubeGeometry(1,1,1)
    @geometry.computeFaceNormals()
    @geometry.computeVertexNormals()

    @mesh = new THREE.Mesh( @geometry, @shader_material )
    @scene.add( @mesh )
