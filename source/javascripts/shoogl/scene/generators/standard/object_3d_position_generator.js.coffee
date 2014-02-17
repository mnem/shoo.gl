NS = namespace('shoogl.scene.generators.standard')
class NS.Object3DPositionGenerator
  constructor: () ->
    @in =
      source_object3d: null
    @out =
      result_vec3: new THREE.Vector3(0, 0, 0)
    @name = "Object3D position"
    @description = "Generates a Vector3 corresponding to the source object's world position"

  update: () ->
    return unless @in.source_object3d?
    @out.result_vec3.setFromMatrixPosition(@in.source_object3d.matrixWorld)
