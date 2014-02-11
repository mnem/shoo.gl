class namespace('shoogl.scene.generators.uniform').SceneMainLightPosition
  constructor: (scene_items) ->
    @_light = scene_items.main_light
    @_position = new THREE.Vector3()
    @description = 'Position of the main light in the scene, in world space.'
    @boxed_type = 'v3'
    @aliases = [
    ]
    @parameters = [
    ]

  generate:() ->
    @_position.setFromMatrixPosition(@_light.matrixWorld)
    return @_position
