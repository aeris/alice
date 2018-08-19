guard :rails do
	watch('Gemfile.lock')
	watch(%r{^(config|lib)/.*})
end

guard :livereload do
	watch(%r{app/views/.+\.(erb|haml|slim)$})
	watch(%r{app/helpers/.+\.rb})
	watch(%r{public/.+\.(css|js|html)})
	watch(%r{config/locales/.+\.yml})
	# Rails Assets Pipeline
	watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html|png|jpg|coffee|scss))).*}) { |m| "/assets/#{m[3]}" }
end
