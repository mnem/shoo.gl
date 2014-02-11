#= require zepto/zepto.min
#
#= require ace-builds/src-min/ace
#= require ace-builds/src-min/snippets/glsl
#= require ace-builds/src-min/ext-language_tools
#= require ace-builds/src-min/mode-glsl
#= require ace-builds/src-min/theme-vibrant_ink
#
#= require shoogl/scene/threejs_scene
#= require shoogl/util/event_debounce
#

ThreejsScene = shoogl.scene.ThreejsScene
EventDebounce = shoogl.util.EventDebounce

class namespace('shoogl.app').ShaderLabApp
  constructor: () ->

  start: () ->
    @_bind_to_page()
    @_create_scene()
    @_create_editors()

    @editor_fragment.focus()
    @editor_fragment.gotoLine(@editor_fragment.getSession().getLength())

    @_load_from_url()

    window.onpopstate = @_on_pop_state

    # Start the scene rendering
    @threejs_scene.render()

  _on_pop_state: (e) =>
    @_restore_state(history.state)

  _load_from_url: () ->
    if location.search? and location.search.length > 1
      maybe_data_string = location.search.substr(1)
      maybe_data_string = decodeURIComponent(maybe_data_string)
      try
        maybe_data = JSON.parse(maybe_data_string)
        @_restore_state(maybe_data)
      catch e
        console.error "Odd URL data. Could not decode.", e

  _restore_state: (state) ->
    if not state?
      return

    if state.vs?
      @editor_vertex.setValue(state.vs, -1)
      if state.vsp?
        @editor_vertex.moveCursorToPosition(state.vsp)

    if state.fs?
      @editor_fragment.setValue(state.fs, -1)
      if state.fsp?
        @editor_fragment.moveCursorToPosition(state.fsp)

    if state.tv?
      for k, v of state.tv
        try
          @threejs_scene[k] = v
        catch e
          if v == null then v = "null"
          if k == null then k = "null"
          console.error "Error restoring threejs scene setting '#{k}' to '#{v}'"

    @_sync_threejs_properties_to_ui()

  _bind_to_page: () ->
    @elem_editor_vertex = $('#editor-vertex')[0]
    @elem_editor_fragment = $('#editor-fragment')[0]
    @elem_view_threejs = $('#view-threejs')[0]
    @elem_view_variables = $('#view-variables')[0]

  _create_editors: () ->
    @editor_vertex = @_make_editor(@elem_editor_vertex)
    @editor_vertex.setValue(@threejs_scene.get_vertex_source(), -1)
    @vertex_source_debounce = new shoogl.util.EventDebounce(@editor_vertex, 'change', @_handle_source_change, 500)

    @editor_fragment = @_make_editor(@elem_editor_fragment)
    @editor_fragment.setValue(@threejs_scene.get_fragment_source(), -1)
    @fragment_source_debounce = new shoogl.util.EventDebounce(@editor_fragment, 'change', @_handle_source_change, 500)

  _make_editor: (element) ->
    editor = ace.edit element
    editor.setTheme 'ace/theme/vibrant_ink'

    session = editor.getSession()
    session.setMode 'ace/mode/glsl'
    session.setTabSize 2
    session.setUseSoftTabs false

    ace.require 'ace/ext/language_tools'

    options =
      enableBasicAutocompletion: true
      enableSnippets: true

    editor.setOptions options

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

    @_push_state()

  _sync_threejs_properties_to_ui: () ->
    $("#threejs-tile input[type=checkbox]").each (i, item) =>
      property_name = $(item).prop('id')
      $(item).prop('checked', !!@threejs_scene[property_name])

  _connect_threejs_properties_to_ui: () ->
    # Hook up the global viewport toggles
    $("#threejs-tile input[type=checkbox]").each (i, item) =>
      property_name = $(item).prop('id')
      @threejs_scene[property_name] = !!$(item).prop('checked')
      $(item).on 'change', (e) =>
        @threejs_scene[property_name] = $(item).prop('checked')
    # Now the model selector
    model_paths = []
    $("#threejs-tile #models-selector input[type=radio]").each (i, item) =>
      model_id = $(item).data('model-id')
      model_path = "models/#{model_id}.js"
      model_paths.push(model_path)
      if !!$(item).prop('checked')
        @threejs_scene.load_model(model_path)
      $(item).on 'change', (e) =>
        @threejs_scene.load_model(model_path)
    if app_config.prefetch_models
      @threejs_scene.warm_model_cache(model_paths)

  _create_scene: () ->
    @threejs_scene = new ThreejsScene(@elem_view_threejs)

    @_connect_threejs_properties_to_ui()
    @_sync_threejs_properties_to_ui()

    @threejs_scene.on_validation_error = @_show_errors
    @threejs_scene.on_validation_success = @_clear_errors

  _push_state: () ->
    data =
      vs: @editor_vertex.getValue()
      vsp: @editor_vertex.getCursorPosition()
      fs: @editor_fragment.getValue()
      fsp: @editor_fragment.getCursorPosition()
      tv:
        animate_light: @threejs_scene.animate_light
        animate_model: @threejs_scene.animate_model
        use_phong: @threejs_scene.use_phong

    state = history.state
    if state and state.vs == data.vs and data.fs == state.fs
      return

    now = new Date()
    title = 'ShaderLab - ' + now.toLocaleString()

    data_json_string = JSON.stringify(data)
    url = '?' + encodeURIComponent(data_json_string)

    history.pushState(data, title, url)
