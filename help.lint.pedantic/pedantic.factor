USING: accessors continuations eval formatting fry help
help.lint help.lint.checks help.markup kernel namespaces parser
prettyprint sequences strings summary vocabs words ;
IN: help.lint.pedantic

ERROR: word-missing-section missing-section word-name ;
ERROR: empty-examples word-name ;


M: empty-examples summary
    word-name>> "Word '%s' has defined empty $examples section" sprintf ;

M: word-missing-section summary
    [ word-name>> ] [ missing-section>> ] bi
    "Word '%s' should define %s help section" sprintf ;

<PRIVATE
: elements-by ( element elt-type -- seq )
  swap elements ;
PRIVATE>

: check-word-sections ( word -- )
    [ word-help ] keep '[
      [ elements-by ] keep swap
      [ name>> _ word-missing-section throw ]
      [ 2drop ] if-empty
    ]
    { [ \ $description ] [ \ $examples ] [ \ $values ] }
    [ prepose ] with map
    [ call( x -- ) ] with each ;

: missing-examples? ( word -- ? )
    word-help \ $examples elements-by empty? ;

: check-word-examples ( word -- )
    [ missing-examples? ] keep '[ _ empty-examples throw ] when ;

GENERIC: word-pedant ( word -- )
M: word word-pedant
    [ check-word-sections ]
    [ check-word-examples ]
    bi ; inline

M: string word-pedant
    "\\ " prepend eval( -- word ) word-pedant ; inline

: vocab-pedant ( vocab-spec -- )
    [ auto-use? off vocab-words [ word-pedant ] each ] with-scope ;

: prefix-pedant ( prefix -- )
    [
      auto-use? off group-articles vocab-articles set
      loaded-child-vocab-names [ vocab-pedant ] each
    ] with-scope ;
