-- xmake.lua
-- Automatically discovers all programs under Programs/.
-- Each directory that contains main.cpp becomes a separate binary target.
-- To add a new program, just create a directory with main.cpp inside Programs/;
-- no modifications to this file are required.

add_requires("glew", "glfw")

local root = path.join(os.scriptdir(), "Programs")

for _, mainfile in ipairs(os.files(root .. "/**/main.cpp")) do
    local prog_dir  = path.directory(mainfile)
    local prog_name = path.filename(prog_dir)
    local chap_name = path.filename(path.directory(prog_dir))

    target(chap_name .. "_" .. prog_name)
        set_kind("binary")
        set_languages("cxx17")
        add_packages("glew", "glfw")
        add_files(prog_dir .. "/*.cpp")
        set_targetdir("$(builddir)/" .. chap_name .. "/" .. prog_name)
        add_runenvs("WAYLAND_DISPLAY", "wayland-0")
    target_end()
end
