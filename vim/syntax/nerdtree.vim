"
" Custom icons
"

let g:NERD_ICON = {
\ 'test2': '',
\ 'test': '',
\ 'js2': '',
\ 'js': '',
\ 'ts2': '',
\ 'ts': 'ﯤ',
\ 'sass': '',
\ 'css': '',
\ 'html': '',
\ 'git': '',
\ 'angular': 'ﮰ',
\ 'code': '',
\ 'readme': '',
\ 'json': '',
\ }

"
" Config
"

let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {
\ 'js': g:NERD_ICON['code'],
\ 'ts': g:NERD_ICON['code'],
\ 'sass': g:NERD_ICON['sass'],
\ 'scss': g:NERD_ICON['sass'],
\ 'css': g:NERD_ICON['css'],
\ 'html': g:NERD_ICON['html'],
\ 'md': g:NERD_ICON['readme'],
\ 'json': g:NERD_ICON['json'],
\ }

let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {
\ '.*\.spec\.ts$': g:NERD_ICON['test'],
\ '.*\.spec\.js$': g:NERD_ICON['test'],
\ '.*\.component\.ts$': g:NERD_ICON['angular'],
\ '.*\.gitignore$': g:NERD_ICON['git'],
\ }

"
" Syntax
"

function! HighlightNerdIcon(iconName, ext, fg)
  " Names for the match areas
  let s:LineMatch = 'Nerd' . a:iconName . 'Line'
  let s:IconMatch = 'Nerd' . a:iconName . 'Icon'

  " Create the line match on the passed extension
  execute 'syn match '. s:LineMatch .' /^\s\+.*\.'. a:ext .'$/ contains='. s:IconMatch
  execute 'syn match '. s:IconMatch .' "'. g:NERD_ICON[a:iconName] .'" containedin='. s:LineMatch

  " Highlight the icon match
  execute 'highlight '. s:IconMatch .' ctermfg='. a:fg
endfunction

call HighlightNerdIcon('code', 'js', 6)
call HighlightNerdIcon('code', 'ts', 6)
call HighlightNerdIcon('sass', 'sass', 13)
call HighlightNerdIcon('sass', 'scss', 13)
call HighlightNerdIcon('css', 'css', 13)
call HighlightNerdIcon('html', 'html', 16)
call HighlightNerdIcon('test', 'spec\..*', 'green')
call HighlightNerdIcon('angular', 'component\.ts', 11)

hi NERDTreeExecFile ctermfg=10
