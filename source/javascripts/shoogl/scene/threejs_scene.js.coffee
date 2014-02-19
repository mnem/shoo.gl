#= require threejs/build/three
#= require stats.js/build/stats.min.js
#
#= require zepto/zepto.min
#
#= require shoogl/scene/camera/OrbitControls
#= require shoogl/scene/fonts/helvetiker_regular.typeface
#= require shoogl/scene/validator/glsl_validator
#= require shoogl/scene/default_shaders
#= require shoogl/scene/scene_items
#= require shoogl/scene/generators/generator_list
#
#= require shoogl/util/event_debounce
#

EventDebounce = shoogl.util.EventDebounce
GLSLValidator = shoogl.scene.validator.GLSLValidator
DefaultShaders = shoogl.scene.default_shaders
SceneItems = shoogl.scene.SceneItems

NS = namespace('shoogl.scene')
class NS.ThreejsScene
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

    @_init_root()
    @validator = new GLSLValidator(@renderer.getContext())
    @_create_basic_scene()

    $(@elem_root).append(@_stats.domElement)

    @_scene_items = new SceneItems(
      @elem_root,
      @scene,
      @camera,
      @main_light)
    @uniform_generators = new shoogl.scene.generators.GeneratorList('Uniforms Foo')
    @uniform_generators.add "uTime",
      new shoogl.scene.generators.standard.TimeGenerator(), 'seconds_f'
    @uniform_generators.add "uTimeSine",
      new shoogl.scene.generators.standard.TimeGenerator(), 'seconds_f:value_f',
      new shoogl.scene.generators.standard.SineGenerator(), 'result_f'
    generator = new shoogl.scene.generators.standard.Object3DPositionGenerator()
    generator.in.source_object3d = @main_light
    @uniform_generators.add "uSceneMainLightPosition",
      generator, 'result_vec3'

    @on_validation_error = @_default_error_handler
    @on_validation_success = @_default_success_handler

  get_vertex_source: () ->
    return @shader_material.vertexShader

  get_fragment_source: () ->
    return @shader_material.fragmentShader

  update_shader: (shader_parameters) ->
    if @_validate_shader_parameters(shader_parameters)
      # shader_parameters.uniforms = @uniform_generators.generate()
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
      @main_light.position.copy(@camera.position)

    @controls.autoRotate = @animate_camera

    # Update the material used
    if @use_phong
      material = @phong_material
    else
      @uniform_generators.update() # @shader_material.uniforms
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
    @main_light = new THREE.DirectionalLight( cfg.light.color, cfg.light.intensity )
    @main_light.position.copy(@camera.position)
    @scene.add(@main_light)

  _create_basic_materials: () ->
    default_vertex_source = DefaultShaders.vertex[DefaultShaders.vertex._default]
    default_fragment_source = DefaultShaders.fragment[DefaultShaders.fragment._default]

    shader_parameters =
      vertexShader: default_vertex_source.code
      fragmentShader: default_fragment_source.code
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
