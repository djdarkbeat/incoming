Gem::Specification.new do |s|
  # The following lines are updated automatically by `rake gemspec`
  s.name              = 'incoming'
  s.version           = '0.1.6'
  s.date              = '2013-12-27'

  s.summary     = 'Incoming! helps you receive email in your Rack apps.'
  s.description = 'Incoming! standardizes various mail parse apis, making it a snap to receive emails through HTTP post hooks.'

  s.authors     = ['Joshua Wood']
  s.email       = ['josh@honeybadger.io']
  s.homepage    = 'https://github.com/honeybadger-io/incoming'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.require_paths = %w[lib]

  s.executables << 'http_post'

  s.add_dependency 'rack'
  s.add_dependency 'mail',          '~> 2.4'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
