from pathlib import Path
from typing import Optional


BOX_W = 240
BOX_H = 56
RX = 10
FONT = 18
SMALL_FONT = 17


def center_bottom(nodes: dict, node_id: str):
    x, y, *_ = nodes[node_id]
    return x + BOX_W / 2, y + BOX_H


def center_top(nodes: dict, node_id: str):
    x, y, *_ = nodes[node_id]
    return x + BOX_W / 2, y


def center_left(nodes: dict, node_id: str):
    x, y, *_ = nodes[node_id]
    return x, y + BOX_H / 2


def center_right(nodes: dict, node_id: str):
    x, y, *_ = nodes[node_id]
    return x + BOX_W, y + BOX_H / 2


def edge_path(nodes: dict, src: str, dst: str) -> str:
    sx, sy, *_ = nodes[src]
    dx, dy, *_ = nodes[dst]

    if dy > sy + BOX_H + 10 and abs((sx + BOX_W / 2) - (dx + BOX_W / 2)) < 40:
        x1, y1 = center_bottom(nodes, src)
        x2, y2 = center_top(nodes, dst)
        mid = (y1 + y2) / 2
        return f"M{x1},{y1} L{x1},{mid} L{x2},{mid} L{x2},{y2}"
    if dx > sx + BOX_W:
        x1, y1 = center_right(nodes, src)
        x2, y2 = center_left(nodes, dst)
        mid = (x1 + x2) / 2
        return f"M{x1},{y1} L{mid},{y1} L{mid},{y2} L{x2},{y2}"
    if dx + BOX_W < sx:
        x1, y1 = center_left(nodes, src)
        x2, y2 = center_right(nodes, dst)
        mid = (x1 + x2) / 2
        return f"M{x1},{y1} L{mid},{y1} L{mid},{y2} L{x2},{y2}"
    x1, y1 = center_bottom(nodes, src)
    x2, y2 = center_top(nodes, dst)
    mid = (y1 + y2) / 2
    return f"M{x1},{y1} L{x1},{mid} L{x2},{mid} L{x2},{y2}"


def path_from_points(points: list[tuple[float, float]]) -> str:
    start = points[0]
    rest = " ".join(f"L{x},{y}" for x, y in points[1:])
    return f"M{start[0]},{start[1]} {rest}"


def render(
    title: str,
    nodes: dict,
    edges: list[tuple[str, str]],
    width: int,
    height: int,
    custom_paths: Optional[list[list[tuple[float, float]]]] = None,
):
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        "<defs>",
        '<marker id="arrow" markerWidth="10" markerHeight="10" refX="8" refY="5" orient="auto" markerUnits="strokeWidth">',
        '<path d="M 0 0 L 10 5 L 0 10 z" fill="#111111"/>',
        "</marker>",
        '<style>',
        'text { font-family: -apple-system, BlinkMacSystemFont, "PingFang TC", "Noto Sans CJK TC", sans-serif; fill: #111111; }',
        ".title { font-size: 30px; font-weight: 700; }",
        f'.label {{ font-size: {FONT}px; font-weight: 600; }}',
        f'.small {{ font-size: {SMALL_FONT}px; font-weight: 600; }}',
        "</style>",
        "</defs>",
        '<rect width="100%" height="100%" fill="#ffffff"/>',
        f'<text x="60" y="60" class="title">{title}</text>',
    ]

    for src, dst in edges:
        parts.append(
            f'<path d="{edge_path(nodes, src, dst)}" fill="none" stroke="#111111" stroke-width="2.4" marker-end="url(#arrow)"/>'
        )

    for points in custom_paths or []:
        parts.append(
            f'<path d="{path_from_points(points)}" fill="none" stroke="#111111" stroke-width="2.4" marker-end="url(#arrow)"/>'
        )

    for _, (x, y, label, color) in nodes.items():
        parts.append(
            f'<rect x="{x}" y="{y}" width="{BOX_W}" height="{BOX_H}" rx="{RX}" ry="{RX}" fill="#ffffff" stroke="#111111" stroke-width="2"/>'
        )
        lines = label.split("\n")
        line_y = y + 24 if len(lines) == 2 else y + 34
        for idx, line in enumerate(lines):
            klass = "small" if len(line) > 20 else "label"
            parts.append(
                f'<text x="{x + BOX_W/2}" y="{line_y + idx * 20}" text-anchor="middle" class="{klass}">{line}</text>'
            )

    parts.append("</svg>")
    return "\n".join(parts)


if __name__ == "__main__":
    out_dir = Path("assets/diagrams")
    out_dir.mkdir(parents=True, exist_ok=True)
    diagrams = {
        "high_level_architecture.svg": (
            "mnews 高階架構圖",
            {
                "A": (880, 40, "main_dev.dart /\nmain_prod.dart", "#FFFFFF"),
                "B": (880, 145, "Environment init\nFirebase / Ads / Comscore", "#FFFFFF"),
                "C": (880, 250, "MNewsApp", "#FFFFFF"),
                "D": (880, 355, "GetMaterialApp", "#FFFFFF"),
                "E": (500, 460, "HomeBinding\nGetX DI", "#FFFFFF"),
                "F": (880, 460, "ConfigBloc", "#FFFFFF"),
                "G": (880, 565, "InitialApp", "#FFFFFF"),
                "H": (880, 670, "Remote Config /\nPush / Upgrade Check", "#FFFFFF"),
                "I": (880, 775, "SectionCubit", "#FFFFFF"),
                "J": (880, 880, "HomePage", "#FFFFFF"),
                "K": (140, 1005, "Drawer /\nSection Switch", "#FFFFFF"),
                "L": (390, 1005, "NewsPage", "#FFFFFF"),
                "M": (640, 1005, "LivePage", "#FFFFFF"),
                "N": (890, 1005, "VideoPage", "#FFFFFF"),
                "O": (1140, 1005, "ShowPage", "#FFFFFF"),
                "P": (1390, 1005, "AnchorpersonPage", "#FFFFFF"),
                "Q": (1640, 1005, "OmbudsPage", "#FFFFFF"),
                "R": (1890, 1005, "ProgramListPage", "#FFFFFF"),
                "S": (2140, 1005, "TopicListPage", "#FFFFFF"),
                "T": (760, 1170, "Bloc / Cubit", "#FFFFFF"),
                "U": (1180, 1170, "GetX Controller\n+ Bloc", "#FFFFFF"),
                "V": (970, 1325, "Services", "#FFFFFF"),
                "W": (970, 1430, "ApiBaseHelper /\nGraphQLClient", "#FFFFFF"),
                "X": (970, 1535, "REST API /\nGraphQL API / Firebase", "#FFFFFF"),
                "Y": (1390, 1325, "Models", "#FFFFFF"),
            },
            [
                ("A", "B"), ("B", "C"), ("C", "D"), ("D", "F"), ("F", "G"),
                ("G", "H"), ("H", "I"), ("I", "J"), ("V", "W"), ("W", "X"),
                ("V", "Y"),
            ],
            2500,
            1760,
            [
                [(880, 383), (880, 420), (620, 420), (620, 488)],
                [(1000, 936), (1000, 970), (260, 970), (260, 1005)],
                [(1000, 936), (1000, 970), (510, 970), (510, 1005)],
                [(1000, 936), (1000, 970), (760, 970), (760, 1005)],
                [(1000, 936), (1000, 970), (1010, 970), (1010, 1005)],
                [(1000, 936), (1000, 970), (1260, 970), (1260, 1005)],
                [(1000, 936), (1000, 970), (1510, 970), (1510, 1005)],
                [(1000, 936), (1000, 970), (1760, 970), (1760, 1005)],
                [(1000, 936), (1000, 970), (2010, 970), (2010, 1005)],
                [(1000, 936), (1000, 970), (2260, 970), (2260, 1005)],
                [(510, 1061), (510, 1130), (880, 1130), (880, 1170)],
                [(760, 1061), (760, 1130), (880, 1130), (880, 1170)],
                [(1260, 1061), (1260, 1130), (880, 1130), (880, 1170)],
                [(2010, 1061), (2010, 1130), (880, 1130), (880, 1170)],
                [(2260, 1061), (2260, 1130), (880, 1130), (880, 1170)],
                [(1010, 1061), (1010, 1130), (1300, 1130), (1300, 1170)],
                [(1510, 1061), (1510, 1130), (1300, 1130), (1300, 1170)],
                [(1760, 1061), (1760, 1130), (1300, 1130), (1300, 1170)],
                [(880, 1226), (880, 1290), (1090, 1290), (1090, 1325)],
                [(1300, 1226), (1300, 1290), (1090, 1290), (1090, 1325)],
                [(1510, 1353), (1210, 1353), (1210, 1200), (1000, 1200)],
                [(1510, 1353), (1210, 1353), (1210, 1200), (1300, 1200)],
            ],
        ),
        "story_data_flow.svg": (
            "文章頁資料流",
            {
                "A": (120, 220, "StoryPage", "#FFFFFF"),
                "B": (470, 220, "StoryPageController\n(GetX)", "#FFFFFF"),
                "C": (860, 220, "StoryServices", "#FFFFFF"),
                "D": (1280, 110, "Internal GraphQL", "#FFFFFF"),
                "E": (1280, 330, "External API\nfallback", "#FFFFFF"),
                "F": (1700, 220, "Story Model", "#FFFFFF"),
            },
            [("A", "B"), ("B", "C"), ("C", "D"), ("C", "E"), ("D", "F"), ("E", "F"), ("F", "A")],
            2000,
            620,
            None,
        ),
        "directory_responsibility.svg": (
            "目錄職責圖",
            {
                "L": (920, 80, "lib/", "#FFFFFF"),
                "A": (120, 260, "main_dev.dart /\nmain_prod.dart\nApp 入口", "#FFFFFF"),
                "B": (520, 260, "mNewsApp.dart /\ninitialApp.dart\nApp shell 與啟動流程", "#FFFFFF"),
                "C": (920, 260, "pages/\n功能頁面", "#FFFFFF"),
                "D": (1320, 260, "widgets/\n共用 UI 元件", "#FFFFFF"),
                "E": (1720, 260, "blocs/\n主要狀態管理", "#FFFFFF"),
                "F": (120, 530, "controller/ +\npages/*_controller.dart\nGetX 控制器", "#FFFFFF"),
                "G": (620, 530, "services/\n資料存取與商業邏輯", "#FFFFFF"),
                "H": (1120, 530, "provider/\nGraphQL / API provider", "#FFFFFF"),
                "I": (1620, 530, "models/\n資料模型", "#FFFFFF"),
                "J": (420, 810, "helpers/\n工具、常數、錯誤、API 包裝", "#FFFFFF"),
                "K": (1020, 810, "configs/\ndev / prod 環境設定", "#FFFFFF"),
                "M": (1620, 810, "core/\nenum / extension", "#FFFFFF"),
            },
            [
                ("D", "E"),
                ("H", "I"),
                ("H", "K"),
                ("G", "J"),
                ("D", "M"),
            ],
            2100,
            1040,
            [
                [(1040, 136), (1040, 180), (240, 180), (240, 260)],
                [(1040, 136), (1040, 180), (640, 180), (640, 260)],
                [(1040, 136), (1040, 180), (1040, 180), (1040, 260)],
                [(1040, 136), (1040, 180), (1440, 180), (1440, 260)],
                [(1040, 136), (1040, 180), (1840, 180), (1840, 260)],
                [(1040, 136), (1040, 420), (240, 420), (240, 530)],
                [(1040, 136), (1040, 420), (740, 420), (740, 530)],
                [(1040, 136), (1040, 420), (1240, 420), (1240, 530)],
                [(1040, 136), (1040, 420), (1740, 420), (1740, 530)],
                [(640, 316), (640, 420), (740, 420), (740, 530)],
                [(1040, 316), (1040, 380), (1240, 380), (1240, 530)],
                [(1040, 316), (1040, 420), (740, 420), (740, 530)],
            ],
        ),
    }
    created = []
    for filename, (title, nodes, edges, width, height, custom_paths) in diagrams.items():
        out_file = out_dir / filename
        out_file.write_text(render(title, nodes, edges, width, height, custom_paths), encoding="utf-8")
        created.append(str(out_file.resolve()))
    print("\n".join(created))
