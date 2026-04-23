-- xmake.lua
-- Automatically discovers all programs under Programs/.
-- Each directory that contains main.cpp becomes a separate binary target.
-- To add a new program, just create a directory with main.cpp inside Programs/;
-- no modifications to this file are required.

add_requires("glew", "glfw", "glm")

local soil2_src = path.join(os.scriptdir(), "SOIL2-master/src")

-- Build SOIL2 as a static library from bundled source
target("soil2")
    set_kind("static")
    set_languages("c11")
    add_files(soil2_src .. "/SOIL2/*.c")
    add_includedirs(soil2_src, {public = true})
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
