require "spec_helper"
require "metanorma"
require "byebug"

RSpec.describe Metanorma::Csa::Processor do

  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Csa::Processor)
  processor = registry.find_processor(:csa)

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
        [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:rxl, "rxl"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(/^Metanorma::Csa /)
  end

  it "generates IsoDoc XML from a blank document" do
    expect(xmlpp(processor.input_to_isodoc(<<~"INPUT", nil))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</csa-standard>
    OUTPUT
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    processor.output(<<~"INPUT", "test.html", :html)
      <csa-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
        <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
          <term id="J">
          <preferred>Term2</preferred>
        </term>
        </terms>
        </sections>
      </csa-standard>
    INPUT
    test_html = File.read("test.html", encoding: "utf-8")
                    .gsub(%r{^.*<main}m, "<main")
                    .gsub(%r{</main>.*}m, "</main>")
    expect(xmlpp(test_html)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
        <p class="zzSTDTitle1"></p>
        <div id="H"><h1>1.&#xA0; Terms and definitions</h1>
        <h2 class="TermNum" id="J">1.1.&#xA0;<p class="Terms" style="text-align:left;">Term2</p></h2>
        </div>
      </main>
    OUTPUT
  end
end
