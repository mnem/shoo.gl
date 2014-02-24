(function(){var n;n=namespace("shoogl.scene.default_shaders"),n.vertex={_default:"basic_projection",basic_projection:{description:"Basic vertex projection with varying normal",code:"varying vec3 vNormal;\nvarying vec3 vViewPosition;\n\nvoid main() {\n  vec3 transformedNormal = normalMatrix * normal;\n  vNormal = normalize(transformedNormal);\n\n  vec4 modelViewPosition;\n  modelViewPosition = modelViewMatrix * vec4( position, 1.0 );\n  vViewPosition = -modelViewPosition.xyz;\n\n  gl_Position = projectionMatrix * modelViewPosition;\n}\n"}},n.fragment={_default:"basic_lighting",basic_lighting:{description:"Simple shader which uses the position of 1 directional light to roughly shade the model",code:"uniform vec3 uSceneMainLightPosition;\nvarying vec3 vNormal;\nvarying vec3 vViewPosition;\n\nvoid main() {\n  gl_FragColor = vec4(vec3(0.9), 1.0);\n\n  // Simplistic lighting, based around the phong code\n  // in three.js, but without the fancy bits\n  vec4 lightPosition = viewMatrix * vec4( uSceneMainLightPosition, 1.0 );\n  vec3 lightVector = lightPosition.xyz + vViewPosition;\n  lightVector = normalize( lightVector );\n\n  float lightIntensity = max(dot( normalize(vNormal), lightVector ), 0.2);\n\n  gl_FragColor.xyz = gl_FragColor.xyz * lightIntensity;\n}\n"},basic_cartoon:{description:"Basic cartoon style shader",code:"uniform vec3 uSceneMainLightPosition;\nvarying vec3 vNormal;\nvarying vec3 vViewPosition;\n\n// If enabled performs a rubbish cell shade effect\n#define TOONIFY 1\n\n// If enabled retains maximum intensity highlights\n// reducing the rest to 2 tone\n#define TOONIFY_2TONE_WITH_HIGHLIGHTS 1\n\n#if TOONIFY_2TONE_WITH_HIGHLIGHTS\n// If retaining highlights, we want to have\n// more shades to pick the highlight from. The\n// larger the number, the finer the highlights.\n#define TOONIFIY_SHADES 32.0\n#else\n// If not showing highlights, sets the\n// number of levels the colour bands used. The\n// larger the number, the more detail is retained\n#define TOONIFIY_SHADES 3.0\n#endif // TOONIFY_2TONE_WITH_HIGHLIGHTS\n\nvoid main() {\n  // Simplistic lighting, based around the phong code\n  // in three.js, but without the fancy bits\n  vec4 lightPosition = viewMatrix * vec4( uSceneMainLightPosition, 1.0 );\n  vec3 lightVector = lightPosition.xyz + vViewPosition;\n  lightVector = normalize( lightVector );\n\n  float lightIntensity = dot( normalize(vNormal), lightVector );\n\n#if TOONIFY\n  // Quantize\n  float levels = TOONIFIY_SHADES;\n  lightIntensity *= levels;\n  lightIntensity = floor(lightIntensity);\n\n#if TOONIFY_2TONE_WITH_HIGHLIGHTS\n  if ( lightIntensity < levels / 2.0 ) {\n    lightIntensity = levels / 6.0;\n  } else if ( lightIntensity < levels - 1.0 ) {\n    lightIntensity = levels / 2.0 +  levels / 8.0;\n  }\n#endif // TOONIFY_2TONE_WITH_HIGHLIGHTS\n\n  lightIntensity /= levels - 0.5;\n#endif // TOONIFY\n\n  vec3 color =  vec3(0.0, 1.0, 0.1);\n  gl_FragColor = vec4(lightIntensity * color, 1.0);\n}\n"},normal_shader:{description:"Shader which colors the fragment based on the normal.",code:"varying vec3 vNormal;\n\nvoid main() {\n  gl_FragColor = vec4(vec3(normalize(vNormal)), 1.0);\n}\n"}}}).call(this);