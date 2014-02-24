module 'Vertex index map generator tests'

test 'Value is empty after empty creation', () ->
  subject = new shoogl.scene.generators.faux.VertexIndexMap()
  equal subject.in.source_geometry, null
  equal subject.in.updates_per_second, 0
  deepEqual subject.out.index_map_, []

test 'Value is empty after creation with copy generator', () ->
  subject = new shoogl.scene.generators.faux.VertexIndexMap()
  generator = new shoogl.scene.generators.standard.CopyGenerator()
  equal subject.in.source_geometry, null
  equal subject.in.updates_per_second, 0
  deepEqual subject.out.index_map_, []

test 'Value is expected after update with copy generator and a cube', () ->
  generator = new shoogl.scene.generators.standard.CopyGenerator()
  subject = new shoogl.scene.generators.faux.VertexIndexMap(generator)
  geometry = new THREE.CubeGeometry(1, 1, 1)
  subject.in.source_geometry = geometry
  subject.update()

  equal subject.in.source_geometry, geometry
  equal subject.in.updates_per_second, 0
  deepEqual subject.out.index_map_f, [0, 1, 2, 3, 4, 5, 6, 7]
