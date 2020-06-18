" Vim color file
" Author:   Mansour Alharthi <man9our.ah@gmail.com>

highlight clear
set background=dark
syntax reset
let g:colors_name = "pure-blue"


  
let s:darkblue = "#082430"
let s:mutewhite = "#fcfcfc"
let s:grey = "#7e7e89"
let s:darkgrey = "#3f3f45"
let s:magenta = "#996ba0"
let s:lightmagenta = "#ffbfbf"
let s:green = "#06ba60"
let s:darkgreen = "#03592e"
let s:purpel = "#7f95d0"
let s:lightblue = "#33c1ff"
let s:anotherblue = "#00b0ff"
let s:orange = "#c66628"
let s:red = "#af0000"
let s:yellow = "#ffc421"
let s:pink = "#ad7fa8"

" Normal 
exec "hi Normal guifg=".s:mutewhite." guibg=".s:darkblue

" Syntax groups
exec "hi Comment guifg=".s:grey
exec "hi Constant guifg=".s:magenta
exec "hi Identifier cterm=NONE guifg=".s:orange
exec "hi Statement guifg=".s:anotherblue
exec "hi PreProc guifg=".s:purpel
exec "hi Type guifg=".s:green
exec "hi Special guifg=".s:lightmagenta
exec "hi Error guifg=".s:mutewhite." guibg=".s:red
exec "hi Todo cterm=NONE guifg=#000000 guibg=".s:yellow

" CursorLine
exec "hi CursorLine cterm=NONE guibg=NONE"
exec "hi LineNr guifg=".s:grey." guibg=NONE"
exec "hi CursorLineNr cterm=bold guifg=".s:orange." guibg=NONE"
set cursorline

" Popup menu
exec "hi Pmenu guifg=".s:darkgrey." guibg=".s:pink
exec "hi PmenuSel guifg=".s:pink." guibg=".s:darkgrey 

" Search
exec "hi IncSearch guifg=#FCE94F guibg=black"
exec "hi Search guifg=black guibg=#FCE94F"

" Other
exec "hi EndOfBuffer guifg=".s:purpel." guibg=NONE"
exec "hi Title guifg=".s:purpel." guibg=NONE"


" Spell
exec "hi SpellBad guifg=".s:mutewhite." guibg=red"
exec "hi SpellLocal guifg=".s:mutewhite." guibg=red"
exec "hi SpellRare guifg=".s:mutewhite." guibg=red"

" Taglist
exec "hi MyTagListComment guifg=".s:grey." guibg=NONE"
exec "hi MyTagListTitle guifg=".s:anotherblue." guibg=NONE"
exec "hi MyTagListFileName guifg=".s:mutewhite." guibg=".s:darkgrey
exec "hi MyTagListTagScope guifg=".s:green." guibg=NONE"

" IndentGuides
exec "hi IndentGuidesOdd  guibg=#323232"
exec "hi IndentGuidesEven guibg=".s:darkgrey

" VertSplit
exec "hi VertSplit guifg=".s:darkblue." guibg=".s:darkblue

" Diff
exec "hi DiffChange	guibg=".s:darkblue." guifg=".s:mutewhite
exec "hi DiffText gui=NONE cterm=NONE guibg=".s:red." guifg=".s:mutewhite
exec "hi DiffAdd guibg=".s:darkgreen." guifg=".s:mutewhite
exec "hi DiffDelete guibg="s:darkgrey." guifg=black"


unlet s:darkblue s:mutewhite s:grey s:darkgrey s:magenta s:lightmagenta s:green s:darkgreen s:purpel s:lightblue s:anotherblue s:orange s:red s:yellow s:pink
