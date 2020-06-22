"" Vim plugin file
" Long status line
" Author: Mansour Alharthi <man9our.ah@gmail.com>

" Git status variables 
let s:gitShow = 0
let s:gitRootDir = ""
let s:gitBranchName = ""
let s:gitInsertNum = 0
let s:gitDeleteNum = 0

" Symbols 
let s:gitBranchSym = "\ue0a0"
let s:lnumSym = "Ln"
let s:cnumSym = "Col"
let s:rightDarkArrowSym = "\ue0b0"
let s:leftDarkArrowSym = "\ue0b2"
let s:symBeforeTagName = "\u21b3"
let s:sepASym = "\ue0b9"
let s:sepBSym = "\ue0b8"

" Background Colors
let s:normalLabel = "#005f87"
let s:insertLabel = "#008700"
let s:replaceLabel = "#52ba00"
let s:visualLabel = "#87005F"
let s:selectLabel = "#0056c4"
let s:otherLabel = "#996BA0"
let s:filenameLabel = "#082430"
let s:ModFileFlagsLabel = "#7e7e89"
let s:ROFileFlagsLabel = "#3f3f45"
let s:infoBarLabel = "#005F5F"
let s:rightLabel = "#87005F"
let s:compErrorLabel = "#af0000"
let s:compWarnLabel = "#ff8700"
let s:clkLabel = s:filenameLabel

" FG colors
let s:mutewhite = "#fcfcfc"
let s:funcnameText = "#c66628"

" Error & Warn: 0=> only show when > 0
let s:alwaysShowEW = 1

" Label colors
" To make it as fast as possible, we define all labels once
" instead of defining on the fly depending on the mode
exec 'hi! NormalModeColor cterm=bold guibg=' . s:normalLabel . ' guifg=' . s:mutewhite
exec 'hi! NormalModeColorSep guibg=' . s:filenameLabel . ' guifg=' . s:normalLabel
exec 'hi! NormalModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:normalLabel

exec 'hi! InsertModeColor cterm=bold guibg='. s:insertLabel . ' guifg=' . s:mutewhite 
exec 'hi! InsertModeColorSep guibg=' . s:filenameLabel . ' guifg=' . s:insertLabel
exec 'hi! InsertModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:insertLabel

exec 'hi! ReplaceModeColor cterm=bold guibg=' . s:replaceLabel . ' guifg=' . s:mutewhite
exec 'hi! ReplaceModeColorSep guibg=' . s:filenameLabel . ' guifg=' . s:replaceLabel
exec 'hi! ReplaceModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:replaceLabel

exec 'hi! VisualModeColor cterm=bold guibg=' . s:visualLabel . ' guifg=' . s:mutewhite
exec 'hi! VisualModeColorSep guibg=' . s:filenameLabel .' guifg=' . s:visualLabel
exec 'hi! VisualModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:visualLabel

exec 'hi! SelectModeColor cterm=bold guibg=' . s:selectLabel . ' guifg=' . s:mutewhite
exec 'hi! SelectModeColorSep guibg=' . s:filenameLabel . ' guifg=' . s:selectLabel 
exec 'hi! SelectModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:selectLabel

exec 'hi! OtherModeColor cterm=bold guibg=' . s:otherLabel . ' guifg=' . s:mutewhite
exec 'hi! OtherModeColorSep guibg=' . s:filenameLabel . ' guifg=' . s:otherLabel 
exec 'hi! OtherModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:otherLabel

exec 'hi! FilenameColor cterm=None guibg=' . s:filenameLabel . ' guifg=' . s:mutewhite

exec 'hi! FuncnameColor cterm=None guibg=' . s:filenameLabel . ' guifg=' . s:funcnameText

exec 'hi! ModFileFlagsColor cterm=bold guibg=' . s:ModFileFlagsLabel 
exec 'hi! ModFileFlagsColorSep guibg=' . s:filenameLabel . ' guifg=' . s:ModFileFlagsLabel

exec 'hi! ROFileFlagsColor cterm=bold guibg=' . s:ROFileFlagsLabel 
exec 'hi! ROFileFlagsColorSepMod guibg=' . s:ModFileFlagsLabel . ' guifg=' . s:ROFileFlagsLabel
exec 'hi! ROFileFlagsColorSep guibg=' . s:filenameLabel . ' guifg=' . s:ROFileFlagsLabel

exec 'hi! InfoBarColor cterm=bold guibg=' . s:infoBarLabel . ' guifg=' . s:mutewhite
exec 'hi! InfoBarColorSepStrick cterm=bold guibg=' . s:infoBarLabel . ' guifg=' . s:filenameLabel
exec 'hi! InfoBarColorSepModFlag guibg=' . s:ModFileFlagsLabel . ' guifg=' . s:infoBarLabel
exec 'hi! InfoBarColorSepROFlag guibg=' . s:ROFileFlagsLabel . ' guifg=' . s:infoBarLabel
exec 'hi! InfoBarColorSep guibg=' . s:filenameLabel . ' guifg=' . s:infoBarLabel

exec 'hi! RightCornerColor cterm=bold guibg=' . s:rightLabel . ' guifg=' . s:mutewhite
exec 'hi! RightCornerColorSep guibg=' . s:rightLabel . ' guifg=' . s:infoBarLabel

exec 'hi! CompilationErrorLabelsColor guibg=' . s:compErrorLabel . ' guifg=' . s:mutewhite
exec 'hi! CompilationErrorLabelsColorSepWarn guibg=' . s:compWarnLabel . ' guifg=' . s:compErrorLabel
exec 'hi! CompilationErrorLabelsColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:compErrorLabel
exec 'hi! YcmErrorSection guibg=' . s:compErrorLabel

exec 'hi! CompilationWarningLabelsColor guibg=' . s:compWarnLabel . ' guifg=' . s:mutewhite
exec 'hi! CompilationWarningLabelsColorSep guibg=' . s:clkLabel. ' guifg=' . s:compWarnLabel
exec 'hi! YcmWarningSection guibg=' . s:compWarnLabel

exec 'hi! ClockLabelsColor guibg=' . s:clkLabel . ' guifg=' . s:mutewhite
exec 'hi! StatusLineNC guifg=' . s:clkLabel . ' cterm=NONE'

"" Functions
" If inside git repo, get path relative to git root, otherwise show full path
function s:GetFilename()
    if s:gitShow == 1
        return fnamemodify(s:gitRootDir, ":t") . substitute(expand("%:p"), s:gitRootDir, "", "")
    endif
    return expand("%:p")
endfunction

" Updates Git status variables
" Should be called via autocmd BufEnter and BufWritePost 
function s:GitUpdateInfo()
    " Parent of current file
    let l:parentDir = fnamemodify(expand("%:p"), ":h")

    "" Lets get the git root dir
    let l:dotGitDir = system("git -C " . l:parentDir . " rev-parse --absolute-git-dir")
    if v:shell_error != 0
        let s:gitShow = 0
        return
    endif
    let s:gitRootDir = trim(fnamemodify(l:dotGitDir, ":h")) 
    
    "" Now get the branch name or the short commit hash
    let l:fullBranchName = system("git -C " . l:parentDir . " symbolic-ref HEAD")
    if v:shell_error != 0
        " Try commit hash
        let s:gitBranchName = system("git -C " . l:parentDir . " rev-parse --short HEAD")
        if v:shell_error != 0
            " Nothing works, abort 
            let s:gitShow = 0
            return
        endif
    else
        let s:gitBranchName = fnamemodify(l:fullBranchName, ":t")
    endif
    let s:gitBranchName = trim(s:gitBranchName)

    "" Append a * after branch name if repo is dirty
    if len(trim(system("git status -s"))) != 0
        let s:gitBranchName .= "*"
    endif

    "" Now get the lines inserted/deleted
    let l:gitDiffRaw = trim(system("git -C " . l:parentDir . " diff --numstat -- " . expand("%:p")))
    if len(l:gitDiffRaw) == 0
        let s:gitInsertNum = 0
        let s:gitDeleteNum = 0
    else
        let l:splitDiff = split(l:gitDiffRaw)
        let s:gitInsertNum = l:splitDiff[0]
        let s:gitDeleteNum = l:splitDiff[1]
    endif

    " Now we can show git status
    let s:gitShow = 1
endfunction

" Right truncate str if len(str) > maxlen
function s:RightTruncate(str, maxlen)
  if (len(a:str) > a:maxlen)
    return strpart(a:str, 0, a:maxlen) . "... "
  endif
  return a:str
endfunction

" Gets the current mode
function s:GetMode()
  if (mode() ==? 'n')
    return 'n'
  elseif (mode() ==? 'v')
    return 'v'
  elseif (mode() ==? "\<C-V>")
    return 'vb'
  elseif (mode() ==? 'R')
    return 'r'
  elseif (mode() ==? 'i')
    return 'i'
  elseif (mode() ==? 's' || mode() == "\<C-S>")
    return 's'
  endif
  return mode(1)
endfunction

"" Returns a status line
function GetStatusLine()
  let l:sts = ""
  let l:showFuncName = 0

  "" Start of main window status line: mode
  let l:currentMode = s:GetMode()
  if (l:currentMode ==# 'n')
    let l:sts .= "%#NormalModeColorSepClk#". s:leftDarkArrowSym . "%#NormalModeColor# NORMAL " . 
                \ "%#NormalModeColorSep#" . s:rightDarkArrowSym
  
  elseif (l:currentMode ==# 'v')
    let l:sts .= "%#VisualModeColorSepClk#" . s:leftDarkArrowSym . "%#VisualModeColor# VISUAL " . 
                \ "%#VisualModeColorSep#" . s:rightDarkArrowSym

  elseif (l:currentMode ==# 'vb')
    let l:sts .= "%#VisualModeColorSepClk#" . s:leftDarkArrowSym . "%#VisualModeColor# V·BLOCK " . 
                \ "%#VisualModeColorSep#" . s:rightDarkArrowSym

  elseif (l:currentMode ==# 'r')
    let l:sts .= "%#ReplaceModeColorSepClk#" . s:leftDarkArrowSym . "%#ReplaceModeColor# REPLACE " . 
                \ "%#ReplaceModeColorSep#" . s:rightDarkArrowSym
    let l:showFuncName = 1

  elseif (l:currentMode ==# 'i')
    let l:sts .= "%#InsertModeColorSepClk#" . s:leftDarkArrowSym . "%#InsertModeColor# INSERT " . 
                \ "%#InsertModeColorSep#" . s:rightDarkArrowSym
    let l:showFuncName = 1

  elseif (l:currentMode ==# 's')
    let l:sts .= "%#SelectModeColorSepClk#" . s:leftDarkArrowSym . "%#SelectModeColor# SELECT " . 
                \ "%#SelectModeColorSep#" . s:rightDarkArrowSym

  else 
    let l:sts .= "%#OtherModeColorSepClk#" . s:leftDarkArrowSym . "%#OtherModeColor# OTHER " . 
                \ "%#OtherModeColorSep#" . s:rightDarkArrowSym

  endif

  let l:middleText = "%#FilenameColor#" . s:GetFilename()  . " "
  if (l:showFuncName == 1) 
    let l:funcProto = Tlist_Get_Tag_Prototype_By_Line()
    if (len(l:funcProto))
      " Show function name instead in insert mode
      let l:middleText = "%#FuncnameColor#" . s:symBeforeTagName . 
                        \ " " . s:RightTruncate(l:funcProto, (&columns - ((s:gitShow == 0)? 75 : 95)))

    endif
  endif
  let l:sts .= " %<%(" . l:middleText . "%)"
 
  "" Left align
  let l:sts .= "%="

  "" file flags colors
  if(&modified)
    let l:sts .= "%#ModFileFlagsColorSep#" . s:leftDarkArrowSym . "%#ModFileFlagsColor# "
  endif
  
  if(&readonly || &modifiable==0)
    if(&modified)
      let l:sts .= "%#ROFileFlagsColorSepMod#" . s:leftDarkArrowSym . "%#ROFileFlagsColor# " 
    else
       let l:sts .= "%#ROFileFlagsColorSep#" . s:leftDarkArrowSym . "%#ROFileFlagsColor# " 
    endif
    let l:sts .= "%#InfoBarColorSepROFlag#"
  else
    if(&modified)
      let l:sts .= "%#InfoBarColorSepModFlag#"
    else
      let l:sts .= "%#InfoBarColorSep#"
    endif
  endif
  

  "" Col, ln & Perc
  let l:sts .= s:leftDarkArrowSym . "%#InfoBarColor# "

  if s:gitShow == 1
      let l:sts .= s:gitBranchSym . " " . s:gitBranchName 
      let l:sts .= "%#InfoBarColorSepStrick#" . s:sepASym . "  %#InfoBarColor#"
      let l:sts .= "\u2714 " . s:gitInsertNum . " \u2718 " . s:gitDeleteNum 
      let l:sts .= "%#InfoBarColorSepStrick#" . s:sepASym . "  %#InfoBarColor#"
  endif

  let l:sts .= s:cnumSym . " %c" . "%#InfoBarColorSepStrick#" . s:sepASym . "  %#InfoBarColor#"
  let l:sts .= s:lnumSym . " %l"
  let l:sts .= " %#RightCornerColorSep#" . s:sepBSym . "  %#RightCornerColor#%2P "

  "" Taglist status line
  let g:TagListStatusLine = ""
  let l:errorsCount = youcompleteme#GetErrorCount()
  let l:warnsCount = youcompleteme#GetWarningCount()
  if( (l:errorsCount > 0 && l:warnsCount > 0) || s:alwaysShowEW == 1)
    let g:TagListStatusLine = "%#CompilationErrorLabelsColor# " . l:errorsCount . " "
    let g:TagListStatusLine .= "%#CompilationErrorLabelsColorSepWarn#" . s:rightDarkArrowSym
    let g:TagListStatusLine .= "%#CompilationWarningLabelsColor# " . l:warnsCount . " "
    let g:TagListStatusLine .= "%#CompilationWarningLabelsColorSep#" . s:rightDarkArrowSym
  elseif(l:errorsCount > 0)
    let g:TagListStatusLine = "%#CompilationErrorLabelsColor# " . l:errorsCount . " "
    let g:TagListStatusLine .= "%#CompilationErrorLabelsColorSepClk#" . s:rightDarkArrowSym
  elseif(l:warnsCount > 0)
    let g:TagListStatusLine = "%#CompilationWarningLabelsColor# " . l:warnsCount . " "
    let g:TagListStatusLine .= "%#CompilationWarningLabelsColorSep#" . s:rightDarkArrowSym
  endif
  "" Fire redraw status line to update with new value
  let g:TagListStatusLine .= "%#ClockLabelsColor#%= " . strftime('%b %d %Y %l:%M %p')  | redraws!

  return l:sts
endfunction


" Always show statusline
set laststatus=2
" Dont show the mode in lastline 
set noshowmode
" Set the statusline for main window
set statusline=%!GetStatusLine()
" Set the statusline for taglist window
let g:TagListStatusLine = "" " Eval this var everytime main status line is updated
autocmd FileType taglist setlocal statusline=%!g:TagListStatusLine
autocmd BufWritePost * call s:GitUpdateInfo()
autocmd VimEnter * call s:GitUpdateInfo()
