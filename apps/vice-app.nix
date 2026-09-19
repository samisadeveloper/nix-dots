{ pkgs }:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "vice";
  version = "2.10.1";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "eklonofficial";
    repo = "Vice";
    rev = "v${version}";
    hash = "sha256-9HWlcSZyWYwiaOu0WB0uYEV63K9FhpD3tQH1OnVxGwg=";
  };

  build-system = with pkgs.python3Packages; [ setuptools wheel ];

  dependencies = with pkgs.python3Packages; [
    evdev
    aiohttp
    click
    tomli-w
    psutil
    pywebview
    pyqt6
    pyqt6-webengine
    pygobject3
  ];

  makeWrapperArgs = [
    "--prefix" "PATH" ":" (pkgs.lib.makeBinPath [
      pkgs.ffmpeg
      pkgs.gpu-screen-recorder
      pkgs.cloudflared
      pkgs.wl-clipboard
      pkgs.xclip
      pkgs.xdotool
      pkgs.xorg.xprop
      pkgs.wmctrl
      pkgs.gst_all_1.gstreamer
      pkgs.gst_all_1.gst-plugins-base
      pkgs.gst_all_1.gst-plugins-good
    ])
  ];

  postInstall = ''
    install -Dm644 ${src}/vice.desktop $out/share/applications/vice.desktop
    install -Dm644 ${src}/assets/vice.svg $out/share/icons/hicolor/scalable/apps/vice.svg
    install -Dm644 ${src}/packaging/vice.rules $out/lib/udev/rules.d/70-vice-input.rules
  '';

  doCheck = false;
  pythonImportsCheck = [ "vice" ];
}
