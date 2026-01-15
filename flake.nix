{
  description = "KanbanFlow MCP Server - manage boards, tasks, and workflows from Claude";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
  let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    pkgsFor = system: import nixpkgs { inherit system; };
  in {
    packages = forAllSystems (system:
      let pkgs = pkgsFor system;
      in {
        default = pkgs.buildNpmPackage rec {
          pname = "kanbanflow-mcp-server";
          version = "1.0.4";  # Fork with date display fix

          src = pkgs.fetchFromGitHub {
            owner = "dean138";
            repo = "kanbanflow-mcp-server";
            rev = "1a5b627976231e4d71b8ca8ad5dd149340f9daf5";
            hash = "sha256-H/VzEx3kLXaMJvFEkAsQ/CGJVrYBVFF/9WXoc/dwk+k=";
          };

          npmDepsHash = "sha256-PEY1iFxDkqlqskLqVw/Nq5fFN7Bo/dvlxZewrHFwg2Q=";

          # TypeScript project - needs to build
          npmBuildScript = "build";

          # Ensure the binary is executable
          postInstall = ''
            chmod +x $out/lib/node_modules/${pname}/build/index.js
          '';

          meta = with pkgs.lib; {
            description = "Model Context Protocol (MCP) server for KanbanFlow";
            homepage = "https://github.com/dean138/kanbanflow-mcp-server";
            license = licenses.mit;
            maintainers = [ ];
            mainProgram = "kanbanflow-mcp-server";
          };
        };

        kanbanflow-mcp-server = self.packages.${system}.default;
      }
    );

    # Overlay for easy integration
    overlays.default = final: prev: {
      kanbanflow-mcp-server = self.packages.${prev.system}.default;
    };
  };
}
