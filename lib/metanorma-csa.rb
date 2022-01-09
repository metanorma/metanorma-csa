require 'asciidoctor' unless defined? Asciidoctor::Converter
require_relative 'metanorma/csa/converter'
require_relative 'isodoc/csa/html_convert'
require_relative 'isodoc/csa/pdf_convert'
require_relative 'isodoc/csa/word_convert'
require_relative 'metanorma/csa/version'

if defined? Metanorma
  require_relative 'metanorma/csa'
  Metanorma::Registry.instance.register(Metanorma::Csa::Processor)
end
