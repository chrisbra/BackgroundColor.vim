if !has("signs")
    finish
endif
let s:bg_color_red="hi default ColorRed ctermbg=DarkRed guibg=Red"
let s:bg_color_white="hi default ColorWhite ctermbg=White guibg=White"
let s:bg_color_yellow="hi default ColorYellow ctermbg=Yellow guibg=Yellow"
let s:bg_color_blue="hi default ColorBlue ctermbg=Blue guibg=Blue"
let s:bg_color_green="hi default ColorGreen ctermbg=Green guibg=Green"
let s:bg_color_black="hi default ColorBlack ctermbg=Black guibg=Black"

" You can define 2 custom colors here
let s:bg_color_custom1=exists("g:bg_color_custom1") ? g:bg_color_custom1 : ""
let s:bg_color_custom2=exists("g:bg_color_custom2") ? g:bg_color_custom2 : ""

let s:bg_color_list = split("s:bg_color_red s:bg_color_white s:bg_color_yellow s:bg_color_blue s:bg_color_green s:bg_color_black s:bg_color_custom1 s:bg_color_custom2")
let s:sign_number   = 200
let b:sign_dict     = {}

fun! <sid>BgInit()
    " more flexible but probably slower:
    "let list=keys(g:)
    "call filter(list, 'v:val =~# "bg_color_"')
    "for hi in list
	"exe g:[hi]
    " endfor
    let b:sign_dict     = {}
    for hi in s:bg_color_list
	if !empty(eval(hi))
	    exe eval(hi)
	endif
    endfor
    call <sid>SignDefine()
endfun

fun! <sid>SignDefine()
    " Undefine all previsiously defined signs
"    redir => s:a | exe "sil sign list" | redir end
"    let s:signlist=split(s:a, "\n")
"    call filter(s:signlist, 'v:val =~# "^sign Color"')
"    for sign in s:signlist
"	let id     = split(sign, '\s\+')[1]
"	let defin  ="sign undefine " . id
"	exe place | exe defin
"    endfor
"    unlet s:signlist s:a

    for item in s:bg_color_list
	if !empty(eval(item))
	    let name=split(eval(item), '\s\+')[2]
	    exe "sign define" name "linehl=" . name 
	endif
    endfor
endfun

fun! <sid>SignPlace(color, force) range
     for line in range(a:firstline, a:lastline)
	 if get(b:sign_dict, line) && !a:force
	    continue
	 elseif get(b:sign_dict, line)
	     exe "sign unplace " b:sign_dict[line]
	 endif
	 if a:color == "Default"
	     continue
	endif
	if !exists(a:color)
	    call <sid>BgInit()
	endif
	 exe "sign place " . s:sign_number  . " line=" . line . " name=" . a:color . " buffer=".bufnr('')
	 "let b:sign_dict[line]={"line": line, "id": s:sign_number}
	 let b:sign_dict[line]=s:sign_number
	 let s:sign_number+=1
     endfor
endfun

fun! <sid>ClearSigns()
    sign unplace *
    let s:sign_number=200
endfun


for color in s:bg_color_list
    if !empty(eval(color))
	let name  = matchstr(color, '[a-z0-9]\+$')
	let name  = toupper(name[0]).name[1:]
	let cname = split(eval(color), '\s\+')[2]
	exe 'com! -range -bang ' name '<line1>,<line2>call <sid>SignPlace("'.cname.'", empty("<bang>")?0:1)'
    endif
    com! -range Clear exe '<line1>,<line2>call <sid>SignPlace("Default",1)'
endfor

au BufNew,BufRead * :call <sid>BgInit()

com! ClearAll :call <sid>ClearSigns()
