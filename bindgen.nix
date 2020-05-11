/*
 * bindgen
 */
{ stdenv, fetchFromGitHub, rustPlatform, pkgs }:
let
  llvm-xtensa = pkgs.callPackage ./llvm-xtensa.nix {};
in
rustPlatform.buildRustPackage rec {
  version = "v0.53.2";
  pname = "rust-bindgen";

  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "rust-bindgen";
    rev = version;

    sha256 = "01dkaa2akqrhpxxf0g2zyfdb3nx16y14qsg0a9d5n92c4yyvmwjg";
  };

  cargoSha256 = "1yvpj2bz11pcyaadp5vc6yf1q04asr7id6aiw1n875dggvnwb3i8";

  /*
   * Copied from upstream crates.io
   */

# [2020-05-11T21:21:31Z ERROR bindgen::ir::item] Unhandled cursor kind 25: Cursor(~String kind: CXXDestructor, loc: /build/source/tests/headers/public-dtor.hpp:11:9, usr: Some("c:@N@cv@S@String@F@~String#"))
# [2020-05-11T21:21:31Z ERROR bindgen::ir::ty] unsupported type: kind = 162; ty = Type(ObjectType, kind: ObjCTypeParam, cconv: 100, decl: Cursor( kind: NoDeclFound, loc: builtin definitions, usr: None), canon: Cursor( kind: NoDeclFound, loc: builtin definitions, usr: None)); at Cursor(get kind: ObjCInstanceMethodDecl, loc: /build/source/tests/headers/objc_template.h:5:15, usr: Some("c:objc(cs)Foo(im)get"))
# [2020-05-11T21:21:31Z ERROR bindgen::ir::ty] unsupported type: kind = 162; ty = Type(KeyType, kind: ObjCTypeParam, cconv: 100, decl: Cursor( kind: NoDeclFound, loc: builtin definitions, usr: None), canon: Cursor( kind: NoDeclFound, loc: builtin definitions, usr: None)); at Cursor(key kind: ParmDecl, loc: /build/source/tests/headers/objc_template.h:9:46, usr: Some("c:objc_template.h@250objc(cs)FooMultiGeneric(im)objectForKey:@key"))
# [2020-05-11T21:21:31Z ERROR bindgen::ir::ty] unsupported type: kind = 162; ty = Type(ObjectType, kind: ObjCTypeParam, cconv: 100, decl: Cursor( kind: NoDeclFound, loc: builtin definitions, usr: None), canon: Cursor( kind: NoDeclFound, loc: builtin definitions, usr: None)); at Cursor(objectForKey: kind: ObjCInstanceMethodDecl, loc: /build/source/tests/headers/objc_template.h:9:24, usr: Some("c:objc(cs)FooMultiGeneric(im)objectForKey:"))
# [2020-05-11T21:21:31Z ERROR bindgen::ir::item] Unhandled cursor kind 24: Cursor(a<type-parameter-0-0 (type-parameter-0-1...)> kind: CXXConstructor, loc: /build/source/tests/headers/issue-544-stylo-creduce.hpp:5:50, usr: Some("c:@SP>2#T#pT@a>#Ft0.0(#Pt0.1)@F@a#&1>@ST>1#T@a1S0_#"))
# [2020-05-11T21:21:31Z ERROR bindgen::ir::item] Unhandled cursor kind 24: Cursor(Bar<Foo> kind: CXXConstructor, loc: /build/source/tests/headers/issue-1464.hpp:5:3, usr: Some("c:@ST>1#NI@Bar@F@Bar#"))
# [2020-05-11T21:21:31Z ERROR bindgen::ir::item] Unhandled cursor kind 25: Cursor(~Bar<Foo> kind: CXXDestructor, loc: /build/source/tests/headers/issue-1464.hpp:6:3, usr: Some("c:@ST>1#NI@Bar@F@~Bar#"))
# [2020-05-11T21:21:31Z ERROR bindgen::ir::item] Unhandled cursor kind 21: Cursor(doBaz kind: CXXMethod, loc: /build/source/tests/headers/constructor-tp.hpp:12:9, usr: Some("c:@ST>1#T@Foo@F@doBaz#"))
# [2020-05-11T21:21:31Z ERROR bindgen::ir::item] Unhandled cursor kind 24: Cursor(Foo<T> kind: CXXConstructor, loc: /build/source/tests/headers/constructor-tp.hpp:21:9, usr: Some("c:@ST>1#T@Foo@F@Foo#"))
# [2020-05-11T21:21:31Z ERROR bindgen::ir::item] Unhandled cursor kind 9: Cursor(kBar kind: VarDecl, loc: /build/source/tests/headers/auto.hpp:10:31, usr: Some("c:@ST>1#T@Bar@kBar"))
# test header_constify_module_enums_namespace_hpp ... [2020-05-11T21:21:31Z ERROR bindgen::ir::item] Unhandled cursor kind 24: Cursor(Bar kind: CXXConstructor, loc: /build/source/tests/headers/constructor-tp.hpp:25:6, usr: Some("c:@S@Bar@F@Bar#"))
  checkPhase = ''
    runHook preCheck
    export LLVM_CONFIG_PATH="${llvm-xtensa}/bin/llvm-config"
    #cargo test --release
    runHook postCheck
  '';

  meta = with stdenv.lib; {
    description = "Automatically generates Rust FFI bindings to C (and some C++) libraries.";
    homepage = https://github.com/rust-lang/rust-bindgen;
    maintainers = with maintainers; [ "crabtw" "fitzgen" "nox" "emilio" ];
    license = with licenses; [ bsd3 ];
    platforms = platforms.unix;
  };
}