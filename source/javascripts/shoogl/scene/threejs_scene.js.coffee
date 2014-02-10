#= require threejs/build/three
#= require stats.js/build/stats.min.js
#
#= require zepto/zepto.min
#
#= require shoogl/scene/camera/OrbitControls
#= require shoogl/scene/validator/glsl_validator
#= require shoogl/scene/fonts/helvetiker_regular.typeface
#
#= require shoogl/util/event_debounce

default_vertex_source =
"""
varying vec3 vNormal;
varying vec3 vViewPosition;

void main() {
  vec3 transformedNormal = normalMatrix * normal;
  vNormal = normalize(transformedNormal);

  vec4 modelViewPosition;
  modelViewPosition = modelViewMatrix * vec4( position, 1.0 );
  vViewPosition = -modelViewPosition.xyz;

  gl_Position = projectionMatrix * modelViewPosition;
}

"""

default_fragment_source =
"""
uniform vec3 lightWorldPosition;
varying vec3 vNormal;
varying vec3 vViewPosition;

void main() {
  gl_FragColor = vec4(vec3(0.9), 1.0);

  // Simplistic lighting, based around the phong code
  // in three.js, but without the fancy bits
  vec4 lightPosition = viewMatrix * vec4( lightWorldPosition, 1.0 );
  vec3 lightVector = lightPosition.xyz + vViewPosition;
  lightVector = normalize( lightVector );

  float lightIntensity = max(dot( normalize(vNormal), lightVector ), 0.2);

  gl_FragColor.xyz = gl_FragColor.xyz * lightIntensity;
}

"""

simple_toon_fragment_source =
"""
uniform vec3 lightWorldPosition;
varying vec3 vNormal;
varying vec3 vViewPosition;

// If enabled performs a rubbish cell shade effect
#define TOONIFY 1

// If enabled retains maximum intensity highlights
// reducing the rest to 2 tone
#define TOONIFY_2TONE_WITH_HIGHLIGHTS 1

#if TOONIFY_2TONE_WITH_HIGHLIGHTS
// If retaining highlights, we want to have
// more shades to pick the highlight from. The
// larger the number, the finer the highlights.
#define TOONIFIY_SHADES 32.0
#else
// If not showing highlights, sets the
// number of levels the colour bands used. The
// larger the number, the more detail is retained
#define TOONIFIY_SHADES 3.0
#endif // TOONIFY_2TONE_WITH_HIGHLIGHTS

void main() {
  // Simplistic lighting, based around the phong code
  // in three.js, but without the fancy bits
  vec4 lightPosition = viewMatrix * vec4( lightWorldPosition, 1.0 );
  vec3 lightVector = lightPosition.xyz + vViewPosition;
  lightVector = normalize( lightVector );

  float lightIntensity = dot( normalize(vNormal), lightVector );

#if TOONIFY
  // Quantize
  float levels = TOONIFIY_SHADES;
  lightIntensity *= levels;
  lightIntensity = floor(lightIntensity);

#if TOONIFY_2TONE_WITH_HIGHLIGHTS
  if ( lightIntensity < levels / 2.0 ) {
    lightIntensity = levels / 6.0;
  } else if ( lightIntensity < levels - 1.0 ) {
    lightIntensity = levels / 2.0 +  levels / 8.0;
  }
#endif // TOONIFY_2TONE_WITH_HIGHLIGHTS

  lightIntensity /= levels - 0.5;
#endif // TOONIFY

  vec3 color =  vec3(0.0, 1.0, 0.1);
  gl_FragColor = vec4(lightIntensity * color, 1.0);
}

"""

EventDebounce = shoogl.util.EventDebounce
GLSLValidator = shoogl.scene.validator.GLSLValidator

class namespace('shoogl.scene').ThreejsScene
  constructor: (@elem_root,
                @animate_camera = false,
                @light_linked_to_camera = true,
                @use_phong = false,
                @clear_color = 0x000000) ->
    @_cached_clear_color = ~@clear_color

    @_model_cache = {}
    @_active_model = null

    @_showing_loading_indicator = false
    @_loading_indicator = null

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
      @shader_material = new_material

  render: (timestamp) =>
    @_stats.begin()

    # Do some animation
    requestAnimationFrame(@render);

    # Work out our time step. No
    # smoothing or max step size for
    # the moment
    if @last_timestamp?
        time_step = (timestamp - @last_timestamp) / 1000
    else
        time_step = 1/60

    @last_timestamp = timestamp

    @_update(time_step)

    @controls.update()

    @renderer.render(@scene, @camera);

    @_stats.end()

  load_model: (model_path) ->
    current_model = @_model_cache[@_active_model]
    if current_model?
      @scene.remove(current_model.container)

    @_active_model = model_path
    new_model = @_model_cache[@_active_model]

    if not new_model?
      new_model = @_fetch_model(model_path)

    @scene.add(new_model.container)

  warm_model_cache: (model_paths) ->
    for model_path in model_paths
      console.log "Prefetching model: ", model_path
      @_fetch_model(model_path)

  _fetch_model: (model_path) ->
    new_model =
      container: new THREE.Object3D()
      mesh: null
    @_model_cache[@_active_model] = new_model
    loader = new THREE.JSONLoader();
    loader.load model_path, (geometry) =>
      new_model.mesh = new THREE.Mesh(geometry, @shader_material)
      new_model.mesh.position.set(0, 0, 0)
      new_model.container.add(new_model.mesh)

    return new_model

  _update: (time_step) ->
    if @clear_color != @_cached_clear_color
      @_cached_clear_color = @clear_color
      @renderer.setClearColor(@clear_color, 1)

    if @light_linked_to_camera
      @_scene_light.position.copy(@camera.position)
      @_uniforms.lightWorldPosition.value.setFromMatrixPosition(@_scene_light.matrixWorld)

    @controls.autoRotate = @animate_camera

    # Update the material used
    if @use_phong
      material = @phong_material
    else
      material = @shader_material

    mesh = @_loading_indicator
    if @_model_cache[@_active_model]? and @_model_cache[@_active_model].mesh?
      if @_showing_loading_indicator
        @_showing_loading_indicator = false
        @scene.remove(@_loading_indicator)
      mesh = @_model_cache[@_active_model].mesh
    else if not @_showing_loading_indicator
      @_showing_loading_indicator = true
      @scene.add(@_loading_indicator)

    mesh.material = material if mesh.material != material

  _init_root: () ->
    width = $(@elem_root).width()
    height = $(@elem_root).height()

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
    @renderer.setClearColor(@clear_color, 1)

    @_create_basic_camera()
    @_create_basic_lights()
    @_create_basic_materials()
    @_create_basic_meshes()

  _create_basic_camera: () ->
    cfg = threejs_config
    @camera.position.set(cfg.camera.position.x, cfg.camera.position.y, cfg.camera.position.z)
    @controls = new THREE.OrbitControls( @camera );
    @controls.minDistance = cfg.camera.min_distance
    @controls.maxDistance = cfg.camera.max_distance
    @controls.autoRotateSpeed = cfg.camera.auto_rotate_speed
    @controls.noPan = cfg.camera.prevent_pan

  _create_basic_lights: () ->
    cfg = threejs_config
    @_scene_light = new THREE.DirectionalLight( cfg.light.color, cfg.light.intensity )
    @_scene_light.position.copy(@camera.position)
    @scene.add(@_scene_light)

  _create_basic_materials: () ->
    @_uniforms =
      lightWorldPosition :
        type: 'v3'
        value: new THREE.Vector3().copy(@_scene_light.position)

    shader_parameters =
      uniforms: @_uniforms
      vertexShader: default_vertex_source
      fragmentShader: default_fragment_source
    @shader_material = new THREE.ShaderMaterial(shader_parameters)

    @phong_material = new THREE.MeshPhongMaterial({color:0x50C8FF})

  _create_basic_meshes: () ->
    options =
      size: 0.25
      height: 0.125
      curveSegments: 2
      font: "helvetiker"
    geometry = new THREE.TextGeometry("Loading...", options)
    geometry.computeBoundingBox();
    offset = geometry.boundingBox.max.sub(geometry.boundingBox.min).multiplyScalar(-0.5)
    @_loading_indicator = new THREE.Mesh( geometry, @shader_material )
    @_loading_indicator.position.copy(offset)
