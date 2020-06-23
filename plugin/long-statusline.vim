"" Vim plugin file
" Long status line
" Author: Mansour Alharthi <man9our.ah@gmail.com>

""""""""""""""""""""""""""""""""""""""" Config
" Error & Warn: 0=> only show when > 0
let s:alwaysShowEW = 1

" Background Colors
" From left to right
let s:errLblColor   = "#af0000"
let s:warnLblColor  = "#ff8700"
let s:clkLblColor   = "#082430"
let s:nLblColor     = "#005F5F" "#005f87
let s:vLblColor     = "#87005F"
let s:rLblColor     = "#52ba00"
let s:iLblColor     = "#008700"
let s:sLblColor     = "#0056c4"
let s:oLblColor     = "#996BA0"
let s:flnLblColor   = "#082430"
let s:mFlgColor     = "#7e7e89"
let s:rFlgColor     = "#3f3f45"
let s:infBColor     = "#005f87" "#005F5F
let s:rcLbl         = "#87005F"

" FG colors
let s:white         = "#fcfcfc"
let s:orange        = "#c66628"

" Symbols 
let s:gitBranchSym  = "\ue0a0"
let s:lnumSym       = "Ln"
let s:cnumSym       = "Col"
let s:rASym         = "\ue0b0"
let s:lASym         = "\ue0b2"
let s:tagNameSym    = "\u21b3"
let s:sepASym       = "\ue0b9"
let s:sepBSym       = "\ue0b8"
let s:gitInsSym     = "\u2714"
let s:gitDelSym     = "\u2718"

"""""""""""""""""""""""""""""""""""""""" Functions
" Git status variables 
let s:gitShow = 0
let s:gitRootDir = ""
let s:gitBranchName = ""
let s:gitInsertNum = 0
let s:gitDeleteNum = 0

" If inside git repo, get path relative to git root, otherwise show full path
function s:GetFilename()

    if s:gitShow == 1
        return fnamemodify(s:gitRootDir, ":t") . substitute(expand("%:p"), s:gitRootDir, "", "")
    endif

    return expand("%:p")
endfunction

" Sets s:gitRootDir
function s:SetGitRootDir(parentDir)
    let l:dotGitDir = system("git -C " . a:parentDir . " rev-parse --absolute-git-dir")
    if v:shell_error != 0
        let s:gitShow = 0
        return 0
    endif

    let s:gitRootDir = trim(fnamemodify(l:dotGitDir, ":h"))

    return 1
endfunction

" Sets s:gitBranchName
function s:SetGitBranchName(parentDir)
    let l:fullBranchName = system("git -C " . a:parentDir . " symbolic-ref HEAD")
    if v:shell_error != 0

        " Try commit hash
        let s:gitBranchName = system("git -C " . a:parentDir . " rev-parse --short HEAD")
        if v:shell_error != 0
            " Nothing works, abort 
            let s:gitShow = 0
            return 0
        endif

    else
        let s:gitBranchName = fnamemodify(l:fullBranchName, ":t")
    endif

    let s:gitBranchName = trim(s:gitBranchName)

    " Append a star after branch name if repo is dirty
    let l:gitSts = system("git -C " . a:parentDir . " status -s")
    if v:shell_error != 0
        let s:gitShow = 0
        return 0
    endif

    if len(trim(l:gitSts)) != 0
        let s:gitBranchName .= "*"
    endif

    return 1
endfunction

" Sets s:gitInsertNum & s:gitDeleteNum
function s:SetGitChangeNum(parentDir)
    let l:gitDiffRaw = trim(system("git -C " . a:parentDir . " diff --numstat -- " . expand("%:p")))
    if v:shell_error != 0
        let s:gitShow = 0
        return 0
    endif

    if len(l:gitDiffRaw) == 0
        let s:gitInsertNum = 0
        let s:gitDeleteNum = 0
    else
        let l:splitDiff = split(l:gitDiffRaw)
        let s:gitInsertNum = l:splitDiff[0]
        let s:gitDeleteNum = l:splitDiff[1]
    endif

    return 1
endfunction

" Updates Git status variables
" Should be called via autocmd BufEnter and BufWritePost 
function s:GitUpdateInfo()
    let l:flname = expand("%:p")
    " If we opened a dir, ignore.
    if !filereadable(l:flname)
        return
    endif 

    " Parent of current file
    let l:parentDir = fnamemodify(l:flname, ":h")

    " Set the git root dir
    if s:SetGitRootDir(l:parentDir) == 0
        return
    endif

    " Set git branch
    if s:SetGitBranchName(l:parentDir) == 0
        return
    endif

    " Set the number of line changes
    if s:SetGitChangeNum(l:parentDir) == 0
        return
    endif

    " Now we can show git status
    let s:gitShow = 1
endfunction

" Builds taglist's statusline
function s:SetTaglistSts()

    let g:TaglistStatusLine = ""
    let l:errorsCount = youcompleteme#GetErrorCount()
    let l:warnsCount = youcompleteme#GetWarningCount()

    if( (l:errorsCount > 0 && l:warnsCount > 0) || s:alwaysShowEW == 1)
        let g:TaglistStatusLine = "%#ErrLbl# " . l:errorsCount . " "
        let g:TaglistStatusLine .= "%#ErrLblSepWrn#" . s:rASym
        let g:TaglistStatusLine .= "%#WrnLbl# " . l:warnsCount . " "
        let g:TaglistStatusLine .= "%#WrnLblSepClk#" . s:rASym

    elseif(l:errorsCount > 0)
        let g:TaglistStatusLine = "%#ErrLbl# " . l:errorsCount . " "
        let g:TaglistStatusLine .= "%#ErrLblSepClk#" . s:rASym

    elseif(l:warnsCount > 0)
        let g:TaglistStatusLine = "%#WrnLbl# " . l:warnsCount . " "
        let g:TaglistStatusLine .= "%#WrnLblSepClk#" . s:rASym

    endif

    " Fire redraw status line to update with new value
    let g:TaglistStatusLine .= "%#ClkLbl#%= " . strftime('%b %d %Y %l:%M %p')  | redraws!
endfunction

" Builds mode label
function s:BuildModeLbl()
    let l:currentMode = mode()
    let l:modeLbl = ""

    if (l:currentMode ==? 'n')
        let l:modeLbl .= "%#NLblSepClk#". s:lASym   . "%#NLbl# NORMAL %#NLblSepFln#"    . s:rASym

    elseif (l:currentMode ==? 'v')
        let l:modeLbl .= "%#VLblSepClk#" . s:lASym  . "%#VLbl# VISUAL %#VLblSepFln#"    . s:rASym

    elseif (l:currentMode ==? "\<C-V>")
        let l:modeLbl .= "%#VLblSepClk#" . s:lASym  . "%#VLbl# V·BLOCK %#VLblSepFln#"   . s:rASym

    elseif (l:currentMode ==? 'r')
        let l:modeLbl .= "%#RLblSepClk#" . s:lASym  . "%#RLbl# REPLACE %#RLblSepFln#"   . s:rASym

    elseif (l:currentMode ==? 'i')
        let l:modeLbl .= "%#ILblSepClk#" . s:lASym  . "%#ILbl# INSERT %#ILblSepFln#"    . s:rASym

    elseif (l:currentMode ==? 's' || l:currentMode == "\<C-S>")
        let l:modeLbl .= "%#SLblSepClk#" . s:lASym  . "%#SLbl# SELECT %#SLblSepFln#"    . s:rASym

    else 
        let l:modeLbl .= "%#OLblSepClk#" . s:lASym . "%#OLBL# OTHER %#OLblSepFln#" . s:rASym

    endif

    return l:modeLbl
endfunction

" Right truncate str if len(str) > maxlen
function s:RightTruncate(str, maxlen)
    if (len(a:str) > a:maxlen)
        return strpart(a:str, 0, a:maxlen) . "... "
    endif
    return a:str
endfunction

" Builds File name/function name label
function s:BuildFilenameLbl()
    let l:middleText = "%#FlnLbl#" . s:GetFilename()  . " "
    if (mode() ==? "i" || mode() ==? "r") 
        let l:funcProto = Tlist_Get_Tag_Prototype_By_Line()

        if (len(l:funcProto))
            " Show function name instead in insert mode
            let l:middleText = "%#FuncLbl#" . s:tagNameSym . 
                            \ " " . s:RightTruncate(l:funcProto, 
                                        \ (winwidth(0) - ((s:gitShow == 0)? 45 : 69)))
      endif

    endif
    return " %<%(" . l:middleText . "%)"
endfunction

" Builds ReadOnly & Modified flags
function s:BuildFlags()
    let l:flags = ""
    if(&modified)
        let l:flags .= "%#MFlagSepFln#" . s:lASym . "%#MFlag# "
    endif
    
    if(&readonly || &modifiable==0)
        if(&modified)
            " M & RO
            let l:flags .= "%#RFlagSepMod#" . s:lASym . "%#RFlag# " 
        else
            " RO
            let l:flags .= "%#RFlagSepFln#" . s:lASym . "%#RFlag# " 
        endif
        let l:flags .= "%#InfBSepRFlag#"
    else
        if(&modified)
            " M 
            let l:flags .= "%#InfBSepMFlag#"
        else
            "None
            let l:flags .= "%#InfBSepFln#"
        endif
    endif
    return l:flags
endfunction

" Builds information bar
function s:BuildInfBar()
    let l:infBar = s:lASym . "%#InfB# "
  
    if s:gitShow == 1
        let l:infBar .= s:gitBranchSym . " " . s:gitBranchName 
        let l:infBar .= "%#InfBStrick#" . s:sepASym . "  %#InfB#"
        let l:infBar .= s:gitInsSym . " " . s:gitInsertNum . " "
        let l:infBar .= s:gitDelSym . " " . s:gitDeleteNum 
        let l:infBar .= "%#InfBStrick#" . s:sepASym . "  %#InfB#"
    endif
  
    let l:infBar .= s:cnumSym . " %c" . "%#InfBStrick#" . s:sepASym . "  %#InfB#"
    let l:infBar .= s:lnumSym . " %l"
    let l:infBar .= " %#RCSepInfB#" . s:sepBSym . "  %#RC#%2P "
    return l:infBar
endfunction

" Builds the main window status line
function SetStatusLine()
    " Starting from the left:
    " Taglist status line
    call s:SetTaglistSts()

    " Start of main window status line
    " Mode
    let l:sts   = s:BuildModeLbl()

    " File of function name
    let l:sts  .= s:BuildFilenameLbl()
 
    " Left align
    let l:sts .= "%="
    
    " File flags
    let l:sts .= s:BuildFlags()
  
    " Information bar
    let l:sts .= s:BuildInfBar()

    return l:sts
endfunction

""""""""""""""""""""""""""""""""""""""" Colors
" Label colors
" From left to right
exec 'hi! ErrLbl guibg='                . s:errLblColor     . ' guifg='     . s:white
exec 'hi! ErrLblSepWrn guibg='          . s:warnLblColor    . ' guifg='     . s:errLblColor
exec 'hi! ErrLblSepClk guibg='          . s:clkLblColor     . ' guifg='     . s:errLblColor
exec 'hi! YcmErrorSection guibg='       . s:errLblColor

exec 'hi! WrnLbl guibg='                . s:warnLblColor    . ' guifg='     . s:white
exec 'hi! WrnLblSepClk guibg='          . s:clkLblColor     . ' guifg='     . s:warnLblColor
exec 'hi! YcmWarningSection guibg='     . s:warnLblColor

exec 'hi! ClkLbl guibg='                . s:clkLblColor     . ' guifg='     . s:white

exec 'hi! NLbl cterm=bold guibg='       . s:nLblColor       . ' guifg='     . s:white
exec 'hi! NLblSepFln guibg='            . s:flnLblColor     . ' guifg='     . s:nLblColor
exec 'hi! NLblSepClk guibg='            . s:clkLblColor     . ' guifg='     . s:nLblColor

exec 'hi! VLbl cterm=bold guibg='       . s:vLblColor       . ' guifg='     . s:white
exec 'hi! VLblSepFln guibg='            . s:flnLblColor     . ' guifg='     . s:vLblColor
exec 'hi! VLblSepClk guibg='            . s:clkLblColor     . ' guifg='     . s:vLblColor

exec 'hi! RLbl cterm=bold guibg='       . s:rLblColor       . ' guifg='     . s:white
exec 'hi! RLblSepFln guibg='            . s:flnLblColor     . ' guifg='     . s:rLblColor
exec 'hi! RLblSepClk guibg='            . s:clkLblColor     . ' guifg='     . s:rLblColor

exec 'hi! ILbl cterm=bold guibg='       . s:iLblColor       . ' guifg='     . s:white 
exec 'hi! ILblSepFln guibg='            . s:flnLblColor     . ' guifg='     . s:iLblColor
exec 'hi! ILblSepClk guibg='            . s:clkLblColor     . ' guifg='     . s:iLblColor

exec 'hi! SLbl cterm=bold guibg='       . s:sLblColor       . ' guifg='     . s:white
exec 'hi! SLblSepFln guibg='            . s:flnLblColor     . ' guifg='     . s:sLblColor 
exec 'hi! SLblSepClk guibg='            . s:clkLblColor     . ' guifg='     . s:sLblColor

exec 'hi! OLbl cterm=bold guibg='       . s:oLblColor       . ' guifg='     . s:white
exec 'hi! OLblSepFln guibg='            . s:flnLblColor     . ' guifg='     . s:oLblColor 
exec 'hi! OLblSepClk guibg='            . s:clkLblColor     . ' guifg='     . s:oLblColor

exec 'hi! FlnLbl cterm=None guibg='     . s:flnLblColor     . ' guifg='     . s:white
exec 'hi! FuncLbl cterm=None guibg='    . s:flnLblColor     . ' guifg='     . s:orange


exec 'hi! MFlag cterm=bold guibg='      . s:mFlgColor 
exec 'hi! MFlagSepFln guibg='           . s:flnLblColor     . ' guifg='      . s:mFlgColor

exec 'hi! RFlag cterm=bold guibg='      . s:rFlgColor 
exec 'hi! RFlagSepMod guibg='           . s:mFlgColor       . ' guifg='      . s:rFlgColor
exec 'hi! RFlagSepFln guibg='           . s:flnLblColor     . ' guifg='      . s:rFlgColor

exec 'hi! InfB cterm=bold guibg='       . s:infBColor       . ' guifg='      . s:white
exec 'hi! InfBStrick cterm=bold guibg=' . s:infBColor       . ' guifg='      . s:flnLblColor
exec 'hi! InfBSepMFlag guibg='          . s:mFlgColor       . ' guifg='      . s:infBColor
exec 'hi! InfBSepRFlag guibg='          . s:rFlgColor       . ' guifg='      . s:infBColor
exec 'hi! InfBSepFln guibg='            . s:flnLblColor     . ' guifg='      . s:infBColor

exec 'hi! RC cterm=bold guibg='         . s:rcLbl           . ' guifg='      . s:white
exec 'hi! RCSepInfB guibg='             . s:rcLbl           . ' guifg='      . s:infBColor

exec 'hi! StatusLineNC guifg='          . s:clkLblColor     . ' cterm=NONE'

" Background Colors
unlet s:nLblColor s:iLblColor s:rLblColor s:vLblColor s:sLblColor s:oLblColor s:flnLblColor s:mFlgColor s:rFlgColor s:infBColor s:rcLbl s:errLblColor s:warnLblColor s:clkLblColor s:white s:orange

""""""""""""""""""""""""""""""""""""""" Autocmd
" Always show statusline
set laststatus=2

" Set the statusline for all windows
set statusline=%!SetStatusLine()

" Set the statusline for taglist window
let g:TaglistStatusLine = "" " Eval this var everytime main status line is updated
augroup longsts
    autocmd!
    " For taglist, set its stl to TaglistStatusLine
    autocmd FileType taglist setlocal statusline=%!g:TaglistStatusLine
    autocmd BufEnter,BufWritePost * call s:GitUpdateInfo()
augroup END
