require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/csand/converter"
require_relative "isodoc/csand/html_convert"
require_relative "isodoc/csand/pdf_convert"
require_relative "isodoc/csand/word_convert"
require_relative "metanorma/csand/version"

if defined? Metanorma
  require_relative "metanorma/csand"
  Metanorma::Registry.instance.register(Metanorma::Csand::Processor)
end
