$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'groupdocs/version'

Gem::Specification.new do |s|
  s.name        = 'groupdocs'
  s.version     = GroupDocs::VERSION
  s.authors     = 'Marketplace Team'
  s.email       = 'marketplace@groupdocs.com'
  s.homepage    = 'https://github.com/groupdocs/groupdocs-ruby'
  s.summary     = 'GroupDocs Cloud SDK for Ruby'
  s.description = 'With this SDK, you can seamlessly integrate GroupDocs’ document collaboration tools into your Ruby web or mobile application. The tools enable end users to view, securely share, collaboratively annotate, e-sign, assemble, convert and compare over 50 common document and image types (including PDF, Microsoft Office and CAD), all from within your Ruby application and without having to install any office suites or browser plugins. For more details, please visit: http://groupdocs.com/cloud/total-api'

  s.license = 'MIT'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_path = 'lib'

  s.add_runtime_dependency 'rest-client'   , '~> 1.6'
  s.add_runtime_dependency 'json'          , '~> 1.7'
  s.add_runtime_dependency 'mime-types'    , '~> 1.19'
  s.add_runtime_dependency 'activesupport' , '~> 4.2'

  s.add_development_dependency 'rspec'    , '~> 2.12'
  s.add_development_dependency 'fuubar'   , '~> 1.1'
  s.add_development_dependency 'rake'     , '~> 10.0'
  s.add_development_dependency 'simplecov', '~> 0.7'
  s.add_development_dependency 'yard'     , '~> 0.8'
  s.add_development_dependency 'webmock'  , '~> 1.9'
end
