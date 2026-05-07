from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
from xml.sax.saxutils import escape
from zipfile import ZIP_DEFLATED, ZipFile


SLIDE_WIDTH = 9144000
SLIDE_HEIGHT = 5143500


def emu(inches: float) -> int:
    return int(inches * 914400)


def bullet_paragraph(text: str, level: int = 0, font_size: int = 22) -> str:
    indent = 228600 * (level + 1)
    mar_l = 228600 * (level + 1)
    return f"""
    <a:p>
      <a:pPr lvl="{level}" marL="{mar_l}" indent="-{indent}">
        <a:buChar char="•"/>
      </a:pPr>
      <a:r>
        <a:rPr lang="zh-TW" sz="{font_size * 100}"/>
        <a:t>{escape(text)}</a:t>
      </a:r>
    </a:p>
    """


def body_paragraph(text: str, font_size: int = 22, bold: bool = False) -> str:
    bold_attr = ' b="1"' if bold else ""
    return f"""
    <a:p>
      <a:r>
        <a:rPr lang="zh-TW" sz="{font_size * 100}"{bold_attr}/>
        <a:t>{escape(text)}</a:t>
      </a:r>
    </a:p>
    """


def text_box(shape_id: int, name: str, x: int, y: int, cx: int, cy: int, paragraphs: str) -> str:
    return f"""
    <p:sp>
      <p:nvSpPr>
        <p:cNvPr id="{shape_id}" name="{escape(name)}"/>
        <p:cNvSpPr txBox="1"/>
        <p:nvPr/>
      </p:nvSpPr>
      <p:spPr>
        <a:xfrm>
          <a:off x="{x}" y="{y}"/>
          <a:ext cx="{cx}" cy="{cy}"/>
        </a:xfrm>
        <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
        <a:noFill/>
        <a:ln><a:noFill/></a:ln>
      </p:spPr>
      <p:txBody>
        <a:bodyPr wrap="square"/>
        <a:lstStyle/>
        {paragraphs}
      </p:txBody>
    </p:sp>
    """


def title_box(shape_id: int, title: str) -> str:
    paragraphs = body_paragraph(title, font_size=28, bold=True)
    return text_box(shape_id, "Title", emu(0.6), emu(0.3), emu(8.8), emu(0.8), paragraphs)


def slide_xml(title: str, body_paragraphs: list[str]) -> str:
    shapes = [
        title_box(2, title),
        text_box(3, "Content", emu(0.8), emu(1.2), emu(8.5), emu(4.0), "".join(body_paragraphs)),
    ]
    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
       xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
       xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld>
    <p:spTree>
      <p:nvGrpSpPr>
        <p:cNvPr id="1" name=""/>
        <p:cNvGrpSpPr/>
        <p:nvPr/>
      </p:nvGrpSpPr>
      <p:grpSpPr>
        <a:xfrm>
          <a:off x="0" y="0"/>
          <a:ext cx="0" cy="0"/>
          <a:chOff x="0" y="0"/>
          <a:chExt cx="0" cy="0"/>
        </a:xfrm>
      </p:grpSpPr>
      {''.join(shapes)}
    </p:spTree>
  </p:cSld>
  <p:clrMapOvr>
    <a:masterClrMapping/>
  </p:clrMapOvr>
</p:sld>
"""


def make_presentation(out_path: Path) -> None:
    slides = [
        (
            "mnews 專案架構分析與統一方案",
            [
                body_paragraph("內容涵蓋：現況架構流程圖、目前專案問題、統一架構建議", 24),
                body_paragraph("結論：不建議繼續混用 Bloc 與 GetX，建議逐步收斂到 GetX", 22),
                body_paragraph("專案位置：/Users/mac/Desktop/mnewsapp", 18),
            ],
        ),
        (
            "目前專案架構流程圖",
            [
                body_paragraph("入口流程", 24, True),
                bullet_paragraph("main_dev.dart / main_prod.dart", 0),
                bullet_paragraph("Environment / Firebase / Ads / Comscore 初始化", 1),
                bullet_paragraph("MNewsApp -> GetMaterialApp -> HomeBinding", 1),
                bullet_paragraph("ConfigBloc -> InitialApp -> Remote Config / Push / Upgrade", 1),
                bullet_paragraph("HomePage -> Section 切換 -> News / Live / Video / Show / Topic", 1),
                body_paragraph("資料流程", 24, True),
                bullet_paragraph("UI(Page/Widget) -> Bloc/Cubit 或 GetX Controller", 0),
                bullet_paragraph("Service -> ApiBaseHelper / GraphQLClient", 1),
                bullet_paragraph("REST API / GraphQL API / Firebase -> Model -> UI", 1),
            ],
        ),
        (
            "專案目錄與責任分工",
            [
                bullet_paragraph("lib/pages: 功能頁面，依新聞、影音、節目、直播等業務模組切分"),
                bullet_paragraph("lib/widgets: 共用 UI 元件，文章內文播放與顯示元件特別多"),
                bullet_paragraph("lib/blocs: 主要畫面狀態管理，包含 config、category、search、list"),
                bullet_paragraph("lib/controller 與 pages/*_controller.dart: GetX controller 與局部頁面控制"),
                bullet_paragraph("lib/services: REST / GraphQL / Firebase 整合與商業邏輯"),
                bullet_paragraph("lib/models: API model 與資料結構"),
                bullet_paragraph("lib/helpers / lib/configs / lib/core: 環境、常數、工具、錯誤處理"),
            ],
        ),
        (
            "目前專案的主要問題",
            [
                bullet_paragraph("架構混用：Bloc/Cubit 與 GetX 同時存在，狀態來源不一致"),
                bullet_paragraph("生命週期分散：有的靠 BlocProvider，有的靠 Get.put/Get.delete 手動管理"),
                bullet_paragraph("首頁 shell 過度承擔控制責任，HomePage 直接建立與刪除 controller"),
                bullet_paragraph("services 邊界偏鬆，資料存取與業務 fallback 邏輯耦合很深"),
                bullet_paragraph("ApiBaseHelper 用固定 key 驗證 response，對 API 格式耦合高"),
                bullet_paragraph("測試不足，目前 test/widget_test.dart 仍是預設範例，無法保護重構"),
            ],
        ),
        (
            "統一架構建議",
            [
                body_paragraph("建議統一到 GetX，而不是回頭統一到 Bloc", 24, True),
                bullet_paragraph("原因 1：專案入口已經是 GetMaterialApp，GetX 已是既有基礎設施"),
                bullet_paragraph("原因 2：DI 與部分核心頁面 controller 已經採用 GetX"),
                bullet_paragraph("原因 3：改成 Bloc-only 需要回收既有 GetX 導航、Binding、controller"),
                bullet_paragraph("目標架構：UI -> GetX Controller -> Service -> API/Provider"),
                bullet_paragraph("原則：不再新增 Bloc/Cubit，新功能與重構後模組全部走 GetX"),
            ],
        ),
        (
            "修改策略與落地建議",
            [
                bullet_paragraph("第一階段：先改 Search / Tag / ProgramList / Contact 等低風險模組"),
                bullet_paragraph("第二階段：整合 News / Video / Show / Topic / Live 的多個 Bloc"),
                bullet_paragraph("第三階段：把 SectionCubit 收斂為 AppShellController"),
                bullet_paragraph("第四階段：把 ConfigBloc 收斂為 AppInitController"),
                bullet_paragraph("services、models、helpers 先保留，優先只改狀態管理層"),
                bullet_paragraph("新增規範：Binding 管 DI、Controller 管狀態、Page 只負責 UI"),
                bullet_paragraph("重構前先補 smoke test，避免首頁、啟動流程與文章頁回歸"),
            ],
        ),
    ]

    now = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")

    with ZipFile(out_path, "w", ZIP_DEFLATED) as zf:
        zf.writestr(
            "[Content_Types].xml",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>
  <Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>
  <Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
  <Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
  <Override PartName="/ppt/presProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presProps+xml"/>
  <Override PartName="/ppt/viewProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.viewProps+xml"/>
  <Override PartName="/ppt/tableStyles.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.tableStyles+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
  """
            + "".join(
                f'  <Override PartName="/ppt/slides/slide{i}.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>\n'
                for i in range(1, len(slides) + 1)
            )
            + "</Types>\n",
        )
        zf.writestr(
            "_rels/.rels",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
""",
        )
        zf.writestr(
            "docProps/core.xml",
            f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
                   xmlns:dc="http://purl.org/dc/elements/1.1/"
                   xmlns:dcterms="http://purl.org/dc/terms/"
                   xmlns:dcmitype="http://purl.org/dc/dcmitype/"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>mnews architecture analysis</dc:title>
  <dc:creator>OpenAI Codex</dc:creator>
  <cp:lastModifiedBy>OpenAI Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">{now}</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">{now}</dcterms:modified>
</cp:coreProperties>
""",
        )
        zf.writestr(
            "docProps/app.xml",
            f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
            xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Microsoft Office PowerPoint</Application>
  <Slides>{len(slides)}</Slides>
  <Notes>0</Notes>
  <HiddenSlides>0</HiddenSlides>
  <MMClips>0</MMClips>
  <ScaleCrop>false</ScaleCrop>
  <HeadingPairs>
    <vt:vector size="2" baseType="variant">
      <vt:variant><vt:lpstr>Slides</vt:lpstr></vt:variant>
      <vt:variant><vt:i4>{len(slides)}</vt:i4></vt:variant>
    </vt:vector>
  </HeadingPairs>
  <TitlesOfParts>
    <vt:vector size="{len(slides)}" baseType="lpstr">
      {''.join(f'<vt:lpstr>{escape(title)}</vt:lpstr>' for title, _ in slides)}
    </vt:vector>
  </TitlesOfParts>
  <Company>OpenAI</Company>
  <LinksUpToDate>false</LinksUpToDate>
  <SharedDoc>false</SharedDoc>
  <HyperlinksChanged>false</HyperlinksChanged>
  <AppVersion>16.0000</AppVersion>
</Properties>
""",
        )
        zf.writestr(
            "ppt/presentation.xml",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentation xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
                saveSubsetFonts="1" autoCompressPictures="0">
  <p:sldMasterIdLst>
    <p:sldMasterId id="2147483648" r:id="rId1"/>
  </p:sldMasterIdLst>
  <p:sldIdLst>
"""
            + "".join(
                f'    <p:sldId id="{255 + i}" r:id="rId{i + 1}"/>\n' for i in range(1, len(slides) + 1)
            )
            + f"""  </p:sldIdLst>
  <p:sldSz cx="{SLIDE_WIDTH}" cy="{SLIDE_HEIGHT}"/>
  <p:notesSz cx="6858000" cy="9144000"/>
  <p:defaultTextStyle/>
</p:presentation>
""",
        )
        zf.writestr(
            "ppt/_rels/presentation.xml.rels",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
"""
            + "".join(
                f'  <Relationship Id="rId{i + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide{i}.xml"/>\n'
                for i in range(1, len(slides) + 1)
            )
            + """  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="slideMasters/slideMaster1.xml"/>
  <Relationship Id="rId100" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/presProps" Target="presProps.xml"/>
  <Relationship Id="rId101" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/viewProps" Target="viewProps.xml"/>
  <Relationship Id="rId102" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/tableStyles" Target="tableStyles.xml"/>
</Relationships>
""",
        )
        zf.writestr(
            "ppt/slideMasters/slideMaster1.xml",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sldMaster xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
             xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
             xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld>
    <p:bg>
      <p:bgPr>
        <a:solidFill><a:schemeClr val="bg1"/></a:solidFill>
      </p:bgPr>
    </p:bg>
    <p:spTree>
      <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
      <p:grpSpPr>
        <a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm>
      </p:grpSpPr>
    </p:spTree>
  </p:cSld>
  <p:clrMap bg1="lt1" tx1="dk1" bg2="lt2" tx2="dk2" accent1="accent1" accent2="accent2" accent3="accent3" accent4="accent4" accent5="accent5" accent6="accent6" hlink="hlink" folHlink="folHlink"/>
  <p:sldLayoutIdLst>
    <p:sldLayoutId id="1" r:id="rId1"/>
  </p:sldLayoutIdLst>
  <p:txStyles>
    <p:titleStyle/>
    <p:bodyStyle/>
    <p:otherStyle/>
  </p:txStyles>
</p:sldMaster>
""",
        )
        zf.writestr(
            "ppt/slideMasters/_rels/slideMaster1.xml.rels",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="../theme/theme1.xml"/>
</Relationships>
""",
        )
        zf.writestr(
            "ppt/slideLayouts/slideLayout1.xml",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sldLayout xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
             xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
             xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
             type="blank" preserve="1">
  <p:cSld name="Blank">
    <p:spTree>
      <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
      <p:grpSpPr>
        <a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm>
      </p:grpSpPr>
    </p:spTree>
  </p:cSld>
  <p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>
</p:sldLayout>
""",
        )
        zf.writestr(
            "ppt/slideLayouts/_rels/slideLayout1.xml.rels",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="../slideMasters/slideMaster1.xml"/>
</Relationships>
""",
        )
        zf.writestr(
            "ppt/theme/theme1.xml",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Office Theme">
  <a:themeElements>
    <a:clrScheme name="Office">
      <a:dk1><a:sysClr val="windowText" lastClr="000000"/></a:dk1>
      <a:lt1><a:sysClr val="window" lastClr="FFFFFF"/></a:lt1>
      <a:dk2><a:srgbClr val="1F497D"/></a:dk2>
      <a:lt2><a:srgbClr val="EEECE1"/></a:lt2>
      <a:accent1><a:srgbClr val="4F81BD"/></a:accent1>
      <a:accent2><a:srgbClr val="C0504D"/></a:accent2>
      <a:accent3><a:srgbClr val="9BBB59"/></a:accent3>
      <a:accent4><a:srgbClr val="8064A2"/></a:accent4>
      <a:accent5><a:srgbClr val="4BACC6"/></a:accent5>
      <a:accent6><a:srgbClr val="F79646"/></a:accent6>
      <a:hlink><a:srgbClr val="0000FF"/></a:hlink>
      <a:folHlink><a:srgbClr val="800080"/></a:folHlink>
    </a:clrScheme>
    <a:fontScheme name="Office">
      <a:majorFont><a:latin typeface="Arial"/><a:ea typeface="Arial"/><a:cs typeface="Arial"/></a:majorFont>
      <a:minorFont><a:latin typeface="Arial"/><a:ea typeface="Arial"/><a:cs typeface="Arial"/></a:minorFont>
    </a:fontScheme>
    <a:fmtScheme name="Office">
      <a:fillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:fillStyleLst>
      <a:lnStyleLst><a:ln w="9525" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln></a:lnStyleLst>
      <a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst>
      <a:bgFillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:bgFillStyleLst>
    </a:fmtScheme>
  </a:themeElements>
  <a:objectDefaults/>
  <a:extraClrSchemeLst/>
</a:theme>
""",
        )
        zf.writestr(
            "ppt/presProps.xml",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentationPr xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                  xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:extLst/>
</p:presentationPr>
""",
        )
        zf.writestr(
            "ppt/viewProps.xml",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:viewPr xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
          xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
          xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:normalViewPr/>
  <p:slideViewPr/>
  <p:outlineViewPr/>
  <p:notesTextViewPr/>
  <p:gridSpacing cx="72008" cy="72008"/>
</p:viewPr>
""",
        )
        zf.writestr(
            "ppt/tableStyles.xml",
            """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:tblStyleLst xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" def="TableStyleMedium2"/>
""",
        )

        for idx, (title, paragraphs) in enumerate(slides, start=1):
            zf.writestr(f"ppt/slides/slide{idx}.xml", slide_xml(title, paragraphs))


if __name__ == "__main__":
    output = Path("mnews_architecture_review.pptx")
    make_presentation(output)
    print(output.resolve())
