;; extends
;;
((command) @custom.gitrebase.pick
 (#match? @custom.gitrebase.pick "^(p|pick)$")
)

((command) @custom.gitrebase.edit
 (#match? @custom.gitrebase.edit "^(e|edit)$")
)

((command) @custom.gitrebase.reword
 (#match? @custom.gitrebase.reword "^(r|reword)$")
)

((command) @custom.gitrebase.squash
 (#match? @custom.gitrebase.squash "^(s|squash)$")
)

((command) @custom.gitrebase.fixup
 (#match? @custom.gitrebase.fixup "^(f|fixup)$")
)

((command) @custom.gitrebase.drop
 (#match? @custom.gitrebase.drop "^(d|drop)$")
)
