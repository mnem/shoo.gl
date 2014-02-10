window.namespace = function(ns) {
  var components = ns.split(".");
  var context = window;
  for (var i = 0; i < components.length; i++) {
    var component = components[i]
    context[component] = context[component] || {}
    context = context[component]
  };

  return context;
};
