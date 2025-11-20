{ pkgs, ... }: {
  # 1. 사용할 Nix 채널 설정
  channel = "stable-23.11";

  # 2. 필요한 패키지 설치 (Java, Flutter 등)
  packages = [
    pkgs.jdk17
    pkgs.unzip
    # Flutter SDK는 IDX가 자동으로 잡기도 하지만, 명시적으로 필요할 수 있습니다.
    # 일단 기본 환경에서 동작하도록 둡니다.
  ];

  # 3. Project IDX 설정
  idx = {
    # 필요한 VS Code 확장 프로그램 자동 설치
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];

    # 미리보기(에뮬레이터) 설정 ★여기가 제일 중요합니다★
    previews = {
      enable = true;
      previews = {
        android = {
          command = ["flutter" "run" "--machine" "-d" "android" "-d" "localhost:5555"];
          manager = "flutter";
        };
      };
    };
  };
}