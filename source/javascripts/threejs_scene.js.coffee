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
  constructor: (elem_root) ->
    @elem_root = elem_root

    @stats = new Stats()

    @init_root()
    @create_basic_scene()

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
    try
      new_material = new THREE.ShaderMaterial(shader_parameters)
      @mesh.material = new_material
      @shader_material = new_material
    catch e
      console.log "Whee!", e
      @mesh.material = @shader_material

    # console.log "update_shader", @shader_material
    # for k, v of shader_parameters
    #   console.log "  #{k}", v
    #   @shader_material[k] = v

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
