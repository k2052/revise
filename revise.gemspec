   # -*- encoding: utf-8 -*-
   $:.push File.expand_path("../lib", __FILE__)
 
   Gem::Specification.new do |s|
    s.name        = "revise"
    s.version     = '0.1'
    s.platform    = Gem::Platform::RUBY
    s.authors     = ["Ken Erickson"]
    s.email       = "bookworm.productions@gmail.com"
    s.homepage    = "http://github.com/bookworm/revise"
    s.summary     = "Authentication for Padrino"
    s.description = "Authentication for Padrino"

    s.files         = `git ls-files -- lib/*`.split("\n")
    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    s.require_paths = ["lib"]

    s.add_dependency 'padrino'
    s.add_dependency 'padrino-responders'
    s.add_dependency 'padrino-fields'
    s.add_dependency 'padrino-flash'
    s.add_dependency 'activesupport'
    s.add_dependency 'orm_adapter'
   end