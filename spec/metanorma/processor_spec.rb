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
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
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
    expect(xmlpp(strip_guid(processor.input_to_isodoc(input, nil))))
      .to be_equivalent_to xmlpp(output)
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    processor.output(<<~"INPUT", "test.xml", "test.html", :html)
      <csa-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
        <terms id="H" obligation="normative"><title>1.<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
          <term id="J">
          <name>1.1.</name>
          <preferred>Term2</preferred>
        </term>
        </terms>
        </sections>
      </csa-standard>
    INPUT
    test_html = File.read("test.html", encoding: "utf-8")
      .gsub(/^.*<main/m, "<main")
      .gsub(%r{</main>.*}m, "</main>")
    expect(xmlpp(test_html)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
        <p class="zzSTDTitle1"></p>
        <div id="H"><h1 id="toc0">1.&#xA0; Terms, Definitions, Symbols and Abbreviated Terms</h1>
        <p class='Terms' style='text-align:left;' id='J'><strong>1.1.</strong>&#xA0;Term2</p>
        </div>
      </main>
    OUTPUT
  end
end
