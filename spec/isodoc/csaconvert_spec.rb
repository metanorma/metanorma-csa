# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::Csa do
  it "processes default metadata" do
    csdc = IsoDoc::Csa::HtmlConvert.new({})
    docxml, _filename, _dir = csdc.convert_init(<<~INPUT, "test", true)
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
        <flavor>csa</flavor>
        <editorialgroup>
          <committee type="A">TC</committee>
        </editorialgroup>
        </ext>
      </bibdata>
      <sections/>
      </csa-standard>
    INPUT

    expect(metadata(csdc.info(docxml, nil)))
      .to be_equivalent_to(
        {:accesseddate=>"XXX",
        :adapteddate=>"XXX",
        :agency=>"Ribose",
        :announceddate=>"XXX",
        :authors=>["Fred Nerk", "Julius Caesar"],
        :authors_affiliations=>{""=>["Fred Nerk", "Julius Caesar"]},
        :circulateddate=>"XXX",
        :confirmeddate=>"XXX",
        :copieddate=>"XXX",
        :correcteddate=>"XXX",
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
        :metadata_extensions=>{"doctype"=>"standard", "flavor"=>"csa", "editorialgroup"=>{"committee_type"=>"A", "committee"=>"TC"}},
        :obsoleteddate=>"XXX",
        :publisheddate=>"XXX",
        :publisher=>"Ribose",
        :receiveddate=>"XXX",
        :revdate=>"2000-01-01",
        :revdate_monthyear=>"January 2000",
        :roles_authors_affiliations=>{"editor"=>{""=>["Julius Caesar"]}, "full-author"=>{""=>["Fred Nerk"]}},
        :script=>"Latn",
        :stable_untildate=>"XXX",
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
      )
  end

  it "processes section names" do
    input = <<~INPUT
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
         <preferred><expression><name>Term2</name></expression></preferred>
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
    output = <<~OUTPUT
       <csa-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword obligation="informative" displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="3">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2">
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                </clause>
             </introduction>
          </preface>
          <sections>
             <clause id="D" obligation="normative" displayorder="7">
                <title id="_">Scope</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="D">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Scope</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="D">4</semx>
                </fmt-xref-label>
                <p id="E">Text</p>
             </clause>
             <clause id="H" obligation="normative" displayorder="5">
                <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="H">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="H">2</semx>
                </fmt-xref-label>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Normal Terms</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="H">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="I">1</semx>
                   </fmt-xref-label>
                   <term id="J">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="H">2</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="I">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="J">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Clause</span>
                         <semx element="autonum" source="H">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="J">1</semx>
                      </fmt-xref-label>
                                     <preferred id="_">
                  <expression>
                     <name>Term2</name>
                  </expression>
               </preferred>
               <fmt-preferred>
                  <p>
                     <semx element="preferred" source="_">
                        <strong>Term2</strong>
                     </semx>
                  </p>
               </fmt-preferred>
                   </term>
                </terms>
                <definitions id="K">
                   <title id="_">Symbols</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="K">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Symbols</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="H">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="K">2</semx>
                   </fmt-xref-label>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="6">
                <title id="_">Symbols</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Symbols</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="L">3</semx>
                </fmt-xref-label>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="8">
                <title id="_">Clause 4</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 4</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="M">5</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="N">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="O">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Clause 4.2</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" obligation="informative" normative="true" displayorder="4">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="R">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="R">1</semx>
                </fmt-xref-label>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title>
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Appendix</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(normative)</span>
                <span class="fmt-caption-delim">
                   <br/>
                </span>
                <semx element="title" source="_">
                   <strong>Annex</strong>
                </semx>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Appendix</span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
             <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
                <title id="_">Annex A.1</title>
                <fmt-title depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Annex A.1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="P">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q">1</semx>
                </fmt-xref-label>
                <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                   <title id="_">Annex A.1a</title>
                   <fmt-title depth="3">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="P">A</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q1">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Annex A.1a</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Appendix</span>
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q1">1</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="10">
                <title id="_">Bibliography</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="T" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title depth="2">
                      <semx element="title" source="_">Bibliography Subsection</semx>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </csa-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Csa::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "injects JS into blank html" do
    FileUtils.rm_f "test.html"
    input = <<~INPUT
      <csa-standard xmlns="https://open.ribose.com/standards/csa">
      <preface><foreword>
      <pre>ABC</pre>
      </foreword></preface>
      </csa-standard>
    INPUT
    IsoDoc::Csa::HtmlConvert.new({}).convert("test", input, false)
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(/jquery\.min\.js/)
    expect(html).to match(/Lato/)
  end
end
