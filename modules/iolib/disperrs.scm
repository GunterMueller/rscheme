#|------------------------------------------------------------*-Scheme-*--|
 | File:    modules/iolib/disperrs.scm
 |
 |          Copyright (C)1997 Donovan Kolbly <d.kolbly@rscheme.org>
 |          as part of the RScheme project, licensed for free use.
 |          See <http://www.rscheme.org/> for the latest information.
 |
 | File version:     1.3
 | File mod date:    1997-11-29 23:10:39
 | System build:     v0.7.3.4-b7u, 2007-05-30
 | Owned by module:  iolib
 |
 | Purpose:          rendition functions for <condition>'s
 |------------------------------------------------------------------------|
 | Notes:
 |      These rendition functions are for <condition>'s defined
 |      in earlier modules
 `------------------------------------------------------------------------|#

(define-method display-object ((self <excess-initializers>) port)
  (format port "excess initializers supplied to `make' of a ~s\n"
	  (class-name (object-class (object self))))
  (let loop ((x (excess self)))
    (if (pair? x)
	(if (pair? (cdr x))
	    (begin
	      (format port "    ~s ~#*@55s\n" (car x) (cadr x))
	      (loop (cddr x)))
	    (format port "   ~s (value missing)\n" (car x)))
	(values))))
