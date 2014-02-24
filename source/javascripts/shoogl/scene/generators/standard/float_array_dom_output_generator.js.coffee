NS = namespace('shoogl.scene.generators.standard')
class NS.FloatArrayDomOutputGenerator
  constructor: () ->
    @in =
      value_f: []
      last_update_timestamp: 0

    dom = $('<span class="array"></span>')
    @_summary = $('<span></span>')
    @_elements = $('<div></div>')

    $(dom).append @_summary
    $(dom).append @_elements

    $(@_summary).removeClass('hidden')
    $(@_elements).addClass('hidden')

    $(dom).on "mousedown", (e) =>
      if $(@_summary).hasClass('hidden')
        $(@_summary).removeClass('hidden')
        $(@_elements).addClass('hidden')
      else
        $(@_summary).addClass('hidden')
        $(@_elements).removeClass('hidden')

    @out =
      output_dom: dom

    @element_doms = []
    @name = "Float array DOM element"
    @description = "DOM element which displays an array of float values"

  update: () ->
    return unless @in?.value_f

    if @element_doms.length < @in.value_f.length
      @element_doms.length = @in.value_f.length
      for i in [0...@element_doms.length]
        unless @element_doms[i]?
          @element_doms[i] =
            index_dom: $('<span class="index"></span>')
            value_dom: $('<span class="number"></span>')
          $(@_elements).append @element_doms[i].index_dom, @element_doms[i].value_dom
    else if @element_doms.length > @in.value_f.length
      for i in [@in.value_f.length...@element_doms.length]
        if @element_doms[i]?
          $(@element_doms[i].index_dom).remove()
          $(@element_doms[i].value_dom).remove()
      @element_doms.length = @in.value_f.length

    if @in.last_update_timestamp != @_last_update_timestamp
      @_last_update_timestamp = @in.last_update_timestamp
      $(@_summary).text "Number of vertices: #{@in.value_f.length}"
      for i in [0...@in.value_f.length]
        $(@element_doms[i].index_dom).text "#{i}"
        $(@element_doms[i].value_dom).text "#{@in.value_f[i].toFixed(4)} "
