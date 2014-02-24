module 'Vector3 DOM output generator tests'

test 'Value is zeroed after creation', () ->
  subject = new shoogl.scene.generators.standard.Vector3DomOutputGenerator()
  subject.update()
  equal $(subject.out.output_dom).text(), '0.0000 0.0000 0.0000 '

test 'Short value is correct for each component', () ->
  subject = new shoogl.scene.generators.standard.Vector3DomOutputGenerator()
  subject.in.value_v3.set(1.2345, 9.8765, 4.5678)
  subject.update()
  equal $(subject.out.output_dom).text(), '1.2345 9.8765 4.5678 '

test 'Mouseover value is correct for each component', () ->
  subject = new shoogl.scene.generators.standard.Vector3DomOutputGenerator()
  subject.in.value_v3.set(1.234567, 9.876543, 4.567899)
  $(subject._x_span).trigger 'mouseover'
  subject.update()
  equal $(subject.out.output_dom).text(), '1.234567 9.8765 4.5679 '

  $(subject._x_span).trigger 'mouseout'
  $(subject._y_span).trigger 'mouseover'
  subject.update()
  equal $(subject.out.output_dom).text(), '1.2346 9.876543 4.5679 '

  $(subject._y_span).trigger 'mouseout'
  $(subject._z_span).trigger 'mouseover'
  subject.update()
  equal $(subject.out.output_dom).text(), '1.2346 9.8765 4.567899 '

  $(subject._z_span).trigger 'mouseout'
  subject.update()
  equal $(subject.out.output_dom).text(), '1.2346 9.8765 4.5679 '
