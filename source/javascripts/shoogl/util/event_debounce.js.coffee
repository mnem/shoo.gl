# Prevents event spam by
# waiting debounce_time after
# the the last event is observed
# before actually triggering the
# callback.

class namespace('shoogl.util').EventDebounce
  constructor: (source, event, callback, debounce_time) ->
    @debounce_time = debounce_time
    @callback = callback
    source.on(event, @observe_event)

  observe_event: (e) =>
    if @observe_event_timer?
      clearTimeout(@observe_event_timer)

    @observe_event_timer = window.setTimeout(@handle_event, @debounce_time, e)

  handle_event: (e) =>
    clearTimeout(@observe_event_timer)
    @observe_event_timer = null
    @callback(e)
