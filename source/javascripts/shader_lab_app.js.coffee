#= require zepto/zepto.min
#= require ace-builds/src-min/ace
#= require ace-builds/src-min/ext-language_tools
#= require ace-builds/src-min/mode-glsl
#= require ace-builds/src-min/theme-monokai
#= require threejs_scene

class @ShaderLabApp
  constructor: () ->
    @default_vertex   = """
                        void main() {
                          gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);
                        }
                        """

    @default_fragment = """
                        void main() {
                          gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0);
                        }
                        """

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
    @editor_vertex.setValue(@default_vertex, -1)

    @editor_fragment = @make_editor(@elem_editor_fragment)
    @editor_fragment.setValue(@default_fragment, -1)

  scene_resize: (e) ->
    console.log "Foo"
    # console.log "Now I'm #{$(@elem_view_threejs).width()}x#{$(@elem_view_threejs).height()}"

  create_scene: () ->
    @threejs_scene = new ThreejsScene(@elem_view_threejs)

  create_variables: () ->
    $(@elem_view_variables).append( @threejs_scene.stats.domElement )

  start: () ->
    @bind_to_page()
    @create_editors()
    @create_scene()
    @create_variables()

    # Start the scene rendering
    @threejs_scene.render()

