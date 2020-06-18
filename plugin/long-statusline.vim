"""""""""""""""""""""""""""""""""""""""" Status line
set laststatus=2
set noshowmode
set statusline=%!GetStatusLine()
let g:TagListStatusLine = "" " Eval this var everytime main status line is updated
autocmd FileType taglist setlocal statusline=%!g:TagListStatusLine

" BG colors
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
let s:brightWhite = "#c4c4c4"
let s:funcnameText = "#c66628"

" Error & Warn: 0=> only show when > 0
let s:alwaysShowEW = 1

" Label colors
" To make it as fast as possible, we define all labels once
" instead of defining on the fly depending on the mode
exec 'hi NormalModeColor cterm=bold guibg=' . s:normalLabel . ' guifg=' . s:brightWhite
exec 'hi NormalModeColorSep guibg=' . s:filenameLabel . ' guifg=' . s:normalLabel
exec 'hi NormalModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:normalLabel

exec 'hi InsertModeColor cterm=bold guibg='. s:insertLabel . ' guifg=' . s:brightWhite 
exec 'hi InsertModeColorSep guibg=' . s:filenameLabel . ' guifg=' . s:insertLabel
exec 'hi InsertModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:insertLabel

exec 'hi ReplaceModeColor cterm=bold guibg=' . s:replaceLabel . ' guifg=' . s:brightWhite
exec 'hi ReplaceModeColorSep guibg=' . s:filenameLabel . ' guifg=' . s:replaceLabel
exec 'hi ReplaceModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:replaceLabel

exec 'hi VisualModeColor cterm=bold guibg=' . s:visualLabel . ' guifg=' . s:brightWhite
exec 'hi VisualModeColorSep guibg=' . s:filenameLabel .' guifg=' . s:visualLabel
exec 'hi VisualModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:visualLabel

exec 'hi SelectModeColor cterm=bold guibg=' . s:selectLabel . ' guifg=' . s:brightWhite
exec 'hi SelectModeColorSep guibg=' . s:filenameLabel . ' guifg=' . s:selectLabel 
exec 'hi SelectModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:selectLabel

exec 'hi OtherModeColor cterm=bold guibg=' . s:otherLabel . ' guifg=' . s:brightWhite
exec 'hi OtherModeColorSep guibg=' . s:filenameLabel . ' guifg=' . s:otherLabel 
exec 'hi OtherModeColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:otherLabel

exec 'hi FilenameColor cterm=None guibg=' . s:filenameLabel . ' guifg=' . s:brightWhite

exec 'hi FuncnameColor cterm=None guibg=' . s:filenameLabel . ' guifg=' . s:funcnameText

exec 'hi ModFileFlagsColor cterm=bold guibg=' . s:ModFileFlagsLabel 
exec 'hi ModFileFlagsColorSep guibg=' . s:filenameLabel . ' guifg=' . s:ModFileFlagsLabel

exec 'hi ROFileFlagsColor cterm=bold guibg=' . s:ROFileFlagsLabel 
exec 'hi ROFileFlagsColorSepMod guibg=' . s:ModFileFlagsLabel . ' guifg=' . s:ROFileFlagsLabel
exec 'hi ROFileFlagsColorSep guibg=' . s:filenameLabel . ' guifg=' . s:ROFileFlagsLabel

exec 'hi InfoBarColor cterm=bold guibg=' . s:infoBarLabel . ' guifg=' . s:brightWhite
exec 'hi InfoBarColorSepModFlag guibg=' . s:ModFileFlagsLabel . ' guifg=' . s:infoBarLabel
exec 'hi InfoBarColorSepROFlag guibg=' . s:ROFileFlagsLabel . ' guifg=' . s:infoBarLabel
exec 'hi InfoBarColorSep guibg=' . s:filenameLabel . ' guifg=' . s:infoBarLabel

exec 'hi RightCornerColor cterm=bold guibg=' . s:rightLabel . ' guifg=' . s:brightWhite
exec 'hi RightCornerColorSep guibg=' . s:rightLabel . ' guifg=' . s:infoBarLabel

exec 'hi CompilationErrorLabelsColor guibg=' . s:compErrorLabel . ' guifg=' . s:brightWhite
exec 'hi CompilationErrorLabelsColorSepWarn guibg=' . s:compWarnLabel . ' guifg=' . s:compErrorLabel
exec 'hi CompilationErrorLabelsColorSepClk guibg=' . s:clkLabel . ' guifg=' . s:compErrorLabel
exec 'hi YcmErrorSection guibg=' . s:compErrorLabel

exec 'hi CompilationWarningLabelsColor guibg=' . s:compWarnLabel . ' guifg=' . s:brightWhite
exec 'hi CompilationWarningLabelsColorSep guibg=' . s:clkLabel. ' guifg=' . s:compWarnLabel
exec 'hi YcmWarningSection guibg=' . s:compWarnLabel

exec 'hi ClockLabelsColor guibg=' . s:clkLabel . ' guifg=' . s:brightWhite
exec 'hi StatusLineNC guifg=' . s:clkLabel . ' cterm=NONE'

"" Returns a status line
function GetStatusLine()
  let s:sts = ""
  let s:showFuncName = 0
  "" Start of main window status line: mode
  let s:currentMode = GetMode()
  if (s:currentMode == 'n')
    let s:sts .= "%#NormalModeColorSepClk#" . "%#NormalModeColor#\ NORMAL\ " . "%#NormalModeColorSep#"
  elseif (s:currentMode == 'v')
    let s:sts .= "%#VisualModeColorSepClk#" . "%#VisualModeColor#\ VISUAL\ " . "%#VisualModeColorSep#"
  elseif (s:currentMode == 'vb')
    let s:sts .= "%#VisualModeColorSepClk#" . "%#VisualModeColor#\ V·BLOCK\ " . "%#VisualModeColorSep#"
  elseif (s:currentMode == 'r')
    let s:sts .= "%#ReplaceModeColorSepClk#" . "%#ReplaceModeColor#\ REPLACE\ " . "%#ReplaceModeColorSep#"
    let s:showFuncName = 1
  elseif (s:currentMode == 'i')
    let s:sts .= "%#InsertModeColorSepClk#" . "%#InsertModeColor#\ INSERT\ " . "%#InsertModeColorSep#"
    let s:showFuncName = 1
  elseif (s:currentMode == 's')
    let s:sts .= "%#SelectModeColorSepClk#" . "%#SelectModeColor#\ SELECT\ " . "%#SelectModeColorSep#"
  else 
    let s:sts .= "%#OtherModeColorSepClk#" . "%#OtherModeColor#\ OTHER\ %#OtherModeColorSep#"
  endif

  let s:middleText = "%#FilenameColor#%F\ "
  if (s:showFuncName == 1) 
    let s:funcProto = Tlist_Get_Tag_Prototype_By_Line()
    if (len(s:funcProto))
      " Show function name instead in insert mode
      let s:middleText = "%#FuncnameColor#↳\ " . RightTruncate(s:funcProto)
    endif
  endif
  let s:sts .= "\ %<%(" . s:middleText . "%)"
 
  "" Left align
  let s:sts .= "%="

  "" file flags colors
  if(&modified)
    let s:sts .= "%#ModFileFlagsColorSep#" . "%#ModFileFlagsColor#\ "
  endif
  
  if(&readonly || &modifiable==0)
    if(&modified)
      let s:sts .= "%#ROFileFlagsColorSepMod#" . "%#ROFileFlagsColor#\ " 
    else
       let s:sts .= "%#ROFileFlagsColorSep#" . "%#ROFileFlagsColor#\ " 
    endif
    let s:sts .= "%#InfoBarColorSepROFlag#"
  else
    if(&modified)
      let s:sts .= "%#InfoBarColorSepModFlag#"
    else
      let s:sts .= "%#InfoBarColorSep#"
    endif
  endif
  

  "" Col, ln & Perc
  let s:sts .= "%#InfoBarColor#\ "

  let s:sts .= "Col %c\ \ "
  let s:sts .= "Ln %l"
  let s:sts .= "\ %#RightCornerColorSep#\ \ %#RightCornerColor#%2P\ "

  "" Taglist status line
  let g:TagListStatusLine = ""
  let s:errorsCount = youcompleteme#GetErrorCount()
  let s:warnsCount = youcompleteme#GetWarningCount()
  if( (s:errorsCount > 0 && s:warnsCount > 0) || s:alwaysShowEW == 1)
    let g:TagListStatusLine = "%#CompilationErrorLabelsColor#\ " . s:errorsCount . "\ "
    let g:TagListStatusLine .= "%#CompilationErrorLabelsColorSepWarn#"
    let g:TagListStatusLine .= "%#CompilationWarningLabelsColor#\ " . s:warnsCount . "\ "
    let g:TagListStatusLine .= "%#CompilationWarningLabelsColorSep#"
  elseif(s:errorsCount > 0)
    let g:TagListStatusLine = "%#CompilationErrorLabelsColor#\ " . s:errorsCount . "\ "
    let g:TagListStatusLine .= "%#CompilationErrorLabelsColorSepClk#"
  elseif(s:warnsCount > 0)
    let g:TagListStatusLine = "%#CompilationWarningLabelsColor#\ " . s:warnsCount . "\ "
    let g:TagListStatusLine .= "%#CompilationWarningLabelsColorSep#"
  endif
  "" Fire redraw status line to update with new value
  let g:TagListStatusLine .= "%#ClockLabelsColor#%=\ " . strftime('%b %d %Y %l:%M %p')  | redraws!

  return s:sts
endfunction

function RightTruncate(str)
  let l:maxlen = &columns - 75
  if (len(a:str) > l:maxlen)
    return strpart(a:str, 0, l:maxlen) . "... "
  endif
  return a:str
endfunction

function GetMode()
  if (mode() == 'n')
    return 'n'
  elseif (mode() == 'v' || mode() == 'V')
    return 'v'
  elseif (mode() == "\<C-V>")
    return 'vb'
  elseif (mode() == 'R')
    return 'r'
  elseif (mode() == 'i')
    return 'i'
  elseif (mode() == 's' || mode() == 'S' || mode() == "\<C-S>")
    return 's'
  endif
  return mode(1)
endfunction

