module "Type tools tests"

test "First slot returns alphabetically first key", () ->
  object =
    b: "bee"
    a: "aigh"
  slot_name = shoogl.scene.generators.TypeTools.first_slot(object)
  equal slot_name, 'a'

test "First slot returns only key", () ->
  object =
    b: "bee"
  slot_name = shoogl.scene.generators.TypeTools.first_slot(object)
  equal slot_name, 'b'

test "Empty object returns empty string", () ->
  object = {}
  slot_name = shoogl.scene.generators.TypeTools.first_slot(object)
  equal slot_name, ''

test "Null object returns empty string", () ->
  object = null
  slot_name = shoogl.scene.generators.TypeTools.first_slot(object)
  equal slot_name, ''

test "First slot returns matching type over alphabetical first", () ->
  object =
    b_v3: "bee"
    a: "aigh"
  slot_name = shoogl.scene.generators.TypeTools.first_slot(object, 'v3')
  equal slot_name, 'b_v3'

test "First slot returns alphabetical first matching type", () ->
  object =
    b_v3: "bee"
    c_v3: "sea"
    a: "aigh"
  slot_name = shoogl.scene.generators.TypeTools.first_slot(object, 'v3')
  equal slot_name, 'b_v3'
