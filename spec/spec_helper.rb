# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "metanorma-csa"
require "rspec/matchers"
require "equivalent-xml"
require "htmlentities"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def metadata(xml)
  xml.sort.to_h.delete_if do |_k, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

def htmlencode(xml)
  HTMLEntities.new.encode(xml, :hexadecimal).gsub(/&#x3e;/, ">").gsub(/&#xa;/, "\n")
    .gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<").gsub(/&#x26;/, "&").gsub(/&#x27;/, "'")
    .gsub(/\\u(....)/) do |_s|
    "&#x#{$1.downcase};"
  end
end

def strip_guid(xml)
  xml.gsub(%r{ id="_[^"]+"}, ' id="_"').gsub(%r{ target="_[^"]+"},
                                             ' target="_"')
end

def xmlpp(xml)
  c = HTMLEntities.new
  xml &&= xml.split(/(&\S+?;)/).map do |n|
    if /^&\S+?;$/.match?(n)
      c.encode(c.decode(n), :hexadecimal)
    else n
    end
  end.join
  xsl = <<~XSL
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
      <xsl:strip-space elements="*"/>
      <xsl:template match="/">
        <xsl:copy-of select="."/>
      </xsl:template>
    </xsl:stylesheet>
  XSL
  ret = Nokogiri::XSLT(xsl).transform(Nokogiri::XML(xml, &:noblanks))
    .to_xml(indent: 2, encoding: "UTF-8")
    .gsub(%r{<fetched>20[0-9-]+</fetched>}, "<fetched/>")
  HTMLEntities.new.decode(ret)
end

ASCIIDOC_BLANK_HDR = <<~"HDR"
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:

HDR

VALIDATING_BLANK_HDR = <<~"HDR"
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:

HDR

BOILERPLATE =
  HTMLEntities.new.decode(
    File.read(File.join(File.dirname(__FILE__), "..", "lib", "metanorma", "csa", "boilerplate.xml"), encoding: "utf-8")
    .gsub(/\{\{ docyear \}\}/, Date.today.year.to_s)
    .gsub(/<p>/, '<p id="_">')
    .gsub(/<p align="left">/, '<p align="left" id="_">')
    .gsub(/\{% if unpublished %\}.+?\{% endif %\}/m, "")
    .gsub(/\{% if ip_notice_received %\}\{% else %\}not\{% endif %\}/m, ""),
  )

LICENSE_BOILERPLATE = <<~BOILERPLATE
  <license-statement>
  <clause>
               <title>Warning for Drafts</title>
               <p id='_'>
                 This document is not a CSA Standard. It is distributed for review and
                 comment, and is subject to change without notice and may not be referred
                 to as a Standard. Recipients of this draft are invited to submit, with
                 their comments, notification of any relevant patent rights of which they
                 are aware and to provide supporting documentation.
               </p>
               </clause>
             </license-statement>
BOILERPLATE

BLANK_HDR = <<~"HDR"
         <?xml version="1.0" encoding="UTF-8"?>
         <csa-standard xmlns="https://www.metanorma.org/ns/csa" type="semantic" version="#{Metanorma::Csa::VERSION}">
         <bibdata type="standard">
          <title language="en" format="text/plain">Document title</title>
  <docidentifier type='CSA'>:#{Time.now.year}</docidentifier>
           <contributor>
             <role type="author"/>
             <organization>
               <name>Cloud Security Alliance</name>
               <abbreviation>CSA</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type="publisher"/>
             <organization>
               <name>Cloud Security Alliance</name>
               <abbreviation>CSA</abbreviation>
             </organization>
           </contributor>

           <language>en</language>
           <script>Latn</script>
          <status>
                  <stage>published</stage>
          </status>

           <copyright>
             <from>#{Time.new.year}</from>
             <owner>
               <organization>
                 <name>Cloud Security Alliance</name>
                 <abbreviation>CSA</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
                  <doctype>standard</doctype>
          </ext>
         </bibdata>
          #{BOILERPLATE}
HDR

HTML_HDR = <<~"HDR"
  <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
  <div class="title-section">
    <p>&#160;</p>
  </div>
  <br/>
  <div class="prefatory-section">
    <p>&#160;</p>
  </div>
  <br/>
  <div class="main-section">
HDR

def mock_pdf
  allow(::Mn2pdf).to receive(:convert) do |url, output, _c, _d|
    FileUtils.cp(url.gsub(/"/, ""), output.gsub(/"/, ""))
  end
end
