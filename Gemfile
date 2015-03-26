source 'http://rubygems.org'

ruby '2.2.1'

# Core bits needed to run the thing
gem 'rack',          '~> 1.6'
gem 'rack-cors',     '~> 0.3'
gem 'grape',         '~> 0.11'
gem 'grape-entity',  '~> 0.4'
gem 'grape-swagger', '~> 0.10'
gem 'json',          '~> 1.8'
gem 'bcrypt'
gem 'hash-path'

# Integrations
gem 'elasticsearch', '~> 1.0'
gem 'mongoid',       '~> 4.0'
gem 'faraday',       '~> 0.9'
gem 'neo4j',         '~> 4.1'

# task runner
gem 'rake',          '~> 10.0.3'

group :development do
  gem 'guard',         '~> 2.10.5'
  gem 'guard-bundler', '~> 2.1.0'
  gem 'guard-rack',    '~> 2.0.0'
  gem 'guard-rspec',   '~> 4.5'
  gem 'rubocop'
  gem 'pry'
  gem 'pry-doc'
end

group :test do
  gem 'rspec',            '~> 3.2'
  gem 'rack-test',        '~> 0.6.2'
  # gem 'database_cleaner', '~> 1.2.0'
  # gem 'factory_girl',     '~> 4.4.0'
  gem 'faker',            '~> 1.4'
end

group :production do
  gem 'puma'
end
