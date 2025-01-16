## trivial-todo-list

### Description

A trivial TODO list application written in AutoIt.

### Why

The main reason to implement this was a demo (livestream) to show "app-update-handler.au3" module, which allows you to update your current running application (executable) in case a new version exists.

### Showcase

How to easily embed the "app-update-handler.au3" module can be seen in "main.au3" (`_Main()` function).

---

### Preconditions for the module usage

1. Add a program version indicator when you build your app.
   Concrete simply set `#pragma compile(FileVersion, 0.1.0)` at the top of your program entry file `main.au3`.
2. Set your output file path/name. This is the program name.
   Concrete simply set `#AutoIt3Wrapper_Outfile_x64=..\build\YOUR-PROGRAM-NAME.exe` below the "#pragma" above in `main.au3`.
3. Include the app update module like so: `#include ".\utils\app-update-handler.au3"`.
4. Embed the module in your program flow (before your program will do the main logic).
``` autoit
If @Compiled Then
    Local Const $sUrlVersionDownload   = 'https://raw.githubusercontent.com/YOUR-GITHUB-USERNAME/app-versions/refs/heads/main'
    Local Const $sUrlAppUpdateDownload = 'https://github.com/YOUR-GITHUB-USERNAME/YOUR-PROGRAM-REPOSITORY-NAME/raw/refs/heads/main/build'
    _TryUpdateApp($sUrlVersionDownload, $sUrlAppUpdateDownload)
EndIf
```
For `$sUrlAppUpdateDownload` you also can define a download URL for your webspace (like FTP-Server or what ever).

---

### TODO

Redesign README.md file.
