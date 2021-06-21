# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::Csa do
  it "processes default metadata" do
    csdc = IsoDoc::Csa::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
      <csa-standard xmlns="https://open.ribose.com/standards/csa">
      <bibdata type="standard">
        <title language="en" format="plain">Main Title</title>
        <docidentifier type="csa">1000(wd)</docidentifier>
        <docnumber>1000</docnumber>
        <edition>2</edition>
        <version>
        <revision-date>2000-01-01</revision-date>
        <draft>3.4</draft>
      </version>
        <contributor>
          <role type="author"/>
          <organization>
            <name>Ribose</name>
          </organization>
        </contributor>
           <contributor>
             <role type='author'>
               <description>full-author</description>
             </role>
             <person>
               <name>
                 <completename>Fred Nerk</completename>
               </name>
             </person>
           </contributor>
           <contributor>
             <role type='editor'>
               <description>contributor</description>
             </role>
             <person>
               <name>
                 <forename>Julius</forename>
                 <surname>Caesar</surname>
               </name>
             </person>
           </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>Ribose</name>
          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage>working-draft</stage>
        </status>
        <copyright>
          <from>2001</from>
          <owner>
            <organization>
              <name>Ribose</name>
            </organization>
          </owner>
        </copyright>
        <ext>
        <doctype>standard</doctype>
        <editorialgroup>
          <committee type="A">TC</committee>
        </editorialgroup>
        </ext>
      </bibdata>
      <sections/>
      </csa-standard>
    INPUT

    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s.gsub(/, :/, ",\n:"))).to be_equivalent_to (<<~OUTPUT)
      {:accesseddate=>"XXX",
      :agency=>"Ribose",
      :authors=>["Fred Nerk", "Julius Caesar"],
      :authors_affiliations=>{""=>["Fred Nerk", "Julius Caesar"]},
      :circulateddate=>"XXX",
      :confirmeddate=>"XXX",
      :copieddate=>"XXX",
      :createddate=>"XXX",
      :docnumber=>"1000(wd)",
      :docnumeric=>"1000",
      :doctitle=>"Main Title",
      :doctype=>"Standard",
      :doctype_display=>"Standard",
      :docyear=>"2001",
      :draft=>"3.4",
      :draftinfo=>" (draft 3.4, 2000-01-01)",
      :edition=>"2",
      :implementeddate=>"XXX",
      :issueddate=>"XXX",
      :lang=>"en",
      :metadata_extensions=>{"doctype"=>"standard", "editorialgroup"=>{"committee_type"=>"A", "committee"=>"TC"}},
      :obsoleteddate=>"XXX",
      :publisheddate=>"XXX",
      :publisher=>"Ribose",
      :receiveddate=>"XXX",
      :revdate=>"2000-01-01",
      :revdate_monthyear=>"January 2000",
      :roles_authors_affiliations=>{"editor"=>{""=>["Julius Caesar"]}, "full-author"=>{""=>["Fred Nerk"]}},
      :script=>"Latn",
      :stage=>"Working Draft",
      :stage_display=>"Working Draft",
      :stageabbr=>"wd",
      :tc=>"TC",
      :transmitteddate=>"XXX",
      :unchangeddate=>"XXX",
      :unpublished=>true,
      :updateddate=>"XXX",
      :vote_endeddate=>"XXX",
      :vote_starteddate=>"XXX"}
    OUTPUT
  end

  it "processes pre" do
    input = <<~"INPUT"
      <csa-standard xmlns="https://open.ribose.com/standards/csa">
      <preface><foreword>
      <pre>ABC</pre>
      </foreword></preface>
      </csa-standard>
    INPUT

    html = IsoDoc::Csa::HtmlConvert.new({}).convert("test", input, true)
      .gsub(/^.*<body/m, "<body")
      .gsub(%r{</body>.*}m, "</body>")
    expect(xmlpp(html)).to be_equivalent_to <<~"OUTPUT"
      #{HTML_HDR}
      <br/>
      <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <pre>ABC</pre>
      </div>
      <p class="zzSTDTitle1"/>
      </div>
      </body>
    OUTPUT
  end

  it "processes keyword" do
    input = <<~"INPUT"
      <csa-standard xmlns="https://open.ribose.com/standards/csa">
        <preface><foreword><keyword>ABC</keyword></foreword></preface>
      </csa-standard>
    INPUT

    html = IsoDoc::Csa::HtmlConvert.new({}).convert("test", input, true)
      .gsub(/^.*<body/m, "<body")
      .gsub(%r{</body>.*}m, "</body>")

    expect(xmlpp(html)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{HTML_HDR}
           <br/>
           <div>
             <h1 class="ForewordTitle">Foreword</h1>
             <span class="keyword">ABC</span>
           </div>
           <p class="zzSTDTitle1"/>
         </div>
       </body>
    OUTPUT
  end

  it "processes simple terms & definitions" do
    input = <<~"INPUT"
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

    presxml = <<~OUTPUT
          <csa-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <sections>
          <terms id='H' obligation='normative' displayorder="1">
            <title depth='1'>1.<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
            <term id='J'>
              <name>1.1.</name>
              <preferred>Term2</preferred>
            </term>
          </terms>
        </sections>
      </csa-standard>
    OUTPUT

    html = <<~OUTPUT
       #{HTML_HDR}
              <p class="zzSTDTitle1"/>
              <div id="H"><h1>1.&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
      <p class="TermNum" id="J">1.1.</p>
        <p class="Terms" style="text-align:left;">Term2</p>
      </div>
            </div>
          </body>
    OUTPUT
    expect(xmlpp(IsoDoc::Csa::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Csa::HtmlConvert.new({}).convert("test", presxml, true).gsub(/^.*<body/m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(html)
  end

  it "processes section names" do
    expect(xmlpp(IsoDoc::Csa::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <csa-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative">
         <title>Introduction</title>
         <clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative">
         <title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
       <definitions id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative">
         <title>Clause 4</title>
         <clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </csa-standard>
    INPUT
       <csa-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
       <preface>
       <foreword obligation="informative" displayorder="1">
          <title>Foreword</title>
          <p id="A">This is a preamble</p>
        </foreword>
         <introduction id="B" obligation="informative" displayorder="2">
          <title>Introduction</title>
          <clause id="C" inline-header="false" obligation="informative">
          <title depth="2">Introduction Subsection</title>
        </clause>
        </introduction></preface><sections>
        <clause id="D" obligation="normative" displayorder="6">
          <title depth="1">4.<tab/>Scope</title>
          <p id="E">Text</p>
        </clause>
     
        <clause id="H" obligation="normative" displayorder="4">
          <title depth="1">2.<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
          <terms id="I" obligation="normative">
          <title depth="2">2.1.<tab/>Normal Terms</title>
          <term id="J"><name>2.1.1.</name>
          <preferred>Term2</preferred>
        </term>
        </terms>
        <definitions id="K"><title>2.2.</title>
          <dl>
          <dt>Symbol</dt>
          <dd>Definition</dd>
          </dl>
        </definitions>
        </clause>
        <definitions id="L" displayorder="5"><title>3.</title>
          <dl>
          <dt>Symbol</dt>
          <dd>Definition</dd>
          </dl>
        </definitions>
        <clause id="M" inline-header="false" obligation="normative" displayorder="7">
          <title depth="1">5.<tab/>Clause 4</title>
          <clause id="N" inline-header="false" obligation="normative">
          <title depth="2">5.1.<tab/>Introduction</title>
        </clause>
        <clause id="O" inline-header="false" obligation="normative">
          <title depth="2">5.2.<tab/>Clause 4.2</title>
        </clause></clause>
     
        </sections><annex id="P" inline-header="false" obligation="normative" displayorder="8">
          <title><strong>Appendix A</strong><br/>(normative)<br/><strong>Annex</strong></title>
          <clause id="Q" inline-header="false" obligation="normative">
          <title depth="2">A.1.<tab/>Annex A.1</title>
          <clause id="Q1" inline-header="false" obligation="normative">
          <title depth="3">A.1.1.<tab/>Annex A.1a</title>
          </clause>
        </clause>
        </annex><bibliography><references id="R" obligation="informative" normative="true" displayorder="3">
          <title depth="1">1.<tab/>Normative References</title>
        </references><clause id="S" obligation="informative" displayorder="9">
          <title depth="1">Bibliography</title>
          <references id="T" obligation="informative" normative="false">
          <title depth="2">Bibliography Subsection</title>
        </references>
        </clause>
        </bibliography>
        </csa-standard>
    OUTPUT
  end

  it "injects JS into blank html" do
    FileUtils.rm_f "test.html"
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    html = Asciidoctor.convert(input, backend: :csa, header_footer: true)
    expect(xmlpp(strip_guid(html))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{BLANK_HDR}
      <sections/>
      </csa-standard>
    OUTPUT

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(/jquery\.min\.js/)
    expect(html).to match(/Lato/)
  end
end
