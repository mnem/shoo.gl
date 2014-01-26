#= require zepto/zepto.min
#= require ace-builds/src-min/ace
#= require ace-builds/src-min/ext-language_tools
#= require ace-builds/src-min/mode-glsl
#= require ace-builds/src-min/theme-monokai
#= require threejs_scene
#= require event_debounce

class @ShaderLabApp
  constructor: () ->

  start: () ->
    @_bind_to_page()
    @_create_scene()
    @_create_editors()

    # Start the scene rendering
    @threejs_scene.render()

  _bind_to_page: () ->
    @elem_editor_vertex = $('#editor-vertex')[0]
    @elem_editor_fragment = $('#editor-fragment')[0]
    @elem_view_threejs = $('#view-threejs')[0]
    @elem_view_variables = $('#view-variables')[0]

  _create_editors: () ->
    @editor_vertex = @_make_editor(@elem_editor_vertex)
    @editor_vertex.setValue(@threejs_scene.get_vertex_source(), -1)
    @vertex_source_debounce = new EventDebounce(@editor_vertex, 'change', @_handle_source_change, 250)

    @editor_fragment = @_make_editor(@elem_editor_fragment)
    @editor_fragment.setValue(@threejs_scene.get_fragment_source(), -1)
    @fragment_source_debounce = new EventDebounce(@editor_fragment, 'change', @_handle_source_change, 250)

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

  _handle_source_change: (e) =>
    shader_parameters =
      vertexShader: @editor_vertex.getValue()
      fragmentShader: @editor_fragment.getValue()

    @threejs_scene.update_shader shader_parameters

  _show_errors: (e) =>
    switch e.type
      when "vertex" then editor = @editor_vertex
      when "fragment" then editor = @editor_fragment
      else
        console.error "Unrecognised errors source type", e
        return

    editor.getSession().setAnnotations(e.errors)

  _clear_errors: (e) =>
    @editor_vertex.getSession().clearAnnotations()
    @editor_fragment.getSession().clearAnnotations()

  _create_scene: () ->
    @threejs_scene = new ThreejsScene(@elem_view_threejs)
    $(@elem_view_variables).append( @threejs_scene.stats.domElement )

    @threejs_scene.on_validation_error = @_show_errors
    @threejs_scene.on_validation_success = @_clear_errors
