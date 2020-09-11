highlight clear

if &background !=# 'dark'
    set background=dark
endif

if exists('g:syntax_on')
    syntax reset
endif

if exists('g:colors_name')
    hi clear
endif

let g:colors_name="aubergine"

highlight Normal guibg=#1A222E guifg=#CBC7C0
highlight NonText guifg=#ffffff guibg=#ff0000
highlight VertSplit guifg=#283447 guibg=NONE gui=NONE cterm=NONE
highlight LineNr guifg=#2C3744 guibg=NONE gui=NONE cterm=NONE
highlight EndOfBuffer guifg=#2C3744 guibg=NONE gui=NONE cterm=NONE

" TODO
highlight Cursor guifg=#ff0000 guibg=#9ea3c0
hi SignColumn guifg=#ff0000 ctermfg=60 guibg=NONE ctermbg=NONE
"

hi ColorColumn guibg=#283447 ctermbg=236 gui=NONE cterm=NONE
hi CursorColumn guibg=#283447
hi CursorLine guibg=#222C3B
hi CursorLineNr guifg=#7889A3 gui=NONE cterm=NONE
hi NormalFloat guifg=#CBC7C0 guibg=#1C2738 gui=NONE cterm=NONE
hi Directory guifg=#D3AB67 gui=bold cterm=bold

" TODO
hi Conceal guifg=#ff0000 ctermfg=138 guibg=#222433 ctermbg=235 gui=NONE cterm=NONE
hi Folded guifg=#0000FF ctermfg=60 guibg=#32364c ctermbg=237 gui=NONE cterm=NONE
hi FoldColumn guifg=#00ff00 ctermfg=237 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi MatchParen guibg=#ff0000 ctermbg=236
hi Title guifg=#67A49A gui=bold cterm=bold
"

highlight Comment guifg=#7889A3

highlight Constant guifg=#9169AA
highlight String guifg=#95A8C8
highlight Character guifg=#4893AC
highlight Number guifg=#9169AA
highlight Boolean guifg=#9169AA
highlight Float guifg=#9169AA

highlight Identifier guifg=#CBC7C0 gui=bold cterm=bold
highlight Function guifg=#D3AB67 gui=bold cterm=bold

highlight Statement guifg=#9169AA gui=bold cterm=bold
highlight Conditional guifg=#9169AA gui=bold cterm=bold
highlight Repeat guifg=#9169AA gui=bold cterm=bold
highlight Label guifg=#9169AA gui=bold cterm=bold
highlight Operator guifg=#4893AC gui=bold cterm=bold
highlight Keyword guifg=#9169AA gui=bold cterm=bold
highlight Exception guifg=#9169AA gui=bold cterm=bold

highlight PreProc guifg=#9169AA gui=bold cterm=bold
highlight Include guifg=#9169AA gui=bold cterm=bold
highlight Define guifg=#9169AA gui=bold cterm=bold
highlight Macro guifg=#9169AA gui=bold cterm=bold
highlight PreCondit guifg=#9169AA gui=bold cterm=bold

highlight Type guifg=#D3AB67 gui=bold cterm=bold
highlight StorageClass guifg=#D3AB67 gui=bold cterm=bold
highlight Structure guifg=#67A49A gui=bold cterm=bold
highlight Typedef guifg=#D3AB67 gui=bold cterm=bold

highlight Special guifg=#F67E7F
highlight SpecialChar guifg=#F67E7F
highlight Tag guifg=#F67E7F
highlight Delimeter guifg=#F67E7F
highlight SpecialComment guifg=#F67E7F
highlight Debug guifg=#F67E7F
highlight SpecialKey guifg=#F67E7F

highlight Underlined guifg=#9169AA gui=underline cterm=underline

highlight Error guifg=#F67E7F guibg=#332222 gui=bold cterm=bold
highlight ErrorMsg guifg=#F67E7F gui=bold cterm=bold
highlight WarningMsg guifg=#D3AB67 gui=bold cterm=bold
highlight MoreMsg guifg=#67A49A

highlight Todo guifg=#67A49A guibg=NONE gui=bold cterm=bold

hi Pmenu guifg=#CBC7C0 guibg=#1C2738
hi PmenuSel guifg=#CBC7C0 guibg=#1A222E
hi PmenuSbar guibg=#1C2738
hi PmenuThumb guibg=#353D54

hi Visual guibg=#452424 gui=NONE cterm=NONE
hi Search guifg=#283447 guibg=#4893AC gui=bold cterm=bold
hi IncSearch guifg=#283447 guibg=#4893AC gui=bold cterm=bold

" TODO
hi Question guifg=#ff0000 ctermfg=79 gui=bold cterm=bold
hi WildMenu guifg=#ff0000 ctermfg=235 guibg=#00ff00 ctermbg=104
"

hi SpellBad guifg=#F67E7F gui=underline cterm=underline
hi SpellCap gui=underline cterm=underline
hi SpellLocal guifg=#F67E7F gui=underline cterm=underline
hi SpellRare guifg=#D3AB67 gui=underline cterm=underline

"TODO
hi DiffAdd guibg=#104a65 ctermbg=24 gui=bold cterm=bold
hi DiffChange guibg=#26463b ctermbg=23 gui=bold cterm=bold
hi DiffDelete guifg=#d2d9ff ctermfg=189 guibg=#674267 ctermbg=96 gui=bold cterm=bold
hi DiffText guibg=#28795c ctermbg=29 gui=NONE cterm=NONE
"

hi GitGutterAdd guifg=#67A49A gui=bold cterm=bold
hi GitGutterChange guifg=#D3AB67 gui=bold cterm=bold
hi GitGutterDelete guifg=#F67E7F gui=bold cterm=bold
hi GitGutterChangeDelete guifg=#4893AC gui=bold cterm=bold

hi CocErrorSign guifg=#F67E7F ctermfg=204 gui=bold cterm=bold
hi CocWarningSign guifg=#D3AB67 ctermfg=138 gui=bold cterm=bold
hi CocInfoSign guifg=#4893AC ctermfg=115 gui=bold cterm=bold
hi CocHintSign guifg=#67A49A ctermfg=115 gui=bold cterm=bold

if has("nvim")
  let g:terminal_color_0 = '#000000'
  let g:terminal_color_1 = '#F67E7F'
  let g:terminal_color_2 = '#7ECABB'
  let g:terminal_color_3 = '#FFD376'
  let g:terminal_color_4 = '#56B5D1'
  let g:terminal_color_5 = '#B67ED0'
  let g:terminal_color_6 = '#59E0DF'
  let g:terminal_color_7 = '#E5E5E5'
  let g:terminal_color_8 = '#666666'
  let g:terminal_color_9 = '#F67E7F'
  let g:terminal_color_10 = '#7ECABB'
  let g:terminal_color_11 = '#FFD376'
  let g:terminal_color_12 = '#56B5D1'
  let g:terminal_color_13 = '#B67ED0'
  let g:terminal_color_14 = '#59E0DF'
  let g:terminal_color_15 = '#E5E5E5'
let g:terminal_color_background = '#1A222E'
  let g:terminal_color_foreground = '#CBC7C0'
endif
