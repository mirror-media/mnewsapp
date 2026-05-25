class YoutubePlaylistInfo {
  final String name;
  final String youtubePlayListId;

  YoutubePlaylistInfo({
    required this.name,
    required this.youtubePlayListId,
  });

  /// 解析 CMS 後台 show 的 playList01 / playList02 欄位。
  ///
  /// 後台格式為「<playlist 連結>：<選單名稱>」,以「全形冒號」分隔。
  /// 名稱可省略;若省略則使用 [defaultName]。
  static YoutubePlaylistInfo? parseByShow(String? json, String defaultName) {
    if (json == null) {
      return null;
    }

    final String raw = json.trim();
    if (raw.isEmpty) {
      return null;
    }

    // 以全形冒號分隔「連結」與「名稱」。
    final List<String> info = raw.split('：');
    final String urlPart = info[0].trim();
    final String namePart = info.length < 2 ? '' : info[1].trim();
    final String name = namePart.isEmpty ? defaultName : namePart;

    final String youtubePlayListId = _extractPlaylistId(urlPart);

    // ===== 選單排查 log(排查完可整段移除)=====
    print('[選單排查] parseByShow raw="$json" '
        '=> id="$youtubePlayListId" name="$name"');

    return YoutubePlaylistInfo(
      name: name,
      youtubePlayListId: youtubePlayListId,
    );
  }

  /// 從 CMS 字串中取出乾淨的 YouTube playlist id。
  ///
  /// 支援下列情況,避免後台填法稍有差異就抓到壞掉的 id:
  ///   - https://www.youtube.com/playlist?list=PLxxxx
  ///   - https://www.youtube.com/playlist?list=PLxxxx&si=xxxx (分享連結帶參數)
  ///   - https://www.youtube.com/watch?v=xxx&list=PLxxxx
  ///   - 直接填純 playlist id (PLxxxx / UUxxxx ...)
  ///   - 前後夾帶空白 / 換行
  static String _extractPlaylistId(String input) {
    final String value = input.trim();
    if (value.isEmpty) {
      return '';
    }

    String? candidate;

    // 1. 優先用標準 URL 解析,直接讀 list 參數(會自動忽略 &si= 等其他參數)。
    final Uri? uri = Uri.tryParse(value);
    final String? listParam = uri?.queryParameters['list'];
    if (listParam != null && listParam.trim().isNotEmpty) {
      candidate = listParam.trim();
    } else {
      // 2. fallback:字串裡只要含 list= 就抓後面那段。
      const String marker = 'list=';
      final int markerIndex = value.indexOf(marker);
      if (markerIndex >= 0) {
        candidate = value.substring(markerIndex + marker.length);
      } else if (!value.contains('/') && !value.contains(' ')) {
        // 3. 沒有 URL 結構,當作後台直接填了純 id。
        candidate = value;
      }
    }

    if (candidate == null) {
      return '';
    }

    // playlist id 僅由英數字、底線、連字號組成;
    // 取開頭的合法片段,自動切掉 &si=、夾帶的名稱、空白、換行等雜訊。
    final RegExpMatch? match =
        RegExp(r'[A-Za-z0-9_-]+').firstMatch(candidate);
    return match?.group(0) ?? '';
  }
}
