require 'asciidoctor' unless defined? Asciidoctor::Converter
require_relative 'metanorma/csa/converter'
require_relative 'isodoc/csa/html_convert'
require_relative 'isodoc/csa/pdf_convert'
require_relative 'isodoc/csa/word_convert'
require_relative 'metanorma/csa/version'
require "metanorma"

if defined? Metanorma::Registry
  require_relative 'metanorma/csa'
  Metanorma::Registry.instance.register(Metanorma::Csa::Processor)
end
