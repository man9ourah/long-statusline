#Credit: https://github.com/rbong/vim-crystalline/wiki/Performance-Comparison
#!/usr/bin/env bash

set -e

export LC_ALL=C

ITER=${ITER:-100}
VIM_CMD=${VIM_CMD:-vim -N}
OUT=${OUT:-line_performance.log}

MEASURE_TIME="function! MeasureTime(iter)
    for l:i in range(a:iter)
      vsplit
      redraw
      quit
      redraw
    endfor
    qa
endfunction"
TIME="/usr/bin/time -f |%E -o $OUT -a"

function logjust() {
  printf '%-12s' "$*" >> "$OUT"
}

function log() {
  echo $* >> "$OUT"
}

log "Benchmark (x$ITER) | Startup | Redraw"
log "-|-|-"

logjust longstl
$TIME bash -c "for i in \$(seq '"$ITER"'); do
  $VIM_CMD -u vimrc.test -c q
done"

$TIME $VIM_CMD -u vimrc.test -c "call MeasureTime(${ITER})"

log
log '<details>'
log '<summary>Additional information</summary>'
log
log "Terminal: $TERM"
log
log Vim:
log '<pre>'
$VIM_CMD --version >> "$OUT"
log '</pre></details>'

# Postprocess: Join times that start with '|' to the previous line
sed -Ei ':begin;$!N;s/(.*)\n\|([0-9]+:[0-9]{2}\.[0-9]{2})$/\1 | \2/;tbegin;P;D' "$OUT"

cat "$OUT"
