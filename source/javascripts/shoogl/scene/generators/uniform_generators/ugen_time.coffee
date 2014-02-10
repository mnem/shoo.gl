class @UGenTime
  generate:() ->
    @_uniform ||= {type: 'f'}
    @_uniform.value = Date.now()/1000
    return @_uniform
