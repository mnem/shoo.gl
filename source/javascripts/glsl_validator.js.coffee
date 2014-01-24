class @GLSLValidator
  constructor: (gl_context) ->
    throw new Error('GLSLValidator must be created with a valid WebGL context') unless gl_context?
    @gl = gl_context

  validate_vertex: (source, row_error_number_adjustment = 0) ->
    @_validate_source(source, @gl.VERTEX_SHADER)

  validate_fragment: (source, row_error_number_adjustment = 0) ->
    @_validate_source(source, @gl.FRAGMENT_SHADER)

  _validate_source: (source, type, row_error_number_adjustment = 0) ->
    shader = @gl.createShader(type)
    @gl.shaderSource(shader, source)
    @gl.compileShader(shader)

    compile_ok = @gl.getShaderParameter(shader, @gl.COMPILE_STATUS)
    errors = []
    if not compile_ok
      log = @gl.getShaderInfoLog(shader)
      errors = @_parse_errors(log, row_error_number_adjustment)

    @gl.deleteShader(shader)

    return [compile_ok, errors]

  _parse_errors: (log, row_error_number_adjustment) ->
    errors = []

    # Example error line:
    #    ERROR: 0:2: 'projectionMatrix' : undeclared identifier
    matcher = new RegExp('^([^:]*):([^:]*):([^:]*):(.*)')
    lines = log.split('\n')
    for line in lines
      error_parts = matcher.exec(line)
      if error_parts? and error_parts.length == 5
        [string, type, maybe_column, row, text] = matcher.exec(line)
        error =
          type: type.trim().toLowerCase()
          row: new Number(row.trim()) - 1 + row_error_number_adjustment
          column: new Number(maybe_column.trim())
          text: text
        errors.push(error)

    return errors
