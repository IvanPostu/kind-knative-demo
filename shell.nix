let 
  pkgs = import <nixpkgs> { config = { allowUnfree = false; }; };
  PROJECT_ROOT = builtins.toString ./.;
in
pkgs.mkShell {
  name = "app-shell";

  nativeBuildInputs = [
  ];

  buildInputs = with pkgs; [
    cmake
  ];

  LANG = "en_US.UTF-8";
  LC_ALL = "en_US.UTF-8";

  shellHook = ''
    export PROJECT_ROOT="${PROJECT_ROOT}"
    export PATH="$PROJECT_ROOT/bin:$PATH"    
  '';
}