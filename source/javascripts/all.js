//= require namespace
//
//= require zepto/zepto.min.js
//
//= require shoogl/app/shader_lab_app

Zepto(function($){
  ns = namespace('shoogl')
  ns.app = new ns.app.ShaderLabApp();
  ns.app.start();
})
