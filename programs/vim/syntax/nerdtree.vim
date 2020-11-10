""
"" Custom icons
""

let g:NERDTreeLimitedSyntax = 1

let s:brown = "905532"
let s:aqua =  "3AFFDB"
let s:blue = "689FB6"
let s:darkBlue = "44788E"
let s:purple = "834F79"
let s:lightPurple = "834F79"
let s:red = "AE403F"
let s:beige = "F5C06F"
let s:yellow = "F09F17"
let s:orange = "D4843E"
let s:darkOrange = "F16529"
let s:pink = "CB6F6F"
let s:salmon = "EE6E73"
let s:green = "8FAA54"
let s:lightGreen = "31B53E"
let s:white = "FFFFFF"
let s:rspec_red = 'FE405F'
let s:git_orange = 'F54D27'

" let g:NERDTreeExtensionHighlightColor['css'] = s:purple " sets the color of css files to blue
" let g:NERDTreeExtensionHighlightColor['scss'] = s:purple " sets the color of css files to blue
" let g:NERDTreeExtensionHighlightColor['sass'] = s:purple " sets the color of css files to blue

" Customise the icons/colours

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
\ 'hash': '',
\ }

" Create the variables
let g:NERDTreeExtensionHighlightColor = {}
let g:NERDTreePatternMatchHighlightColor = {}
" let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {} " needed

function! CustomNerdIconExtension(ext, icon, color)
  let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols[a:ext] = a:icon
  let g:NERDTreeExtensionHighlightColor[a:ext] = a:color
endfunction

function! CustomNerdIconPattern(pattern, icon, color)
  let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols[a:pattern] = a:icon
  let g:NERDTreePatternMatchHighlightColor[a:pattern] = a:color
endfunction

call CustomNerdIconExtension('ts', g:NERD_ICON['ts'], s:blue)
call CustomNerdIconExtension('tsx', g:NERD_ICON['html'], s:beige)
call CustomNerdIconExtension('css', g:NERD_ICON['hash'], s:pink)
call CustomNerdIconExtension('scss', g:NERD_ICON['sass'], s:pink)
call CustomNerdIconExtension('sass', g:NERD_ICON['sass'], s:pink)
call CustomNerdIconPattern('.*\.test\..*', g:NERD_ICON['test'], s:green)

" let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {} " needed
" let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols['.*\.test\..*'] = g:NERD_ICON['test']
" let g:NERDTreePatternMatchHighlightColor['.*\.test\..*'] = s:rspec_red " sets the color for files ending with _spec.rb

"\ 'css': '',

""
"" Config
""

" let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {
" \ 'js': g:NERD_ICON['code'],
" \ 'ts': g:NERD_ICON['code'],
" \ 'sass': g:NERD_ICON['sass'],
" \ 'scss': g:NERD_ICON['sass'],
" \ 'css': g:NERD_ICON['css'],
" \ 'html': g:NERD_ICON['html'],
" \ 'md': g:NERD_ICON['readme'],
" \ 'json': g:NERD_ICON['json'],
" \ }

" let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['ts'] = g:NERD_ICON['code'],
"let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {
"\ '.*\.spec\.ts$': g:NERD_ICON['test'],
"\ '.*\.spec\.js$': g:NERD_ICON['test'],
"\ '.*\.component\.ts$': g:NERD_ICON['angular'],
"\ '.*\.gitignore$': g:NERD_ICON['git'],
"\ }

""
"" Syntax
""

"function! HighlightNerdIcon(iconName, ext, fg)
"  " Names for the match areas
"  let s:LineMatch = 'Nerd' . a:iconName . 'Line'
"  let s:IconMatch = 'Nerd' . a:iconName . 'Icon'

"  " Create the line match on the passed extension
"  execute 'syn match '. s:LineMatch .' /^\s\+.*\.'. a:ext .'$/ contains='. s:IconMatch
"  execute 'syn match '. s:IconMatch .' "'. g:NERD_ICON[a:iconName] .'" containedin='. s:LineMatch

"  " Highlight the icon match
"  execute 'highlight '. s:IconMatch .' ctermfg='. a:fg
"endfunction

"call HighlightNerdIcon('code', 'js', 6)
"call HighlightNerdIcon('code', 'ts', 6)
"call HighlightNerdIcon('sass', 'sass', 13)
"call HighlightNerdIcon('sass', 'scss', 13)
"call HighlightNerdIcon('css', 'css', 13)
"call HighlightNerdIcon('html', 'html', 16)
"call HighlightNerdIcon('test', 'spec\..*', 'green')
"call HighlightNerdIcon('angular', 'component\.ts', 11)

"hi NERDTreeExecFile ctermfg=10
"let g:NERD_ICON = {
"\ 'test2': '',
"\ 'test': '',
"\ 'js2': '',
"\ 'js': '',
"\ 'ts2': '',
"\ 'ts': 'ﯤ',
"\ 'sass': '',
"\ 'css': '',
"\ 'html': '',
"\ 'git': '',
"\ 'angular': 'ﮰ',
"\ 'code': '',
"\ 'readme': '',
"\ 'json': '',
"\ }

""
"" Config
""

" let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {
" \ 'js': g:NERD_ICON['code'],
" \ 'ts': g:NERD_ICON['code'],
" \ 'sass': g:NERD_ICON['sass'],
" \ 'scss': g:NERD_ICON['sass'],
" \ 'css': g:NERD_ICON['css'],
" \ 'html': g:NERD_ICON['html'],
" \ 'md': g:NERD_ICON['readme'],
" \ 'json': g:NERD_ICON['json'],
" \ }

" let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['ts'] = g:NERD_ICON['code'],
"let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {
"\ '.*\.spec\.ts$': g:NERD_ICON['test'],
"\ '.*\.spec\.js$': g:NERD_ICON['test'],
"\ '.*\.component\.ts$': g:NERD_ICON['angular'],
"\ '.*\.gitignore$': g:NERD_ICON['git'],
"\ }

""
"" Syntax
""

"function! HighlightNerdIcon(iconName, ext, fg)
"  " Names for the match areas
"  let s:LineMatch = 'Nerd' . a:iconName . 'Line'
"  let s:IconMatch = 'Nerd' . a:iconName . 'Icon'

"  " Create the line match on the passed extension
"  execute 'syn match '. s:LineMatch .' /^\s\+.*\.'. a:ext .'$/ contains='. s:IconMatch
"  execute 'syn match '. s:IconMatch .' "'. g:NERD_ICON[a:iconName] .'" containedin='. s:LineMatch

"  " Highlight the icon match
"  execute 'highlight '. s:IconMatch .' ctermfg='. a:fg
"endfunction

"call HighlightNerdIcon('code', 'js', 6)
"call HighlightNerdIcon('code', 'ts', 6)
"call HighlightNerdIcon('sass', 'sass', 13)
"call HighlightNerdIcon('sass', 'scss', 13)
"call HighlightNerdIcon('css', 'css', 13)
"call HighlightNerdIcon('html', 'html', 16)
"call HighlightNerdIcon('test', 'spec\..*', 'green')
"call HighlightNerdIcon('angular', 'component\.ts', 11)

"hi NERDTreeExecFile ctermfg=10
