(function(){var t;t=namespace("shoogl.scene.generators.standard"),t.CosineGenerator=function(){function t(){this["in"]={value_f:0,hertz_f:1},this.out={result_f:0},this.name="Cosine generator",this.description="Uses the input value and hertz frequency to generate a cosine output value."}return t.prototype.update=function(){return this.out.result_f=Math.cos(this["in"].value_f*this["in"].hertz_f)},t}()}).call(this);