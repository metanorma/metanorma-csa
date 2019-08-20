lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metanorma/csand/version"

Gem::Specification.new do |spec|
  spec.name          = "metanorma-csand"
  spec.version       = Metanorma::Csand::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "metanorma-csand lets you write CSA Normal Documents (CSAND) in AsciiDoc."
  spec.description   = <<~DESCRIPTION
    metanorma-csand lets you write CSA Normal Documents (CSAND) in AsciiDoc syntax.

    This gem is in active development.

    Formerly known as asciidoctor-csand.
  DESCRIPTION

  spec.homepage      = "https://github.com/metanorma/metanorma-csand"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.add_dependency "asciidoctor", "~> 1.5.7"
  spec.add_dependency "asciimath"
  spec.add_dependency "htmlentities", "~> 4.3.4"
  spec.add_dependency "image_size"
  spec.add_dependency "mime-types"
  spec.add_dependency "nokogiri"
  spec.add_dependency "ruby-jing"
  spec.add_dependency "thread_safe"
  spec.add_dependency "uuidtools"

  spec.add_dependency "metanorma-standoc", "~> 1.3.0"
  spec.add_dependency "isodoc", "~> 1.0.0"

  spec.add_development_dependency "bundler", "~> 2.0.1"
  spec.add_development_dependency "byebug", "~> 9.1"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "= 0.54.0"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "metanorma", "~> 0.3.12"
end
