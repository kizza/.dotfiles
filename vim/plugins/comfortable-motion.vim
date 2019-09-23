Plug 'yuttie/comfortable-motion.vim'

let g:comfortable_motion_no_default_key_mappings = 1
let g:comfortable_motion_impulse_multiplier = 1  " Feel free to increase/decrease this value.

let g:comfortable_motion_interval = 1000.0 / 60
let g:comfortable_motion_friction = 20.0
let g:comfortable_motion_air_drag = 2.0

nnoremap <silent> <C-d> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 4)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -4)<CR>

nnoremap <silent> <C-f> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 8)<CR>
nnoremap <silent> <C-b> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -8)<CR>

nnoremap <silent> zt :call comfortable_motion#zt()<CR>
nnoremap <silent> zz :call comfortable_motion#zz()<CR>
nnoremap <silent> zb :call comfortable_motion#zb()<CR>
