#= require zepto/zepto.min
#= require ace-builds/src-min/ace
#= require ace-builds/src-min/ext-language_tools
#= require ace-builds/src-min/mode-glsl
#= require ace-builds/src-min/theme-monokai
#= require threejs_scene
#= require event_debounce

class @ShaderLabApp
  constructor: () ->

  bind_to_page: () ->
    @elem_editor_vertex = $('#editor-vertex')[0]
    @elem_editor_fragment = $('#editor-fragment')[0]
    @elem_view_threejs = $('#view-threejs')[0]
    @elem_view_variables = $('#view-variables')[0]

  make_editor: (element) ->
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

  create_editors: () ->
    @editor_vertex = @make_editor(@elem_editor_vertex)
    @editor_vertex.setValue(@threejs_scene.get_vertex_source(), -1)
    @vertex_source_debounce = new EventDebounce(@editor_vertex, 'change', @handle_vertex_source_change, 1000)

    @editor_fragment = @make_editor(@elem_editor_fragment)
    @editor_fragment.setValue(@threejs_scene.get_fragment_source(), -1)
    @fragment_source_debounce = new EventDebounce(@editor_fragment, 'change', @handle_fragment_source_change, 1000)

  handle_vertex_source_change: (e) =>
    console.log "handle_vertex_source_change"
    shader_parameters =
      vertexShader: @editor_vertex.getValue()
      fragmentShader: @editor_fragment.getValue()
    @threejs_scene.update_shader(shader_parameters)

  handle_fragment_source_change: (e) =>
    console.log "handle_fragment_source_change"
    shader_parameters =
      vertexShader: @editor_vertex.getValue()
      fragmentShader: @editor_fragment.getValue()
    @threejs_scene.update_shader(shader_parameters)

  create_scene: () ->
    @threejs_scene = new ThreejsScene(@elem_view_threejs)

  create_variables: () ->
    $(@elem_view_variables).append( @threejs_scene.stats.domElement )

  start: () ->
    @bind_to_page()
    @create_scene()
    @create_editors()
    @create_variables()

    # Start the scene rendering
    @threejs_scene.render()

