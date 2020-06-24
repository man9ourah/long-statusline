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
let s:nLblColor     = "#005F5F"
let s:vLblColor     = "#87005F"
let s:rLblColor     = "#52ba00"
let s:iLblColor     = "#008700"
let s:sLblColor     = "#0056c4"
let s:oLblColor     = "#996BA0"
let s:flnLblColor   = "#082430"
let s:mFlgColor     = "#7e7e89"
let s:rFlgColor     = "#3f3f45"
let s:infBColor     = "#005f87"
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
function s:BuildModeLbl(buf, singleStl)
    " If there are multiple status lines, then only output mode for current
    " window
    if a:singleStl != 1 && a:buf != bufnr("%")
        return
    endif

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
function s:BuildFilenameLbl(buf, singleStl)

    let l:middleText = "%#FlnLbl#" . s:GetFilename(a:buf)  . " "
    if ((mode() ==? "i" || mode() ==? "r") && a:singleStl == 1) 
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

" Builds ReadOnly & Modified flags
function s:BuildFlags(buf)
    let l:flags = ""
    let l:bufmodified = getbufvar(a:buf, "&modified")
    let l:bufreadonly = getbufvar(a:buf, "&readonly") || getbufvar(a:buf, "&modifiable") == 0

    if(l:bufmodified)
        let l:flags .= "%#MFlagSepFln#" . s:lASym . "%#MFlag# "
    endif
    
    if(l:bufreadonly)
        if(l:bufmodified)
            " M & RO
            let l:flags .= "%#RFlagSepMod#" . s:lASym . "%#RFlag# " 
        else
            " RO
            let l:flags .= "%#RFlagSepFln#" . s:lASym . "%#RFlag# " 
        endif
        let l:flags .= "%#InfBSepRFlag#"
    else
        if(l:bufmodified)
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
function s:BuildInfBar(buf)
    let l:infBar = s:lASym . "%#InfB# "

    if s:GitIsGit(a:buf) == 1
        let l:infBar .= s:gitBranchSym . " " . s:GitBranchName(a:buf) . s:GitDirty(a:buf)
        let l:infBar .= "%#InfBStrick#" . s:sepASym . "  %#InfB#"
        let l:infBar .= s:gitInsSym . " " . s:GitInsertNum(a:buf) . " "
        let l:infBar .= s:gitDelSym . " " . s:GitDeleteNum(a:buf)
        let l:infBar .= "%#InfBStrick#" . s:sepASym . "  %#InfB#"
    endif
  
    let l:infBar .= s:cnumSym . " %c" . "%#InfBStrick#" . s:sepASym . "  %#InfB#"
    let l:infBar .= s:lnumSym . " %l"
    let l:infBar .= " %#RCSepInfB#" . s:sepBSym . "  %#RC#%2P "
    return l:infBar
endfunction

" Builds the main window status line
function SetStatusLine(...)
    let l:buf = get(a:, 1, bufnr())
    let l:singleStl = get(a:, 2, 1)

    call s:GitInit(l:buf)

    " Start of main window status line
    " Mode
    let l:sts = s:BuildModeLbl(l:buf, l:singleStl)

    " File or function name
    let l:sts .= s:BuildFilenameLbl(l:buf, l:singleStl)
 
    " Left align
    let l:sts .= "%="
    
    " File flags
    let l:sts .= s:BuildFlags(l:buf)
  
    " Information bar
    let l:sts .= s:BuildInfBar(l:buf)

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
" Only two possible layouts: 
" if we are in diff mode: both windows will have their own statusline, and
" taglist is off.
" Otherwise, only the bottom right window will have a long status line that
" shows the information for whatever the current window and other windows will
" have a straight line instead
function s:ManageWinStl()
    let l:isDiff = 0
    let l:bottomRightWin = winnr('$')
    for n in range(1, bottomRightWin)
        let l:isDiff += getwinvar(n, "&diff")
        let l:wintype = win_gettype(n)
        " Ignore popup & autocmd
        if (l:wintype !=# 'popup' || l:wintype !=# 'autocmd' || l:wintype !=# "command")
            let l:bufnum = winbufnr(n)
            let l:winbufname = bufname(l:bufnum)

            if l:winbufname ==# g:TagList_title
                " Set the taglist status line
                call setwinvar(n, '&statusline', "%!SetTaglistSts()")

            elseif (n == bottomRightWin)
                " Set bottom right Window with full status line for all windows
                call setwinvar(n, '&statusline', "%!SetStatusLine()")
            
            else
                " Otherwise status line should be straight line
                call setwinvar(n, '&statusline', "%#StraightLine#%{repeat('━',\ winwidth(".n."))}")
              
            end

        endif

    endfor

    " If we are in diff
    if l:isDiff != 0
        let s:GitStatus["enabled"] = -1
        for n in range(1, winnr('$'))
            if (l:wintype !=# 'popup' || l:wintype !=# 'autocmd' || l:wintype !=# "command")
                let l:bufnum = winbufnr(n)
                call setwinvar(n, '&statusline', "%!SetStatusLine(" . l:bufnum . ", -1)")
            endif
        endfor
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
function g:AsyncGitCallback()
    let l:res = split(g:asyncrun_text, ":")
    let l:isFullUpdate = (l:res[0] == "1") ? 1 : -1
    let l:tmpfile = l:res[1]
    let l:buf = l:res[2]

    if g:asyncrun_code != 0
        " If, for any reason, the command was not successfull, abort
        call system("rm " . l:tmpfile . " &")
        let s:GitStatus["enabled"] = -1
        return
    endif

    if !has_key(s:GitStatus, l:buf)
        let s:GitStatus[l:buf] = {"IsGit": -1, "RootDir": "", "BranchName": "", "Dirty": "",
                                \ "InsertNum": 0, "DeleteNum": 0, "CacheExpired": 0}
    endif

    let l:lines = readfile(l:tmpfile)

    let l:maxExpectedLines = 2

    if l:isFullUpdate == 1
        let s:GitStatus[l:buf]["RootDir"] = trim(fnamemodify(l:lines[0], ":h"))
        let s:GitStatus[l:buf]["BranchName"] = trim(fnamemodify(l:lines[1], ":t"))
        let l:maxExpectedLines = 4
    endif

    let s:GitStatus[l:buf]["InsertNum"] = 0
    let s:GitStatus[l:buf]["DeleteNum"] = 0
    let s:GitStatus[l:buf]["Dirty"] = ""

    if len(l:lines) == l:maxExpectedLines
        let s:GitStatus[l:buf]["Dirty"] = "*"
        let l:splitdiff = split(l:lines[l:maxExpectedLines-1])
        let s:GitStatus[l:buf]["InsertNum"] = trim(l:splitdiff[0])
        let s:GitStatus[l:buf]["DeleteNum"] = trim(l:splitdiff[1])
    elseif len(l:lines) == l:maxExpectedLines-1
        let s:GitStatus[l:buf]["Dirty"] = "*"
    endif

    let s:GitStatus[l:buf]["IsGit"] = 1
    call system("rm " . l:tmpfile . " &")
endfunction

" Full or light update of git information
" If the buffer is new, or it has been a while since updated, it will be full
" update, otherwise, it will be a light update of status and changed lines
" numbers
function s:GitUpdate(isFullUpdate, ...)
    if s:GitStatus["enabled"] == -1
        return
    endif

    let l:buf = get(a:, 1, bufnr())
    let l:flname = expand("#" . l:buf . ":p")
    let l:parentDir = fnamemodify(l:flname, ":h")
    let l:tmpfile = tempname()
    let l:redir = l:tmpfile ." 2> /dev/null "

    let l:cmd = ""
    if a:isFullUpdate == 1
        let l:cmd  = "git -C " . l:parentDir . " rev-parse --absolute-git-dir > " . l:redir . "&& "
        let l:cmd .= "(git -C " . l:parentDir . " symbolic-ref HEAD || " 
        let l:cmd .= "git -C " . l:parentDir . " rev-parse --short HEAD) >> " . l:redir . "&& "
    endif
    let l:cmd .= "([[ -z $(git -C " . l:parentDir . " status -s) ]] || echo '*') >> " . l:redir . "&& "
    let l:cmd .= "git -C " . l:parentDir . " diff --numstat -- " . l:flname . " >> " . l:redir
    
    if g:asyncrun_status != "running"
        " Async call to g:AsyncGitCallback()
        exec "AsyncRun -post=call\\ g:AsyncGitCallback() " .
                            \ "-text=" . a:isFullUpdate . ":" . l:tmpfile . ":" . l:buf . " " .
                            \ l:cmd
    endif
endfunction

" Initializes git information
function s:GitInit(buf)

    if !has_key(s:GitStatus, a:buf)
        let s:GitStatus[a:buf] = {"IsGit": -1, "RootDir": "", "BranchName": "", "Dirty": "",
                                \ "InsertNum": 0, "DeleteNum": 0, "CacheExpired": 0}
    endif

    if s:GitStatus["enabled"] == -1
        return
    endif

    let l:flname = expand("#" . a:buf . ":p")
    " If we opened a dir or taglist, ignore.
    if !filereadable(l:flname)
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
    " Call our status line manager
    autocmd WinEnter,BufEnter,BufDelete,SessionLoadPost,FileChangedShellPost * call s:ManageWinStl()
    " Update git with every write
    autocmd BufWritePost * call s:GitUpdate(-1)
    " GitToggle Command
    command! -nargs=0 -bar GitToggle call s:GitToggleGit()
augroup END

""""""""""""""""""""""""""""""""""""""" Colors of Status line 
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

exec 'hi! StraightLine guifg='          . s:purpel         . ' guibg='      . s:flnLblColor
exec 'hi! VertSplit guibg='             . s:purpel         . ' guifg='      . s:flnLblColor

" Background Colors
unlet s:nLblColor s:iLblColor s:rLblColor s:vLblColor s:sLblColor s:oLblColor s:flnLblColor s:mFlgColor s:rFlgColor s:infBColor s:rcLbl s:errLblColor s:warnLblColor s:clkLblColor s:white s:orange s:purpel


