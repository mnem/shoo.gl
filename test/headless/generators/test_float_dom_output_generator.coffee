module 'Float DOM output generator tests'

test 'Value is 0.0000 after creation', () ->
  subject = new shoogl.scene.generators.standard.FloatDomOutputGenerator()
  subject.update()
  equal $(subject.out.output_dom).text(), '0.0000'

test 'DOM has expected classes without mouseover', () ->
  subject = new shoogl.scene.generators.standard.FloatDomOutputGenerator()
  ok $(subject.out.output_dom).hasClass('number'), 'Expected .number CSS class'
  ok not $(subject.out.output_dom).hasClass('mouseover'), 'Expected no .mouseover CSS class'

test 'DOM has expected classes with mouseover', () ->
  subject = new shoogl.scene.generators.standard.FloatDomOutputGenerator()
  $(subject.out.output_dom).trigger 'mouseover'
  ok $(subject.out.output_dom).hasClass('number'), 'Expected .number CSS class'
  ok $(subject.out.output_dom).hasClass('mouseover'), 'Expected .mouseover CSS class'

test 'Value is 0 after creation and with mouseover', () ->
  subject = new shoogl.scene.generators.standard.FloatDomOutputGenerator()
  $(subject.out.output_dom).trigger 'mouseover'
  subject.update()
  equal $(subject.out.output_dom).text(), '0'

test 'Value is rounded correctly', () ->
  subject = new shoogl.scene.generators.standard.FloatDomOutputGenerator()
  subject.in.value_f = 1.23456789
  subject.update()
  equal $(subject.out.output_dom).text(), '1.2346'

test 'Long value is shown with mouseover', () ->
  subject = new shoogl.scene.generators.standard.FloatDomOutputGenerator()
  subject.in.value_f = 1.23456789
  $(subject.out.output_dom).trigger 'mouseover'
  subject.update()
  equal $(subject.out.output_dom).text(), '1.23456789'

test 'Mouse out shows short rounded value', () ->
  subject = new shoogl.scene.generators.standard.FloatDomOutputGenerator()
  subject.in.value_f = 1.23456789
  $(subject.out.output_dom).trigger 'mouseover'
  subject.update()
  equal $(subject.out.output_dom).text(), '1.23456789'
  $(subject.out.output_dom).trigger 'mouseout'
  subject.update()
  equal $(subject.out.output_dom).text(), '1.2346'
