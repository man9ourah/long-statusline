" Highlight Function names
" Right from: https://stackoverflow.com/a/773392/9416167
syn match    cCustomParen    "(" contains=cParen,cCppParen
syn match    cCustomFunc     "\w\+\s*(" contains=cCustomParen

hi def link cCustomFunc  Function
