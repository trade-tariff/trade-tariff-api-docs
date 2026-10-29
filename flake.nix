{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      nixpkgs-ruby,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ nixpkgs-ruby.overlays.default ];
        };

        rubyVersion = builtins.head (builtins.split "\n" (builtins.readFile ./.ruby-version));
        ruby = pkgs."ruby-${rubyVersion}";

        psychBuildFlags = with pkgs; [
          "--with-libyaml-include=${libyaml.dev}/include"
          "--with-libyaml-lib=${libyaml.out}/lib"
        ];

        reviewTools = import (builtins.fetchTree {
          type = "github";
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "4a29d733e8a7d5b824c3d8c958a946a9867b3eb2";
          narHash = "sha256-f+JACbTqzZ+G92DSnXOUGRhGANb8Blh7CoeYOeBF8/U=";
        }) { inherit system; };
        reviewTrufflehog = reviewTools.trufflehog.overrideAttrs (_: {
          version = "3.95.4";
          src = builtins.fetchTree {
            type = "github";
            owner = "trufflesecurity";
            repo = "trufflehog";
            rev = "d411fff7b8879a62509f3fa98c07f247ac089a51";
            narHash = "sha256-6n3gVr6+P5hWLFUAWByIYtlUkmpOmBF9Ffy5GC8awT0=";
          };
          vendorHash = "sha256-zA5CYHNhpbRhFrnjDNUV30sw+qXAJupMl7uvgOu62lU=";
        });
        reviewRubyHooks = builtins.fetchTree {
          type = "github";
          owner = "mattlqx";
          repo = "pre-commit-ruby";
          rev = "1f893f2c0db4068fafa19b8ea7d7db1253ea0cc1";
          narHash = "sha256-7S84RvncmcXVIjgNhzFyN4HnKJk+tKxHYvfOLcuiw8c=";
        };
        reviewPreCommitConfig = pkgs.writeText "review-pre-commit.json" (
          builtins.toJSON {
            default_install_hook_types = [
              "pre-commit"
              "pre-push"
            ];
            default_stages = [ "pre-commit" ];
            repos = [
              {
                repo = "local";
                hooks = [
                  {
                    id = "trailing-whitespace";
                    name = "trim trailing whitespace";
                    language = "system";
                    entry = "${reviewTools.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
                    types = [ "text" ];
                    stages = [
                      "pre-commit"
                      "pre-push"
                      "manual"
                    ];
                  }
                  {
                    id = "end-of-file-fixer";
                    name = "fix end of files";
                    language = "system";
                    entry = "${reviewTools.python3Packages.pre-commit-hooks}/bin/end-of-file-fixer";
                    types = [ "text" ];
                    stages = [
                      "pre-commit"
                      "pre-push"
                      "manual"
                    ];
                  }
                  {
                    id = "check-yaml";
                    name = "check yaml";
                    language = "system";
                    entry = "${reviewTools.python3Packages.pre-commit-hooks}/bin/check-yaml";
                    types = [ "yaml" ];
                  }
                  {
                    id = "trufflehog";
                    name = "TruffleHog";
                    language = "system";
                    entry = "${reviewTrufflehog}/bin/trufflehog git file://. --since-commit HEAD --results=verified --fail --trust-local-git-config";
                    pass_filenames = false;
                  }
                  {
                    id = "rubocop";
                    name = "Check Ruby style with rubocop";
                    language = "system";
                    entry = "${reviewRubyHooks}/bin/rubocop-wrapper.sh";
                    args = [ "--autocorrect" ];
                    pass_filenames = true;
                    types = [ "ruby" ];
                  }
                  {
                    id = "actionlint-docker";
                    name = "Lint GitHub Actions workflow files";
                    language = "system";
                    entry = "${reviewTools.actionlint}/bin/actionlint";
                    args = [
                      "--no-rails"
                      "--"
                      "config.rb"
                      "bin"
                      "source"
                      "templates"
                    ];
                    types = [ "yaml" ];
                    files = "^\\.github/workflows/";
                  }
                ];
              }
            ];
          }
        );
        reviewEnvironment = ''
          if [ "''${REVIEW_SANDBOX:-}" != 1 ] || [ "$PWD" != /workspace ]; then
            echo 'Run review commands inside a disposable review sandbox.' >&2
            exit 64
          fi
          export TMPDIR=/workspace/.review/tmp PRE_COMMIT_HOME=/workspace/.review/pre-commit
          export GEM_HOME=/workspace/.review/gems
          export GEM_PATH="$GEM_HOME''${REVIEW_GEM_CACHE:+:$REVIEW_GEM_CACHE}"
          export PATH="$GEM_HOME/bin:$PATH" BUNDLE_BIN="$GEM_HOME/bin" BUNDLE_CACHE_PATH="$GEM_HOME/cache"
          export BUNDLE_IGNORE_CONFIG=1 BUNDLE_PATH__SYSTEM=true BUNDLE_FROZEN=true
          export BUNDLE_LOCAL__OPTIONAL_HTML=/deps/optional_html BUNDLE_DISABLE_LOCAL_BRANCH_CHECK=true
          export CARGO_HOME=/workspace/.review/cargo CARGO_NET_OFFLINE=true NIX_BUILD_TOP=/workspace
          unset BUNDLE_PATH BUNDLE_APP_CONFIG BUNDLE_WITHOUT BUNDLE_FORCE_RUBY_PLATFORM
          mkdir -p "$TMPDIR" "$GEM_HOME/cache" "$CARGO_HOME"
          cp /deps/cargo-config "$CARGO_HOME/config.toml"
        '';

        preCommitCheck = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          configPath = ".pre-commit-config-nix.yaml";
          default_stages = [ "pre-commit" ];
          hooks = {
            actionlint = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-added-large-files = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-case-conflicts = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-merge-conflicts = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-yaml = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            deadnix = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            detect-private-keys = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            end-of-file-fixer = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            nixfmt-rfc-style = {
              package = pre-commit-hooks.inputs.nixpkgs.legacyPackages.${system}.nixfmt;
              enable = true;
              stages = [ "pre-commit" ];
            };
            shellcheck = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            statix = {
              enable = true;
              settings.ignore = [ "{.direnv,.nix,.worktrees}/**" ];
              stages = [ "pre-commit" ];
            };
            trim-trailing-whitespace = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            trufflehog = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            rubocop = {
              enable = true;
              name = "rubocop";
              description = "Run RuboCop through Bundler on changed Ruby files";
              entry = ''
                bash -c '
                  changed_files=$(git diff --name-only --diff-filter=ACM --merge-base main | grep -E "\\.(rb|rake)$|^(Gemfile|Rakefile|config\\.ru)$" || true)

                  if [ -n "$changed_files" ]; then
                    bundle exec rubocop --autocorrect --force-exclusion $changed_files
                  fi
                '
              '';
              files = "\\.(rb|rake)$|^(Gemfile|Rakefile|config\\.ru)$";
              pass_filenames = false;
              stages = [ "pre-commit" ];
            };
          };
        };

        preCommit = pkgs.writeShellScriptBin "pre-commit" ''
          set -euo pipefail

          has_config=false
          for arg in "$@"; do
            case "$arg" in
              -c|--config|--config=*)
                has_config=true
                ;;
            esac
          done

          if [ "$has_config" = true ]; then
            exec ${preCommitCheck.config.package}/bin/pre-commit "$@"
          fi

          if [ "''${1:-}" = "run" ]; then
            shift
            exec ${preCommitCheck.config.package}/bin/pre-commit run --config .pre-commit-config-nix.yaml "$@"
          fi

          exec ${preCommitCheck.config.package}/bin/pre-commit "$@"
        '';
      in
      {
        devShells.review = self.devShells.${system}.default.overrideAttrs (old: {
          shellHook = "";
          buildInputs = (old.buildInputs or [ ]) ++ [
            pkgs.libyaml
            pkgs.libffi
            pkgs.openssl
            pkgs.zlib
          ];
          nativeBuildInputs = [
            pkgs.gitMinimal
            pkgs.cargo
            pkgs.rustc
            pkgs.rustPlatform.bindgenHook
            pkgs.pkg-config
            pkgs.which
            reviewTools.pre-commit
            (pkgs.writeShellApplication {
              name = "review-bootstrap";
              text = reviewEnvironment + ''
                for archive in /deps/gem-archives/bundler-*.gem; do
                  gem install --local --no-document --ignore-dependencies "$archive"
                done
                gem install --local --no-document --ignore-dependencies /deps/sass-native.gem
                for archive in /deps/gem-archives/*.gem; do
                  [ -f "$archive" ] || continue
                  cp "$archive" "$GEM_HOME/cache/"
                done
                bundle check || bundle install --local
                bundle binstubs --all
              '';
            })
            (pkgs.writeShellApplication {
              name = "review-check";
              text = reviewEnvironment + ''
                status=0
                pre-commit run --all-files --config ${reviewPreCommitConfig} || status=$?
                pre-commit run --all-files --hook-stage pre-push --config ${reviewPreCommitConfig} || status=$?
                make html || status=$?
                bundle exec rake test 2>&1 | tee "$TMPDIR/unit.log" || status=$?
                ruby -e 'abort "Skipped unit tests" if File.read(ARGV[0]).match?(/[1-9][0-9]* (?:skips|pendings|omissions)/)' "$TMPDIR/unit.log" || status=$?
                exit "$status"
              '';
            })
          ]
          ++ (old.nativeBuildInputs or [ ]);
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.libyaml
            pkgs.libffi
            pkgs.openssl
            pkgs.zlib
            pkgs.stdenv.cc.cc.lib
          ];
          BUNDLE_BUILD__PSYCH = builtins.concatStringsSep " " psychBuildFlags;
          TZDIR = "${pkgs.tzdata.outPath}/share/zoneinfo";
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        });

        devShells.default = pkgs.mkShell {
          shellHook = ''
            export GEM_HOME=$PWD/.nix/ruby/$(${ruby}/bin/ruby -e "puts RUBY_VERSION")
            mkdir -p $GEM_HOME

            export GEM_PATH=$GEM_HOME
            export PATH=$GEM_HOME/bin:$PATH
            export BUNDLE_BUILD__PSYCH="${builtins.concatStringsSep " " psychBuildFlags}"
            ${preCommitCheck.shellHook}
            export PATH=${preCommit}/bin:$PATH
          '';

          buildInputs = preCommitCheck.enabledPackages ++ [
            pkgs.graphviz
            pkgs.nodejs_latest
            ruby
          ];
        };
      }
    );
}
