#= require zepto/zepto.min
#= require ace-builds/src-min/ace
#= require ace-builds/src-min/ext-language_tools
#= require ace-builds/src-min/mode-glsl
#= require ace-builds/src-min/theme-monokai
#= require threejs_scene
#= require event_debounce

class @ShaderLabApp
  constructor: () ->

  _bind_to_page: () ->
    @elem_editor_vertex = $('#editor-vertex')[0]
    @elem_editor_fragment = $('#editor-fragment')[0]
    @elem_view_threejs = $('#view-threejs')[0]
    @elem_view_variables = $('#view-variables')[0]

  _make_editor: (element) ->
    editor = ace.edit element
    editor.setTheme 'ace/theme/monokai'

    session = editor.getSession()
    session.setMode 'ace/mode/glsl'
    session.setTabSize 2
    session.setUseSoftTabs false

    # options =
    #   enableBasicAutocompletion: true
    #   enableSnippets: true

    # editor.setOptions options

    return editor

  _create_editors: () ->
    @editor_vertex = @_make_editor(@elem_editor_vertex)
    @editor_vertex.setValue(@threejs_scene.get_vertex_source(), -1)
    @vertex_source_debounce = new EventDebounce(@editor_vertex, 'change', @_handle_source_change, 250)

    @editor_fragment = @_make_editor(@elem_editor_fragment)
    @editor_fragment.setValue(@threejs_scene.get_fragment_source(), -1)
    @fragment_source_debounce = new EventDebounce(@editor_fragment, 'change', @_handle_source_change, 250)

  _handle_source_change: (e) =>
    vertex_ok = @_validate_vertex_source()
    fragment_ok = @_validate_fragment_source()
    if vertex_ok and fragment_ok
      shader_parameters =
        vertexShader: @editor_vertex.getValue()
        fragmentShader: @editor_fragment.getValue()
      @threejs_scene.update_shader(shader_parameters)

  _validate_vertex_source: () ->
    prefix = [
      "precision " + @threejs_scene.renderer.getPrecision() + " float;",
      "precision " + @threejs_scene.renderer.getPrecision() + " int;",

      "uniform mat4 modelMatrix;",
      "uniform mat4 modelViewMatrix;",
      "uniform mat4 projectionMatrix;",
      "uniform mat4 viewMatrix;",
      "uniform mat3 normalMatrix;",
      "uniform vec3 cameraPosition;",

      "attribute vec3 position;",
      "attribute vec3 normal;",
      "attribute vec2 uv;",
      "attribute vec2 uv2;"
    ]
    source = prefix.join('\n') + @editor_vertex.getValue()
    [success, errors] = @threejs_scene.validator.validate_vertex(source, -prefix.length)
    if success
      @editor_vertex.getSession().clearAnnotations()
    else
      @editor_vertex.getSession().setAnnotations(errors)
    return success

  _validate_fragment_source: () ->
    prefix = [
      "precision " + @threejs_scene.renderer.getPrecision() + " float;",
      "precision " + @threejs_scene.renderer.getPrecision() + " int;",

      "uniform mat4 viewMatrix;",
      "uniform vec3 cameraPosition;",
    ]
    source = @editor_fragment.getValue()
    [success, errors] = @threejs_scene.validator.validate_fragment(source, -prefix.length)
    if success
      @editor_fragment.getSession().clearAnnotations()
    else
      @editor_fragment.getSession().setAnnotations(errors)
    return success

  _create_scene: () ->
    @threejs_scene = new ThreejsScene(@elem_view_threejs)

  _create_variables: () ->
    $(@elem_view_variables).append( @threejs_scene.stats.domElement )

  start: () ->
    @_bind_to_page()
    @_create_scene()
    @_create_editors()
    @_create_variables()

    # Start the scene rendering
    @threejs_scene.render()

