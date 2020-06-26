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
let s:clkLblColor   = "#0a2c3b"
let s:nLblColor     = "#005F5F"
let s:vLblColor     = "#87005F"
let s:rLblColor     = "#52ba00"
let s:iLblColor     = "#008700"
let s:sLblColor     = "#0056c4"
let s:oLblColor     = "#996BA0"
let s:disLblColor   = "#3f3f45"
let s:flnLblColor   = "#0A2C3B"
let s:mFlgColor     = "#7e7e89"
let s:infBColor     = "#005f87"
let s:disInfBColor  = "#3f3f45"
let s:rcLbl         = "#87005F"

" FG colors
let s:white         = "#fcfcfc"
let s:orange        = "#c66628"
let s:purpel        = "#7f95d0"

" Symbols 
let s:lnumSym       = "Ln"
let s:cnumSym       = "Col"
let s:rASym         = "\ue0b0"
let s:lASym         = "\ue0b2"
let s:tagNameSym    = "\u21b3"
let s:sepASym       = "\ue0b9"
let s:sepBSym       = "\ue0b8"
let s:gitBranchSym  = "\ue0a0"
let s:gitInsSym     = "\u2714"
let s:gitDelSym     = "\u2718"
let s:readonlySym   = "\ue0a2"

"""""""""""""""""""""""""""""""""""""""" Functions
"""""""""""""""""""""""""""""""""""""""" Status line
" If inside git repo, get path relative to git root, otherwise show full path
function s:GetFilename(buf)
    let l:flname = expand("#" . a:buf . ":p")
    if stridx(l:flname, g:TagList_title) != -1
        return g:TagList_title
    endif
    
    if s:GitIsGit(a:buf) == 1
        let l:gitRootDir = s:GitRootDir(a:buf)
        return fnamemodify(l:gitRootDir, ":t") . substitute(l:flname, l:gitRootDir, "", "")
    endif

    return l:flname
endfunction

" Builds mode label
function s:BuildModeLbl(isActiveWindow, nextToTaglist)

    let l:currentMode = mode()

    if (l:currentMode ==? 'n')
        let l:leftPart = (a:nextToTaglist) ? "%#NLblSepClk#". s:lASym : ""
        let l:leftPart .= "%#NLbl#"
        let l:middlePart = " NORMAL "
        let l:rightPart = "%#NLblSepFln#" . s:rASym

    elseif (l:currentMode ==? 'v')
        let l:leftPart = (a:nextToTaglist) ? "%#VLblSepClk#" . s:lASym  : ""
        let l:leftPart .= "%#VLbl#"
        let l:middlePart = " VISUAL "
        let l:rightPart = "%#VLblSepFln#" . s:rASym

    elseif (l:currentMode ==? "\<C-V>")
        let l:leftPart = (a:nextToTaglist) ? "%#VLblSepClk#" . s:lASym : "" 
        let l:leftPart .= "%#VLbl#"
        let l:middlePart = " V·BLOCK "
        let l:rightPart = "%#VLblSepFln#" . s:rASym

    elseif (l:currentMode ==? 'r')
        let l:leftPart = (a:nextToTaglist) ? "%#RLblSepClk#" . s:lASym : ""
        let l:leftPart .= "%#RLbl#"
        let l:middlePart = " REPLACE "
        let l:rightPart = "%#RLblSepFln#" . s:rASym

    elseif (l:currentMode ==? 'i')
        let l:leftPart = (a:nextToTaglist) ? "%#ILblSepClk#" . s:lASym : ""
        let l:leftPart .= "%#ILbl#"
        let l:middlePart = " INSERT "
        let l:rightPart = "%#ILblSepFln#" . s:rASym

    elseif (l:currentMode ==? 's' || l:currentMode == "\<C-S>")
        let l:leftPart = (a:nextToTaglist) ? "%#SLblSepClk#" . s:lASym : ""
        let l:leftPart .= "%#SLbl#"
        let l:middlePart = " SELECT "
        let l:rightPart = "%#SLblSepFln#" . s:rASym

    else 
        let l:leftPart = (a:nextToTaglist) ? "%#OLblSepClk#" . s:lASym : ""
        let l:leftPart  .= "%#OLBL#"
        let l:middlePart = " OTHER "
        let l:rightPart = "%#OLblSepFln#" . s:rASym

    endif
    
    if a:isActiveWindow
        return l:leftPart . l:middlePart . l:rightPart
    else
        return ((a:nextToTaglist) ? "%#DisLblSepClk#" . s:lASym : "") . 
                \ "%#DisLbl#" . l:middlePart . "%#DisLblSepFln#" . s:rASym
    endif
endfunction

" Right truncate str if len(str) > maxlen
function s:RightTruncate(str, maxlen)
    if (len(a:str) > a:maxlen)
        return strpart(a:str, 0, a:maxlen) . "... "
    endif
    return a:str
endfunction

" Builds File name/function name label
function s:BuildFilenameLbl(buf, isActiveWindow)
    let l:bufreadonly = getbufvar(a:buf, "&readonly") || (getbufvar(a:buf, "&modifiable") == 0)
    let l:middleText = "%#FlnLbl#" . s:GetFilename(a:buf)  . " " 
    let l:middleText .= (l:bufreadonly) ? s:readonlySym . " " : ""

    if ((mode() ==? "i" || mode() ==? "r") && a:isActiveWindow) 
        let l:funcProto = Tlist_Get_Tag_Prototype_By_Line()

        if (len(l:funcProto))
            " Show function name instead in insert mode
            let l:middleText = "%#FuncLbl#" . s:tagNameSym . 
                            \ " " . s:RightTruncate(l:funcProto, 
                                        \ (winwidth(0) - ((s:GitIsGit(a:buf) == 1) ? 69 : 45)))
        endif

    endif

    return " %<%(" . l:middleText . "%)"
endfunction

" Builds modified flag
function s:BuildFlags(buf, infBHighlight)
    let l:flags = ""
    let l:bufmodified = getbufvar(a:buf, "&modified")

    if(l:bufmodified)
        " M 
        let l:flags .= "%#MFlagSepFln#" . s:lASym . "%#MFlag# "
        let l:flags .= "%#" . a:infBHighlight . "SepMFlag#"
    else
        "None
        let l:flags .= "%#" . a:infBHighlight . "SepFln#"
    endif

    return l:flags
endfunction

" Builds information bar
function s:BuildInfBar(buf, infBHighlight)
    let l:infBar = s:lASym . "%#" . a:infBHighlight . "# "

    if s:GitIsGit(a:buf) == 1
        let l:infBar .= s:gitBranchSym . " " . s:GitBranchName(a:buf) . s:GitDirty(a:buf)
        let l:infBar .= "%#" . a:infBHighlight . "Strick#" . s:sepASym . "  %#" . a:infBHighlight . "#"
        let l:infBar .= s:gitInsSym . " " . s:GitInsertNum(a:buf) . " "
        let l:infBar .= s:gitDelSym . " " . s:GitDeleteNum(a:buf)
        let l:infBar .= "%#" . a:infBHighlight . "Strick#" . s:sepASym . "  %#" . a:infBHighlight . "#"
    endif
  
    let l:infBar .= s:cnumSym . " %c" . "%#" . a:infBHighlight . "Strick#" . s:sepASym . "  %#" . a:infBHighlight . "#"
    let l:infBar .= s:lnumSym . " %l"
    let l:infBar .= " %#RCSep" . a:infBHighlight . "#" . s:sepBSym . "  %#RC#%2P "
    return l:infBar
endfunction

" Builds the main window status line
function SetStatusLine(winid, nextToTaglist)
    let l:winnum = win_id2win(a:winid)
    let l:buf = winbufnr(l:winnum)
    let l:isActiveWindow = (l:winnum == winnr())

    call s:GitInit(l:buf)

    " Start of main window status line
    " Mode
    let l:sts = s:BuildModeLbl(l:isActiveWindow, a:nextToTaglist)

    " File or function name
    let l:sts .= s:BuildFilenameLbl(l:buf, l:isActiveWindow)
 
    " Left align
    let l:sts .= "%="
    
    let l:infBHighlight = (l:isActiveWindow)? "InfB" : "DisInfB"

    " File flags
    let l:sts .= s:BuildFlags(l:buf, l:infBHighlight)
  
    " Information bar
    let l:sts .= s:BuildInfBar(l:buf, l:infBHighlight)

    return l:sts
endfunction

" Builds taglist's statusline
function SetTaglistSts()

    let l:TaglistStatusLine = ""
    let l:errorsCount = youcompleteme#GetErrorCount()
    let l:warnsCount = youcompleteme#GetWarningCount()

    if( (l:errorsCount > 0 && l:warnsCount > 0) || s:alwaysShowEW == 1)
        let l:TaglistStatusLine = "%#ErrLbl# " . l:errorsCount . " "
        let l:TaglistStatusLine .= "%#ErrLblSepWrn#" . s:rASym
        let l:TaglistStatusLine .= "%#WrnLbl# " . l:warnsCount . " "
        let l:TaglistStatusLine .= "%#WrnLblSepClk#" . s:rASym

    elseif(l:errorsCount > 0)
        let l:TaglistStatusLine = "%#ErrLbl# " . l:errorsCount . " "
        let l:TaglistStatusLine .= "%#ErrLblSepClk#" . s:rASym

    elseif(l:warnsCount > 0)
        let l:TaglistStatusLine = "%#WrnLbl# " . l:warnsCount . " "
        let l:TaglistStatusLine .= "%#WrnLblSepClk#" . s:rASym

    endif

    " Finally, add time
    let l:TaglistStatusLine .= "%#ClkLbl#%= " . strftime('%b %d %Y %l:%M %p') 
    return l:TaglistStatusLine
endfunction

" Manages how status line appear accross all windows.
" Status lines colors will change if the window is active .
" Popup, preview and qf windows will have a straight line as a status line
function s:ManageWinStl()
    let l:isDiff = 0
    let l:bottomRightWin = winnr('$')
    for n in range(1, bottomRightWin)
        let l:isDiff += getwinvar(n, "&diff")
        let l:wintype = win_gettype(n)
        " Ignore popup & autocmd
        if (l:wintype !=# 'popup' || l:wintype !=# 'autocmd')
            let l:bufnum = winbufnr(n)
            let l:winbufname = bufname(l:bufnum)
            let l:winid = win_getid(n)
            let l:isPrv = getwinvar(n, "&pvw")
            let l:isHelp = getbufvar(l:winbufname, "&ft") ==# "help"
            let l:isQf = getwinvar(n, '&syntax') == 'qf'

            if l:winbufname ==# g:TagList_title
                " Set the taglist status line
                call setwinvar(n, '&statusline', "%!SetTaglistSts()")

            elseif l:isPrv || l:isHelp || l:isQf || l:wintype ==# "command"
                call setwinvar(n, '&statusline', "%#StraightLine#%{repeat('━',\ winwidth(win_id2win(".l:winid.")))}")

            elseif (n == l:bottomRightWin) && ((winwidth(n) + winwidth(1) + 1 ) == &columns)
                call setwinvar(n, '&statusline', "%!SetStatusLine(".l:winid.", 1)")
            else
                " Other windows status lines
                call setwinvar(n, '&statusline', "%!SetStatusLine(".l:winid.", 0)")
            end

        endif

    endfor

    " If we are in diff
    if l:isDiff != 0
        " Disable Git, unnecessary overhead
        let s:GitStatus["enabled"] = -1
    endif
endfunction

"""""""""""""""""""""""""""""""""""""" Git Functions
" Global git status for all buffers
let s:GitStatus = {"enabled": 1}
let s:GitNewCache = 1000

" Debug Git
function g:GitDebug()
    echom s:GitStatus
endfunction

" Toggle Git
function s:GitToggleGit()
    let s:GitStatus = {"enabled": s:GitStatus["enabled"] * -1}
endfunction

" Async call back to read tmp file and update s:GitStatus
function g:AsyncGitCallback(isFullUpdate, tmpfile, buf)

    if g:asyncrun_code != 0
        " If, for any reason, the command was not successfull, abort
        let s:GitStatus[a:buf]["LocalEnable"] = -1
        return
    endif

    if !has_key(s:GitStatus, a:buf)
        let s:GitStatus[a:buf] = {"LocalEnable" : 1 ,"IsGit": -1, "RootDir": "", "BranchName": "", 
                                \ "Dirty": "", "InsertNum": 0, "DeleteNum": 0, "CacheExpired": 0}
    endif

    let l:lines = readfile(a:tmpfile)

    let l:maxExpectedLines = 2

    if a:isFullUpdate == 1
        let s:GitStatus[a:buf]["RootDir"] = trim(fnamemodify(l:lines[0], ":h"))
        let s:GitStatus[a:buf]["BranchName"] = trim(fnamemodify(l:lines[1], ":t"))
        let l:maxExpectedLines = 4
    endif

    let s:GitStatus[a:buf]["InsertNum"] = 0
    let s:GitStatus[a:buf]["DeleteNum"] = 0
    let s:GitStatus[a:buf]["Dirty"] = ""

    if len(l:lines) == l:maxExpectedLines
        let s:GitStatus[a:buf]["Dirty"] = "*"
        let l:splitdiff = split(l:lines[l:maxExpectedLines-1])
        let s:GitStatus[a:buf]["InsertNum"] = trim(l:splitdiff[0])
        let s:GitStatus[a:buf]["DeleteNum"] = trim(l:splitdiff[1])
    elseif len(l:lines) == l:maxExpectedLines-1
        let s:GitStatus[a:buf]["Dirty"] = "*"
    endif

    let s:GitStatus[a:buf]["IsGit"] = 1
endfunction

" Full or light update of git information
" If the buffer is new, or it has been a while since updated, it will be full
" update, otherwise, it will be a light update of status and changed lines
" numbers
function s:GitUpdate(initOrWrite, ...)
    let l:buf = get(a:, 1, bufnr())

    if s:GitStatus["enabled"] == -1 || s:GitStatus[l:buf]["LocalEnable"] == -1
        return
    endif
    
    let l:flname = expand("#" . l:buf . ":p")
    let l:parentDir = fnamemodify(l:flname, ":h")
    let l:tmpfile = tempname()
    let l:redir = l:tmpfile ." 2> /dev/null "
    let l:isFullUpdate = a:initOrWrite == 1 || s:GitStatus[l:buf]["IsGit"] == -1 
    let l:cmd = ""
    if l:isFullUpdate
        let l:cmd  = "git -C " . l:parentDir . " rev-parse --absolute-git-dir > " . l:redir . "&& "
        let l:cmd .= "(git -C " . l:parentDir . " symbolic-ref HEAD || " 
        let l:cmd .= "git -C " . l:parentDir . " rev-parse --short HEAD) >> " . l:redir . "&& "
    endif
    let l:cmd .= "([[ -z $(git -C " . l:parentDir . " status -s) ]] || echo '*') >> " . l:redir . "&& "
    let l:cmd .= "git -C " . l:parentDir . " diff --numstat -- " . l:flname . " >> " . l:redir
    
    if g:asyncrun_status != "running"
        " Async call to g:AsyncGitCallback()
        call asyncrun#run("", 
                    \ {"post": "call g:AsyncGitCallback(" . l:isFullUpdate . ", '" . l:tmpfile . "', " .  l:buf . ")"},
                    \ l:cmd)
    else
        " If we could not execute it now, void the cache so that it is executed
        " the next time 
        let s:GitStatus[l:buf]["CacheExpired"] = 0
    endif
endfunction

" Initializes git information
function s:GitInit(buf)

    if !has_key(s:GitStatus, a:buf)
        let s:GitStatus[a:buf] = {"LocalEnable" : 1 ,"IsGit": -1, "RootDir": "", "BranchName": "", 
                                \ "Dirty": "", "InsertNum": 0, "DeleteNum": 0, "CacheExpired": 0}
    endif

    if s:GitStatus["enabled"] == -1 || s:GitStatus[a:buf]["LocalEnable"] == -1
        return
    endif

    let l:flname = expand("#" . a:buf . ":p")
    " If we opened a dir or taglist, ignore.
    if !filereadable(l:flname)
        let s:GitStatus[a:buf]["LocalEnable"] = -1
        return
    endif 

    if s:GitStatus[a:buf]["CacheExpired"] > 0
        " Dont update unless it has been a while
        let s:GitStatus[a:buf]["CacheExpired"] -= 1
        return
    endif

    " Restart Cache after update
    let s:GitStatus[a:buf]["CacheExpired"] = s:GitNewCache

    call s:GitUpdate(1, a:buf)

endfunction

" Whether we are in git repo
function s:GitIsGit(buf)
    return s:GitStatus[a:buf]["IsGit"]
endfunction

" Whether we are in git repo
function s:GitRootDir(buf)
    return s:GitStatus[a:buf]["RootDir"]
endfunction

" Git Branch of current repo
function s:GitBranchName(buf)
    return s:GitStatus[a:buf]["BranchName"]
endfunction

" If repo is dirty
function s:GitDirty(buf)
    return s:GitStatus[a:buf]["Dirty"]
endfunction

" Lines inserted for current file
function s:GitInsertNum(buf)
    return s:GitStatus[a:buf]["InsertNum"]
endfunction

" Lines deleted for current file
function s:GitDeleteNum(buf)
    return s:GitStatus[a:buf]["DeleteNum"]
endfunction
""""""""""""""""""""""""""""""""""""""" Autocmd
" Always show statusline
set laststatus=2

augroup longsts
    autocmd!
    autocmd BufWinEnter,WinEnter,BufDelete,SessionLoadPost,FileChangedShellPost * call s:ManageWinStl()
    " Update git with every write
    autocmd BufWritePost * call s:GitUpdate(-1)
    " GitToggle Command
    command! -nargs=0 -bar GitToggle call s:GitToggleGit()
augroup END

""""""""""""""""""""""""""""""""""""""" Colors of Status line 
" Label colors
" From left to right
exec 'hi! ErrLbl guibg='                    . s:errLblColor     . ' guifg='     . s:white
exec 'hi! ErrLblSepWrn guibg='              . s:warnLblColor    . ' guifg='     . s:errLblColor
exec 'hi! ErrLblSepClk guibg='              . s:clkLblColor     . ' guifg='     . s:errLblColor
exec 'hi! YcmErrorSection guibg='           . s:errLblColor

exec 'hi! WrnLbl guibg='                    . s:warnLblColor    . ' guifg='     . s:white
exec 'hi! WrnLblSepClk guibg='              . s:clkLblColor     . ' guifg='     . s:warnLblColor
exec 'hi! YcmWarningSection guibg='         . s:warnLblColor

exec 'hi! ClkLbl guibg='                    . s:clkLblColor     . ' guifg='     . s:white

exec 'hi! NLbl cterm=bold guibg='           . s:nLblColor       . ' guifg='     . s:white
exec 'hi! NLblSepFln guibg='                . s:flnLblColor     . ' guifg='     . s:nLblColor
exec 'hi! NLblSepClk guibg='                . s:clkLblColor     . ' guifg='     . s:nLblColor

exec 'hi! VLbl cterm=bold guibg='           . s:vLblColor       . ' guifg='     . s:white
exec 'hi! VLblSepFln guibg='                . s:flnLblColor     . ' guifg='     . s:vLblColor
exec 'hi! VLblSepClk guibg='                . s:clkLblColor     . ' guifg='     . s:vLblColor

exec 'hi! RLbl cterm=bold guibg='           . s:rLblColor       . ' guifg='     . s:white
exec 'hi! RLblSepFln guibg='                . s:flnLblColor     . ' guifg='     . s:rLblColor
exec 'hi! RLblSepClk guibg='                . s:clkLblColor     . ' guifg='     . s:rLblColor

exec 'hi! ILbl cterm=bold guibg='           . s:iLblColor       . ' guifg='     . s:white 
exec 'hi! ILblSepFln guibg='                . s:flnLblColor     . ' guifg='     . s:iLblColor
exec 'hi! ILblSepClk guibg='                . s:clkLblColor     . ' guifg='     . s:iLblColor

exec 'hi! SLbl cterm=bold guibg='           . s:sLblColor       . ' guifg='     . s:white
exec 'hi! SLblSepFln guibg='                . s:flnLblColor     . ' guifg='     . s:sLblColor 
exec 'hi! SLblSepClk guibg='                . s:clkLblColor     . ' guifg='     . s:sLblColor

exec 'hi! OLbl cterm=bold guibg='           . s:oLblColor       . ' guifg='     . s:white
exec 'hi! OLblSepFln guibg='                . s:flnLblColor     . ' guifg='     . s:oLblColor 
exec 'hi! OLblSepClk guibg='                . s:clkLblColor     . ' guifg='     . s:oLblColor

exec 'hi! DisLbl cterm=bold guibg='         . s:disLblColor     . ' guifg='     . s:white
exec 'hi! DisLblSepFln guibg='              . s:flnLblColor     . ' guifg='     . s:disLblColor 
exec 'hi! DisLblSepClk guibg='              . s:clkLblColor     . ' guifg='     . s:disLblColor

exec 'hi! FlnLbl cterm=None guibg='         . s:flnLblColor     . ' guifg='     . s:white
exec 'hi! FuncLbl cterm=None guibg='        . s:flnLblColor     . ' guifg='     . s:orange


exec 'hi! MFlag cterm=bold guibg='          . s:mFlgColor 
exec 'hi! MFlagSepFln guibg='               . s:flnLblColor     . ' guifg='      . s:mFlgColor

exec 'hi! InfB cterm=bold guibg='           . s:infBColor       . ' guifg='      . s:white
exec 'hi! InfBStrick cterm=bold guibg='     . s:infBColor       . ' guifg='      . s:flnLblColor
exec 'hi! InfBSepMFlag guibg='              . s:mFlgColor       . ' guifg='      . s:infBColor
exec 'hi! InfBSepFln guibg='                . s:flnLblColor     . ' guifg='      . s:infBColor

exec 'hi! DisInfB cterm=bold guibg='        . s:disInfBColor    . ' guifg='      . s:white
exec 'hi! DisInfBStrick cterm=bold guibg='  . s:disInfBColor    . ' guifg='      . s:flnLblColor
exec 'hi! DisInfBSepMFlag guibg='           . s:mFlgColor       . ' guifg='      . s:disInfBColor
exec 'hi! DisInfBSepFln guibg='             . s:flnLblColor     . ' guifg='      . s:disInfBColor

exec 'hi! RC cterm=bold guibg='             . s:rcLbl           . ' guifg='      . s:white
exec 'hi! RCSepInfB guibg='                 . s:rcLbl           . ' guifg='      . s:infBColor
exec 'hi! RCSepDisInfB guibg='              . s:rcLbl           . ' guifg='      . s:disInfBColor

" Hide status line main colors
exec 'hi! StatusLine guifg='                . s:flnLblColor     . ' guibg='      .s:flnLblColor 
exec 'hi! StatusLineNC guibg='              .s:flnLblColor      . ' guifg='      .s:flnLblColor

exec 'hi! StraightLine guifg='              . s:purpel          . ' guibg='      . s:flnLblColor
exec 'hi! VertSplit guibg='                 . s:purpel          . ' guifg='      . s:flnLblColor

" Background Colors
unlet s:nLblColor s:iLblColor s:rLblColor s:vLblColor s:sLblColor s:oLblColor s:disLblColor s:flnLblColor s:mFlgColor s:infBColor s:disInfBColor s:rcLbl s:errLblColor s:warnLblColor s:clkLblColor s:white s:orange s:purpel


