(function(){var e=function(e,t){return function(){return e.apply(t,arguments)}};namespace("shoogl.util").EventDebounce=function(){function t(t,n,i,s){this.handle_event=e(this.handle_event,this),this.observe_event=e(this.observe_event,this),this.debounce_time=s,this.callback=i,t.on(n,this.observe_event)}return t.prototype.observe_event=function(e){return null!=this.observe_event_timer&&clearTimeout(this.observe_event_timer),this.observe_event_timer=window.setTimeout(this.handle_event,this.debounce_time,e)},t.prototype.handle_event=function(e){return clearTimeout(this.observe_event_timer),this.observe_event_timer=null,this.callback(e)},t}()}).call(this);