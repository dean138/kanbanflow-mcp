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
          version = "1.0.3";

          src = pkgs.fetchFromGitHub {
            owner = "WilliamAvHolmberg";
            repo = "kanbanflow-mcp-server";
            rev = "098dd47cb7ab54f516c68d73132093ca529ef481";
            hash = "sha256-9AyQkG5DEmnMTQPaBCgjOZkboHyEiQTOb8fMx9552/o=";
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
            homepage = "https://github.com/WilliamAvHolmberg/kanbanflow-mcp-server";
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
