_: {
  flake.templates = {
    cpp = {
      path = ../../templates/cpp;
      description = "C++ project with Clang, CMake, Ninja, clangd, and LLDB";
    };

    frontend = {
      path = ../../templates/frontend;
      description = "Frontend project with Node.js, pnpm, TypeScript, ESLint, and Prettier";
    };

    rust = {
      path = ../../templates/rust;
      description = "Rust project with rust-analyzer, rustfmt, and Clippy";
    };

    default = {
      path = ../../templates/rust;
      description = "Rust project with rust-analyzer, rustfmt, and Clippy";
    };
  };
}
