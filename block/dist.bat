mkdir block
..\7z\7za a -tzip block.love *.lua sound image fonts chapters
copy /b ..\love.exe+block.love block\block.exe
copy ..\DevIL.dll block\DevIL.dll
copy ..\love.dll block\love.dll
copy ..\lua51.dll block\lua51.dll
copy ..\mpg123.dll block\mpg123.dll
copy ..\msvcp120.dll block\msvcp120.dll
copy ..\msvcr120.dll block\msvcr120.dll
copy ..\OpenAL32.dll block\OpenAL32.dll
copy ..\SDL2.dll block\SDL2.dll
..\7z\7za a -tzip block.zip block
del /Q block
rd block
del block.love

pause 