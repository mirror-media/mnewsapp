import '../value/image_path.dart';

enum Organize { tpp, kmt, dpp }

extension OrganizeExtension on Organize {
  String logoPath() {
    switch (this) {
      case Organize.tpp:
        return ImagePath.tppLogo;
      case Organize.kmt:
        return ImagePath.kmtLogo;
      case Organize.dpp:
        return ImagePath.dppLogo;
    }
  }

  String president() {
    switch (this) {
      case Organize.tpp:
        return '柯文哲';
      case Organize.kmt:
        return '侯友宜';
      case Organize.dpp:
        return '賴清德';
    }
  }

  String vicePresident() {
    switch (this) {
      case Organize.tpp:
        return '吳欣盈';
      case Organize.kmt:
        return '趙少康';
      case Organize.dpp:
        return '蕭美琴';
    }
  }

  String numberIcon() {
    switch (this) {
      case Organize.tpp:
        return ImagePath.number1Icon;
      case Organize.kmt:
        return ImagePath.number3Icon;
      case Organize.dpp:
        return ImagePath.number2Icon;
    }
  }

  String candidatePictureUrl() {
    switch (this) {
      case Organize.tpp:
        return 'https://storage.googleapis.com/whoareyou-gcs.readr.tw/person/%E6%9F%AF%E6%96%87%E5%93%B2.jpg';
      case Organize.kmt:
        return 'https://whoareyou-gcs.readr.tw/person/%E4%BE%AF%E5%8F%8B%E5%AE%9C.jpg';
      case Organize.dpp:
        return 'https://storage.googleapis.com/whoareyou-gcs.readr.tw/person/%E8%B3%B4%E6%B8%85%E5%BE%B7.jpg';
    }
  }
}
