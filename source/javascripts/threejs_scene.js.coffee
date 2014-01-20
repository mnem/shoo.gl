#= require threejs/build/three.min
#= require zepto/zepto.min
#= require stats.js/build/stats.min.js
#= require event_debounce

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

    @resize_debounce = new EventDebounce($(window), 'resize', @handle_resize, 250)

  handle_resize: (e) =>
    width = $(@elem_root).width()
    height = $(@elem_root).height()

    @camera.aspect = width / height
    @camera.updateProjectionMatrix()
    @renderer.setSize( width, height )

  create_basic_scene: () ->
    geometry = new THREE.CubeGeometry(1,1,1)
    material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } )
    @cube = new THREE.Mesh( geometry, material )
    @scene.add( @cube )

    @camera.position.z = 5

  render: () =>
    @stats.begin()

    requestAnimationFrame(@render);
    @cube.rotation.x += 0.1;
    @cube.rotation.y += 0.1;
    @renderer.render(@scene, @camera);

    @stats.end()
