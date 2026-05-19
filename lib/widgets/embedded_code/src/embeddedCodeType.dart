enum EmbeddedCodeType {
  facebook,
  instagram,
  twitter,
  tiktok,
  dcard,
  googleForms,
  googleMap,
  youtube,
  googleDocs,
  googleSpreadsheets,
}

Map<String, EmbeddedCodeType> embeddedCodeTypeMap = {
  'www.facebook.com/plugins': EmbeddedCodeType.facebook,
  'instagram-media': EmbeddedCodeType.instagram,
  'twitter-tweet': EmbeddedCodeType.twitter,
  'class="tiktok-embed"': EmbeddedCodeType.tiktok,
  'embed.dcard.tw/v1/posts': EmbeddedCodeType.dcard,
  'docs.google.com/forms': EmbeddedCodeType.googleForms,
  'maps.google.com/maps': EmbeddedCodeType.googleMap,
  'www.youtube.com/embed': EmbeddedCodeType.youtube,
  'docs.google.com/document': EmbeddedCodeType.googleDocs,
  'docs.google.com/spreadsheets': EmbeddedCodeType.googleSpreadsheets,
};

class EmbeddedCode {
  static EmbeddedCodeType? findEmbeddedCodeType(String embeddedCode) {
    for (String key in embeddedCodeTypeMap.keys) {
      if (embeddedCode.contains(key)) {
        return embeddedCodeTypeMap[key];
      }
    }

    return null;
  }

  static RegExp? getLaunchUrlRegExpByType(EmbeddedCodeType? type) {
    switch (type) {
      case EmbeddedCodeType.facebook:
        // username refer to https://www.facebook.com/help/105399436216001
        // facebook url ex.
        // https://www.facebook.com/ facebookapp              / posts                                / 10160138384851729
        // https://www.facebook.com/ 563994370665617          / videos                               / 397668314698045
        // https://www.facebook.com/ DonDonDonkiTW            / photos           /a.3857266087638216 / 3902755526422605
        // https://www.facebook.com/ permalink.php?story_fbid = 229021587215556  &id                 = 11239244970
        return RegExp(
          r'src="https:\/\/www\.facebook\.com\/plugins\/(?:post|video)\.php\?(?:.*)href=(https?(?:%3A%2F%2F|\:\/\/)www\.facebook\.com(?:%2F|\/)(?:permalink\.php(?:%3F|\?)story_fbid|[a-zA-Z0-9.]+)(?:%2F|\/|=|%3D)(?:posts|videos|photos|[0-9]+)(?:%2F[a-z].[0-9]+|\/[a-z].[0-9]+|\&id|%26id)?(?:%2F|\/|=|%3D)[0-9]+)',
          caseSensitive: false,
        );
      case EmbeddedCodeType.instagram:
        return RegExp(
          r'permalink="(https:\/\/www\.instagram\.com\/p\/\w+\/)',
          caseSensitive: false,
        );
      case EmbeddedCodeType.twitter:
        return RegExp(
          r'(https?:\/\/twitter\.com\/\w{1,15}\/status\/\d+)',
          caseSensitive: false,
        );
      case EmbeddedCodeType.tiktok:
        return RegExp(
          r'cite="(https:\/\/www.tiktok.com\/.*)" data-video-id="',
          caseSensitive: false,
        );
      case EmbeddedCodeType.dcard:
        return RegExp(
          r'(https:\/\/embed.dcard.tw\/v1\/posts\/[0-9]+)',
          caseSensitive: false,
        );
      case EmbeddedCodeType.googleForms:
        // <iframe src="https://docs.google.com/forms/d/e/1FAIpQLSeI8_vYyaJgM7SJM4Y9AWfLq-tglWZh6yt7bEXEOJr_L-hV1A/viewform?formkey=dGx0b1ZrTnoyZDgtYXItMWVBdVlQQWc6MQ/viewform?embedded=true" width="640" height="1098" frameborder="0" marginheight="0" marginwidth="0">載入中…</iframe>
        return RegExp(
          r'src="(https://docs.google.com/forms/d/e/.*)/viewform?embedded=true',
          caseSensitive: false,
        );
      case EmbeddedCodeType.googleMap:
        return null;
      case EmbeddedCodeType.youtube:
        return null;
      case EmbeddedCodeType.googleDocs:
        return RegExp(
          r'src="(https://docs.google.com/document/d/e/.*)/viewform?embedded=true',
          caseSensitive: false,
        );
      case EmbeddedCodeType.googleSpreadsheets:
        return RegExp(
          r'src="(https://docs.google.com/spreadsheets/d/e/.*)/',
          caseSensitive: false,
        );
      default:
        return null;
    }
  }
}
