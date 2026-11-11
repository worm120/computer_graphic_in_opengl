-- xmake.lua
-- Automatically discovers all programs under Programs/.
-- Each directory that contains main.cpp becomes a separate binary target.
-- To add a new program, just create a directory with main.cpp inside Programs/;
-- no modifications to this file are required.

-- On NixOS there is no /usr/lib: use the libs provided by nixpkgs instead of
-- letting xmake download and build them from source. Enter the toolchain shell
-- first, then build/run:
--   nix-shell -p glew glfw glm pkg-config libx11 --run 'xmake f -y --cxx=g++'
--   nix-shell -p glew glfw glm pkg-config libx11 --run 'xmake run Chapter_02_opengl_Prog2_5_triangle'
-- or simply: ./run.sh Prog2_5_triangle
add_requires("glew", "glfw", "glm", {system = true})

local soil2_src = path.join(os.scriptdir(), "SOIL2-master/src")

-- Build SOIL2 as a static library from bundled source
target("soil2")
    set_kind("static")
    set_languages("c11")
    add_files(soil2_src .. "/SOIL2/*.c")
    add_includedirs(soil2_src, {public = true})
    -- SOIL2 talks to GLX directly; with a static lib the symbols must be linked
    -- by every consumer, so expose them as public links.
    add_links("GL", "GLX", {public = true})
target_end()

local root = path.join(os.scriptdir(), "Programs")

for _, mainfile in ipairs(os.files(root .. "/**/main.cpp")) do
    local prog_dir  = path.directory(mainfile)
    local prog_name = path.filename(prog_dir)
    local chap_name = path.filename(path.directory(prog_dir))

    target(chap_name .. "_" .. prog_name)
        set_kind("binary")
        set_languages("cxx17")
        add_packages("glew", "glfw", "glm")
        add_files(prog_dir .. "/*.cpp")
        set_targetdir("$(builddir)/" .. chap_name .. "/" .. prog_name)
        set_rundir(prog_dir)
        add_runenvs("WAYLAND_DISPLAY", "wayland-0")
        -- Link SOIL2 for any target that uses Utils.cpp (which includes SOIL2)
        if os.isfile(prog_dir .. "/Utils.cpp") then
            add_deps("soil2")
        end
    target_end()
end
