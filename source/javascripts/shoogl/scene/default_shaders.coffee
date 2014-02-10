DefaultShaders = namespace('shoogl.scene.default_shaders')

DefaultShaders.vertex =
  _default: "basic_projection"

  basic_projection:
    description: 'Basic vertex projection with varying normal'
    code: '''
    varying vec3 vNormal;
    varying vec3 vViewPosition;

    void main() {
      vec3 transformedNormal = normalMatrix * normal;
      vNormal = normalize(transformedNormal);

      vec4 modelViewPosition;
      modelViewPosition = modelViewMatrix * vec4( position, 1.0 );
      vViewPosition = -modelViewPosition.xyz;

      gl_Position = projectionMatrix * modelViewPosition;
    }

    '''

DefaultShaders.fragment =
  _default: 'basic_lighting'

  basic_lighting:
    description: 'Simple shader which uses the position of 1 directional light to roughly shade the model'
    code: '''
    uniform vec3 lightWorldPosition;
    varying vec3 vNormal;
    varying vec3 vViewPosition;

    void main() {
      gl_FragColor = vec4(vec3(0.9), 1.0);

      // Simplistic lighting, based around the phong code
      // in three.js, but without the fancy bits
      vec4 lightPosition = viewMatrix * vec4( lightWorldPosition, 1.0 );
      vec3 lightVector = lightPosition.xyz + vViewPosition;
      lightVector = normalize( lightVector );

      float lightIntensity = max(dot( normalize(vNormal), lightVector ), 0.2);

      gl_FragColor.xyz = gl_FragColor.xyz * lightIntensity;
    }

    '''

  basic_cartoon:
    description: 'Basic cartoon style shader'
    code: '''
    uniform vec3 lightWorldPosition;
    varying vec3 vNormal;
    varying vec3 vViewPosition;

    // If enabled performs a rubbish cell shade effect
    #define TOONIFY 1

    // If enabled retains maximum intensity highlights
    // reducing the rest to 2 tone
    #define TOONIFY_2TONE_WITH_HIGHLIGHTS 1

    #if TOONIFY_2TONE_WITH_HIGHLIGHTS
    // If retaining highlights, we want to have
    // more shades to pick the highlight from. The
    // larger the number, the finer the highlights.
    #define TOONIFIY_SHADES 32.0
    #else
    // If not showing highlights, sets the
    // number of levels the colour bands used. The
    // larger the number, the more detail is retained
    #define TOONIFIY_SHADES 3.0
    #endif // TOONIFY_2TONE_WITH_HIGHLIGHTS

    void main() {
      // Simplistic lighting, based around the phong code
      // in three.js, but without the fancy bits
      vec4 lightPosition = viewMatrix * vec4( lightWorldPosition, 1.0 );
      vec3 lightVector = lightPosition.xyz + vViewPosition;
      lightVector = normalize( lightVector );

      float lightIntensity = dot( normalize(vNormal), lightVector );

    #if TOONIFY
      // Quantize
      float levels = TOONIFIY_SHADES;
      lightIntensity *= levels;
      lightIntensity = floor(lightIntensity);

    #if TOONIFY_2TONE_WITH_HIGHLIGHTS
      if ( lightIntensity < levels / 2.0 ) {
        lightIntensity = levels / 6.0;
      } else if ( lightIntensity < levels - 1.0 ) {
        lightIntensity = levels / 2.0 +  levels / 8.0;
      }
    #endif // TOONIFY_2TONE_WITH_HIGHLIGHTS

      lightIntensity /= levels - 0.5;
    #endif // TOONIFY

      vec3 color =  vec3(0.0, 1.0, 0.1);
      gl_FragColor = vec4(lightIntensity * color, 1.0);
    }

    '''

  normal_shader:
    description: 'Shader which colors the fragment based on the normal.'
    code: '''
    varying vec3 vNormal;

    void main() {
      gl_FragColor = vec4(vec3(normalize(vNormal)), 1.0);
    }

    '''
