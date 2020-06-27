"" Vim plugin file
" Long status line
" Author: Mansour Alharthi <man9our.ah@gmail.com>

""""""""""""""""""""""""""""""""""""""" Global Variables
" Dont load more than once
if exists('g:loaded_statusline')
  finish
endif
let g:loaded_statusline = 1

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
let s:gitUnTckSym   = "??"
let s:readonlySym   = "\ue0a2"

" Global git status for all buffers
let s:GitStatus = {"enabled": 1}
" How many times until we update Git information without a write
let s:GitMaxCacheExp = 1000

"""""""""""""""""""""""""""""""""""""""" Functions
"""""""""""""""" Util
" Right truncate str if len(str) > maxlen
function s:RightTruncate(str, maxlen)
    if (len(a:str) > a:maxlen)
        return strpart(a:str, 0, a:maxlen) . "... "
    endif

    return a:str
endfunction

" If inside git repo, get path relative to git root, otherwise show full path
function s:GetFilename(buf)
    let l:flname = expand("#" . a:buf . ":p")
    
    if s:GitStatus[a:buf]["IsGit"]
        return fnamemodify(s:GitStatus[a:buf]["RootDir"], ":t") . 
                    \ substitute(l:flname, s:GitStatus[a:buf]["RootDir"], "", "")
    endif

    return l:flname
endfunction

""""""""""""""" Status line Components
" Builds file name & function name label
function s:BuildFilenameLbl(buf, isActiveWindow)
    let l:bufreadonly = getbufvar(a:buf, "&readonly") || 
                \ (getbufvar(a:buf, "&modifiable") == 0)

    let l:middleText = "%#FlnLbl#" . s:GetFilename(a:buf)  . " " . 
                \ ((l:bufreadonly) ? s:readonlySym . " " : "")

    let l:md = mode()
    if (l:md ==? "i" || l:md ==# "R") && (a:isActiveWindow)
        " Consult Taglist about nearby tag
        let l:funcProto = Tlist_Get_Tag_Prototype_By_Line()

        if (len(l:funcProto))
            " Show function name instead in insert or replace mode
            let l:middleText = "%#FuncLbl#" . s:tagNameSym . 
                        \ " " . s:RightTruncate(l:funcProto, 
                        \ (winwidth(0) - ((s:GitStatus[a:buf]["IsGit"]) ? 69 : 45)))

        endif

    endif

    return " %<%(" . l:middleText . "%)"
endfunction

" Builds information bar [Git, Col&Ln, Percentage]
function s:BuildInfBar(buf, isActiveWindow)
    let l:infBHighlight = (a:isActiveWindow)? "InfB" : "DisInfB"
    let l:infBar = s:lASym . "%#" . l:infBHighlight . "# "

    if s:GitStatus[a:buf]["IsGit"]
        let l:infBar .= s:gitBranchSym . " " . 
                    \ s:GitStatus[a:buf]["BranchName"] . s:GitStatus[a:buf]["Dirty"]

        let l:infBar .= "%#" . l:infBHighlight . "Strick#" . 
                    \ s:sepASym . "  %#" . l:infBHighlight . "#"
        
        if s:GitStatus[a:buf]["IsTracked"]
            let l:infBar .= s:gitInsSym . " " . s:GitStatus[a:buf]["InsertNum"] . " "
            let l:infBar .= s:gitDelSym . " " . s:GitStatus[a:buf]["DeleteNum"]
        else
            let l:infBar .= s:gitUnTckSym
        endif

        let l:infBar .= "%#" . l:infBHighlight . "Strick#" . 
                    \ s:sepASym . "  %#" . l:infBHighlight . "#"

    endif
  
    let l:infBar .= s:cnumSym . " %c" . "%#" . l:infBHighlight . 
                \ "Strick#" . s:sepASym . "  %#" . l:infBHighlight . "#"

    let l:infBar .= s:lnumSym . " %l"
    let l:infBar .= " %#RCSep" . l:infBHighlight . "#" . 
                \ s:sepBSym . "  %#RC#%2P "

    return l:infBar
endfunction

" Builds the status line
function SetStatusLine(winid, nextToTaglist)
    let l:winnum = win_id2win(a:winid)
    let l:buf = winbufnr(l:winnum)
    let l:isActiveWindow = (l:winnum == winnr())
    
    " Initialize Git
    call s:GitInit(l:buf)

    " Mode
    let l:sts = s:modeMap[l:isActiveWindow][a:nextToTaglist][mode()]

    " File or function name
    let l:sts .= s:BuildFilenameLbl(l:buf, l:isActiveWindow)
 
    " Left align
    let l:sts .= "%="
    

    " Modified flag
    let l:sts .= s:modifiedFlag[getbufvar(l:buf, "&modified")][l:isActiveWindow]
  
    " Information bar
    let l:sts .= s:BuildInfBar(l:buf, l:isActiveWindow)

    return l:sts
endfunction

" Builds taglist's statusline
function SetTaglistSts()
    return "%#ErrLbl# " . youcompleteme#GetErrorCount() . " " . 
                \ "%#ErrLblSepWrn#" . s:rASym . 
                \ "%#WrnLbl# " . youcompleteme#GetWarningCount() . " " . 
                \ "%#WrnLblSepClk#" . s:rASym . 
                \ "%#ClkLbl#%= " . strftime('%b %d %Y %l:%M %p')
endfunction

" Status lines manager
function s:ManageWinStl()
    let l:bottomRightWin = winnr('$')
    let l:taglistWin = -1

    for n in range(1, bottomRightWin)
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
                let l:taglistWin = n

            elseif l:isPrv || l:isHelp || l:isQf || l:wintype ==# "command"
                " Set straight line
                call setwinvar(n, '&statusline', 
                            \ "%#StraightLine#%{" . 
                            \ "repeat('━',\ winwidth(win_id2win(".l:winid.")))" . 
                            \ "}")

            elseif (n == l:bottomRightWin) && 
                        \ ((winwidth(n) + winwidth(1) + 1 ) == &columns) && 
                        \ l:taglistWin == 1

                " Only two windows in the bottom
                " Two arrows for mode label
                call setwinvar(n, '&statusline', "%!SetStatusLine(".l:winid.", 1)")

            else
                " Other windows status lines
                call setwinvar(n, '&statusline', "%!SetStatusLine(".l:winid.", 0)")
            end

        endif

    endfor
endfunction

"""""""""""""""" Git
" Debug Git
function g:GitDebug()
    echom s:GitStatus
endfunction

" Toggle Git
function s:GitToggleGit()
    let s:GitStatus = {"enabled": 1 - s:GitStatus["enabled"] }
endfunction

" Async call back to read tmp file and update s:GitStatus
function g:AsyncGitCallback(isFullUpdate, tmpfile, buf)

    if g:asyncrun_code != 0
        " If, for any reason, the command was not successfull, abort
        let s:GitStatus[a:buf]["LocalEnable"] = 0
        return
    endif

    if !has_key(s:GitStatus, a:buf)
        let s:GitStatus[a:buf] = {"LocalEnable" : 1 ,"IsGit": 0, "RootDir": "", "BranchName": "", 
                                \ "Dirty": "", "IsTracked": 0, "InsertNum": 0, "DeleteNum": 0, "CacheExpired": 0}
    endif

    let l:lines = readfile(a:tmpfile)
    let l:maxExpectedLines = 3

    if a:isFullUpdate
        let s:GitStatus[a:buf]["RootDir"] = trim(fnamemodify(l:lines[0], ":h"))
        let s:GitStatus[a:buf]["BranchName"] = trim(fnamemodify(l:lines[1], ":t"))
        let l:maxExpectedLines = 5
    endif

    let s:GitStatus[a:buf]["IsTracked"] = str2nr(l:lines[l:maxExpectedLines - 3])
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

" Either full or light update of git information
function s:GitUpdate(initOrWrite, ...)
    let l:buf = get(a:, 1, bufnr())

    if !s:GitStatus["enabled"] || !s:GitStatus[l:buf]["LocalEnable"]
        return
    endif
    
    let l:flname = expand("#" . l:buf . ":p")
    let l:parentDir = fnamemodify(l:flname, ":h")
    let l:tmpfile = tempname()
    let l:redir = l:tmpfile ." 2> /dev/null "
    let l:isFullUpdate = a:initOrWrite || !s:GitStatus[l:buf]["IsGit"]
    let l:cmd = ""

    if l:isFullUpdate
        let l:cmd  = "git -C " . l:parentDir . " rev-parse --absolute-git-dir > " . l:redir . "&& "
        let l:cmd .= "(git -C " . l:parentDir . " symbolic-ref HEAD || " 
        let l:cmd .= "git -C " . l:parentDir . " rev-parse --short HEAD) >> " . l:redir . "&& "
    endif

    let l:cmd .= "([[ -n $(git -C " . l:parentDir . " ls-files " . l:flname . ") ]] && " . 
                \ "echo '1'  || echo '0') >> " . l:redir . "&& "
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
" 1 out of GitMaxCacheExp times it will just decrement the cache timer, if the
" cache is expired it will issue an async call to update Git
function s:GitInit(buf)

    if !has_key(s:GitStatus, a:buf)
        let s:GitStatus[a:buf] = {"LocalEnable" : 1 ,"IsGit": 0, "RootDir": "", "BranchName": "", 
                                \ "Dirty": "", "IsTracked": 0, "InsertNum": 0, "DeleteNum": 0, "CacheExpired": 0}
    endif

    if !s:GitStatus["enabled"] || !s:GitStatus[a:buf]["LocalEnable"]
        return
    endif

    let l:flname = expand("#" . a:buf . ":p")
    " If we opened a dir or taglist, ignore.
    if !filereadable(l:flname)
        let s:GitStatus[a:buf]["LocalEnable"] = 0
        return
    endif 

    if s:GitStatus[a:buf]["CacheExpired"] > 0
        " Dont update unless it has been a while
        let s:GitStatus[a:buf]["CacheExpired"] -= 1
        return
    endif

    " Renew Cache after update
    let s:GitStatus[a:buf]["CacheExpired"] = s:GitMaxCacheExp

    call s:GitUpdate(1, a:buf)

endfunction

""""""""""""""""""""""""""""""""""""""" Initialization
" Flatten all dictionaries.. zero calculation at load & retrieval time
" Mode labels dictionary
" [disabled|enabled][right arrow|left&right arrows1][mode()]
let s:modeMap = 
        \ {
            \ "0":{
                \ "0":{
                    \ "n":      "%#DisLbl# NORMAL %#DisLblSepFln#"    .    s:rASym,
                    \ "c":      "%#DisLbl# NORMAL %#DisLblSepFln#"    .    s:rASym,
                    \ "V":      "%#DisLbl# VISUAL %#DisLblSepFln#"    .    s:rASym,
                    \ "v":      "%#DisLbl# VISUAL %#DisLblSepFln#"    .    s:rASym,
                    \ "\<C-V>": "%#DisLbl# V·BLOCK %#DisLblSepFln#"   .    s:rASym,
                    \ "i":      "%#DisLbl# INSERT %#DisLblSepFln#"    .    s:rASym,
                    \ "R":      "%#DisLbl# REPLACE %#DisLblSepFln#"   .    s:rASym,
                    \ "s":      "%#DisLbl# SELECT %#DisLblSepFln#"    .    s:rASym,
                    \ "S":      "%#DisLbl# SELECT %#DisLblSepFln#"    .    s:rASym,
                    \ "\<C-S>": "%#DisLbl# SELECT %#DisLblSepFln#"    .    s:rASym,
                    \ "!":      "%#DisLbl# OTHER %#DisLblSepFln#"     .    s:rASym,
                    \ "t":      "%#DisLbl# OTHER %#DisLblSepFln#"     .    s:rASym,
                    \ "r":      "%#DisLbl# OTHER %#DisLblSepFln#"     .    s:rASym,
                \ }, "1":{
                    \ "n":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# NORMAL %#DisLblSepFln#"    .    s:rASym,
                    \ "c":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# NORMAL %#DisLblSepFln#"    .    s:rASym,
                    \ "V":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# VISUAL %#DisLblSepFln#"    .    s:rASym,
                    \ "v":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# VISUAL %#DisLblSepFln#"    .    s:rASym,
                    \ "\<C-V>": "%#DisLblSepClk#" . s:lASym . "%#DisLbl# V·BLOCK %#DisLblSepFln#"   .    s:rASym,
                    \ "i":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# INSERT %#DisLblSepFln#"    .    s:rASym,
                    \ "R":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# REPLACE %#DisLblSepFln#"   .    s:rASym,
                    \ "s":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# SELECT %#DisLblSepFln#"    .    s:rASym,
                    \ "S":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# SELECT %#DisLblSepFln#"    .    s:rASym,
                    \ "\<C-S>": "%#DisLblSepClk#" . s:lASym . "%#DisLbl# SELECT %#DisLblSepFln#"    .    s:rASym,
                    \ "!":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# OTHER %#DisLblSepFln#"     .    s:rASym,
                    \ "t":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# OTHER %#DisLblSepFln#"     .    s:rASym,
                    \ "r":      "%#DisLblSepClk#" . s:lASym . "%#DisLbl# OTHER %#DisLblSepFln#"     .    s:rASym,
                \ }
            \ }, "1":{
                \ "0":{
                    \ "n":      "%#NLbl# NORMAL %#NLblSepFln#"    .    s:rASym,
                    \ "c":      "%#NLbl# NORMAL %#NLblSepFln#"    .    s:rASym,
                    \ "V":      "%#VLbl# VISUAL %#VLblSepFln#"    .    s:rASym,
                    \ "v":      "%#VLbl# VISUAL %#VLblSepFln#"    .    s:rASym,
                    \ "\<C-V>": "%#VLbl# V·BLOCK %#VLblSepFln#"   .    s:rASym,
                    \ "i":      "%#ILbl# INSERT %#ILblSepFln#"    .    s:rASym,
                    \ "R":      "%#RLbl# REPLACE %#RLblSepFln#"   .    s:rASym,
                    \ "s":      "%#SLbl# SELECT %#SLblSepFln#"    .    s:rASym,
                    \ "S":      "%#SLbl# SELECT %#SLblSepFln#"    .    s:rASym,
                    \ "\<C-S>": "%#SLbl# SELECT %#SLblSepFln#"    .    s:rASym,
                    \ "!":      "%#OLBL# OTHER %#OLblSepFln#"     .    s:rASym,
                    \ "t":      "%#OLBL# OTHER %#OLblSepFln#"     .    s:rASym,
                    \ "r":      "%#OLBL# OTHER %#OLblSepFln#"     .    s:rASym,
                \ },"1":{ 
                    \ "n":      "%#NLblSepClk#" . s:lASym . "%#NLbl# NORMAL %#NLblSepFln#"    .    s:rASym,
                    \ "c":      "%#NLblSepClk#" . s:lASym . "%#NLbl# NORMAL %#NLblSepFln#"    .    s:rASym,
                    \ "V":      "%#VLblSepClk#" . s:lASym . "%#VLbl# VISUAL %#VLblSepFln#"    .    s:rASym,
                    \ "v":      "%#VLblSepClk#" . s:lASym . "%#VLbl# VISUAL %#VLblSepFln#"    .    s:rASym,
                    \ "\<C-V>": "%#VLblSepClk#" . s:lASym . "%#VLbl# V·BLOCK %#VLblSepFln#"   .    s:rASym,
                    \ "i":      "%#ILblSepClk#" . s:lASym . "%#ILbl# INSERT %#ILblSepFln#"    .    s:rASym,
                    \ "R":      "%#RLblSepClk#" . s:lASym . "%#RLbl# REPLACE %#RLblSepFln#"   .    s:rASym,
                    \ "s":      "%#SLblSepClk#" . s:lASym . "%#SLbl# SELECT %#SLblSepFln#"    .    s:rASym,
                    \ "S":      "%#SLblSepClk#" . s:lASym . "%#SLbl# SELECT %#SLblSepFln#"    .    s:rASym,
                    \ "\<C-S>": "%#SLblSepClk#" . s:lASym . "%#SLbl# SELECT %#SLblSepFln#"    .    s:rASym,
                    \ "!":      "%#OLblSepClk#" . s:lASym . "%#OLBL# OTHER %#OLblSepFln#"     .    s:rASym,
                    \ "t":      "%#OLblSepClk#" . s:lASym . "%#OLBL# OTHER %#OLblSepFln#"     .    s:rASym,
                    \ "r":      "%#OLblSepClk#" . s:lASym . "%#OLBL# OTHER %#OLblSepFln#"     .    s:rASym,
                \ }
            \ }
        \ }


" Modified flag dictionary
let s:modifiedFlag = 
        \ {
            \ 0:{
                \ 0: "%#DisInfBSepFln#", 1: "%#InfBSepFln#"
            \ }, 1:{
                \ 0: "%#MFlagSepFln#" . s:lASym . "%#MFlag# %#DisInfBSepMFlag#", 
                \ 1: "%#MFlagSepFln#" . s:lASym . "%#MFlag# %#InfBSepMFlag#"
            \ }
        \ }

"""""""""""""""" Status line highlight groups
" All flattened 
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

exec 'hi! StatusLine guifg='                . s:flnLblColor     . ' guibg='      .s:flnLblColor 
exec 'hi! StatusLineNC guibg='              .s:flnLblColor      . ' guifg='      .s:flnLblColor

exec 'hi! StraightLine guifg='              . s:purpel          . ' guibg='      . s:flnLblColor
exec 'hi! VertSplit guibg='                 . s:purpel          . ' guifg='      . s:flnLblColor

unlet s:nLblColor s:iLblColor s:rLblColor s:vLblColor 
            \ s:sLblColor s:oLblColor s:disLblColor s:flnLblColor 
            \ s:mFlgColor s:infBColor s:disInfBColor s:rcLbl 
            \ s:errLblColor s:warnLblColor s:clkLblColor s:white 
            \ s:orange s:purpel

"""""""""""""""" Autocmd
" Always show statusline
set laststatus=2

augroup longsts
    autocmd!
    " Call our status line manager
    autocmd BufWinEnter,WinEnter,BufDelete,SessionLoadPost,FileChangedShellPost * call s:ManageWinStl()
    " Update git with every write
    autocmd BufWritePost * call s:GitUpdate(0)
    " GitToggle Command
    command! -nargs=0 -bar GitToggle call s:GitToggleGit()
augroup END

