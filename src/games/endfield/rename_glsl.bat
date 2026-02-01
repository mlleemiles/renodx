for /r %%i in (*.glsl) do (
    ren "%%i" "%%~ni.slang"
)