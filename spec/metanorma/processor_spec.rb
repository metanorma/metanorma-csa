# frozen_string_literal: true

require "spec_helper"
require "metanorma"

RSpec.describe Metanorma::Csa::Processor do
  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Csa::Processor)
  processor = registry.find_processor(:csa)

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~OUTPUT
      [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(/^Metanorma::Csa /)
  end

  it "generates IsoDoc XML from a blank document" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
    INPUT
    output = <<~OUTPUT
          #{BLANK_HDR}
      <sections/>
      </csa-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(processor.input_to_isodoc(input, nil))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    processor.output(<<~INPUT, "test.xml", "test.html", :html)
      <csa-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
        <terms id="H" obligation="normative" displayorder="1">
          <fmt-title>1.<tab/>Terms, Definitions, Symbols and Abbreviated Terms</fmt-title>
          <term id="J">
          <fmt-name>1.1.</fmt-name>
          <preferred>Term2</preferred>
        </term>
        </terms>
        </sections>
      </csa-standard>
    INPUT
    test_html = File.read("test.html", encoding: "utf-8")
      .gsub(/^.*<main/m, "<main")
      .gsub(%r{</main>.*}m, "</main>")
    expect(Xml::C14n.format(strip_guid(test_html))).to be_equivalent_to Xml::C14n.format(strip_guid(<<~OUTPUT))
      <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
        <div id="H"><h1 id="_">
             <a class="anchor" href="#H"/>
             <a class="header" href="#H">1.  Terms, Definitions, Symbols and Abbreviated Terms</a>
           </h1>
        <p class='Terms' style='text-align:left;' id='J'><strong>1.1.</strong>&#xa0;Term2</p>
        </div>
      </main>
    OUTPUT
  end
end
