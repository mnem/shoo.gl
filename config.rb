###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

# Build-specific configuration
configure :build do
  sprockets.append_path File.join root, 'bower_components'

  activate :bourbon
  activate :minify_css
  activate :minify_javascript, :ignore => 'models/*'
  activate :minify_html
  activate :asset_hash, :ignore => 'models/*'
  activate :imageoptim
  activate :relative_assets
  activate :gzip
end

configure :development do
  sprockets.append_path File.join root, 'bower_components'

  set :debug_assets, true
  activate :livereload
  activate :bourbon
end

activate :deploy do |deploy|
  deploy.method = :git
  # Optional Settings
  # deploy.remote   = "custom-remote" # remote name or git url, default: origin
  # deploy.branch   = "custom-branch" # default: gh-pages
  # deploy.strategy = :submodule      # commit strategy: can be :force_push or :submodule, default: :force_push
end

ready do
  sprockets.append_path File.join root, 'bower_components'
end
