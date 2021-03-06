(define-module-extend gui.app.dv ()
  (&module
   (export <group> get-interactive-wrapper)
   (export print-page page-size with-client make-client)))
(define-module-extend rs.sys.paths ()
  (&module
   (export extension-related-path)))

,(use rs.sys.paths)
,(use rs.util.msgs)
,(use rs.sys.tables)
,(use gui.app.dv)
,(use graphics.geometry)
,(use rs.util.properties)

#|
(load "~/rscheme/doc/using-docbook/tools/loadofig.scm")
|#

(define $basis   14)  ;; basis width
(define $basis/2  7)  ;; basis width
(define $gwidth  36)  ;; basis width

(load "arrow.scm")

(define-class <node-cell> (<object>)
  name  ;; (union <symbol> (singleton #f))
  description
  (size type: <size>)
  (handles type: <list> init-value: '())
  (origin type: <point> init-value: $zero-point)
  (extern-repr init-value: '(group)))

(define (node-frame (self <node-cell>))
  (make-rect (x (origin self))
	     ;; flipped coords
	     (y (origin self))
	     (width (size self))
	     (height (size self))))

(define-class <gvec-node-cell> (<node-cell>))
(define-class <hvec-node-cell> (<node-cell>))
(define-class <var-node-cell> (<node-cell>))

(define-method gen-links ((self <node-cell>) index)
  '(group))

(define-method gen-links ((self <var-node-cell>) index)
  (print self)
  (let* ((orig (origin self))
	 (content (cadddr (description self))))
    (gen-cell-value self 
		    index
		    (make-rect (x orig) (y orig) $basis $basis)
		    content)))

(define-method gen-links ((self <hvec-node-cell>) index)
  (let* ((orig (origin self))
	 (content (cdddr (description self)))
	 (n (length content)))
    (cons
     'group
     (map
      (lambda (i cell)
	(gen-cell-value self index
			(make-rect (+ (x orig) (* i $basis))
				   (y orig)
				   $basis
				   $basis)
			cell))
      (range n)
      content))))

;;;

(define (dbox f c)
  (list 'box
	stroke-color: c
	origin-x: (origin-x f)
	origin-y: (origin-y f)
	width: (size-width f)
	height: (size-height f)))

(define (link-line/rvr src-pt to-frame)
  (let ((xmid (/ (+ (origin-x to-frame)
		    (+ (x src-pt) $basis/2))
		 2))
	(to (point+ (upper-left to-frame)
		    (make-size 0 (- $basis/2)))))
    (curvy-path-with-arrow (list src-pt
				 (make-point xmid (y src-pt))
				 (make-point xmid (y to))
				 to))))

(define (link-line/r src-pt to-frame)
  (hline-with-arrow src-pt
		    (point+ (upper-left to-frame)
			    (make-size 0 (- $basis/2)))
		    1))

(define (link-line/d src-pt to-frame)
  (vline-with-arrow src-pt
		    (point+ (upper-left to-frame)
			    (make-size $basis/2 0))
		    -1))

(define (link-line/u src-pt to-frame)
  (vline-with-arrow src-pt
		    (point+ (lower-left to-frame)
			    (make-size $basis/2 0))
		    1))

(define (guess-link-line-winding from-frame to-frame)
  (let* ((src-pt (point+ (upper-right from-frame)
			 (make-size (- $basis/2) (- $basis/2))))
	 (to (upper-left to-frame)))
    (if (< (abs (- (y src-pt) (y to)))
	   (abs (- (x src-pt) (x to))))
	(if (< (x src-pt) (x to))
	    '(r)
	    '(l))
	(if (< (y src-pt) (y to))
	    '(u)
	    '(d)))))

(define *line-winders*
  (list (cons '(r) link-line/r)
	(cons '(u) link-line/u)
	(cons '(d) link-line/d)
	(cons '(r u r) link-line/rvr)
	(cons '(r d r) link-line/rvr)))

(define (link-line from-frame to-frame winding)
  (let* ((src-pt (point+ (upper-right from-frame)
			 (make-size (- $basis/2) (- $basis/2))))
	 (w (assoc winding *line-winders*)))
    ((cdr w) src-pt to-frame)))

#|    
    (list 'group
	  ;(dbox (inset-rect from-frame 3 3) '(rgb 0.7 0.8 1))
	  (if (< (abs (- (y src-pt) (y to)))
		 (abs (- (x src-pt) (x to))))
	      (hline-with-arrow src-pt (point+ to (make-size 0 (- $basis/2))))
	      (vline-with-arrow src-pt (point+ to (make-size $basis/2 0)))))))
|#


(define (ofig-pass1/var node)
  (make <var-node-cell>
	description: node
	name: (car node)
	size: (make-size $basis $basis)
	handles: (list (cons 'self $zero-point)
		       (cons 'value (make-point $basis/2 $basis/2)))
	origin: (make-point 0 (- $basis))
	; should really be a circle
	extern-repr: `(group
		       (text string: ,(symbol->string (car node))
			     origin-x: -2
			     alignment: right
			     font: (font "Helvetica" "Bold" 12)
			     origin-y: ,(- 3 $basis))
		       (box origin-y: ,(- $basis)
			    width: ,$basis
			    height: ,$basis))))

(define (ofig-pass1/gvec node)
  (let* ((n (length (cddddr node)))
	 (divs (map (lambda (i)
		      `(line start-x: 0
			     start-y: ,(- (* i $basis))
			     stroke-width: 0.5
			     end-x: ,$gwidth
			     end-y: ,(- (* i $basis))))
		    (cdr (range n))))
	 (boxh (* n $basis)))
    (make <gvec-node-cell>
	  description: node
	  name: (car node)
	  size: (make-size $gwidth boxh)
	  handles: '()
	  origin: (make-point 0 (- boxh))
	  extern-repr: `(group
			 (text string: ,(symbol->string (caddr node))
			       origin-y: 1
			       alignment: right
			       origin-x: ,(+ 2 $gwidth) ;; the `2' kerns ">"
			       font: (font "Times" "Italic" 10))
			 ,@divs
			 (box origin-y: ,(- boxh)
			      width: ,$gwidth
			      height: ,boxh)))))

(define (ofig-pass1/hvec node)
  (let ((n (length (cdddr node))))
    (make <hvec-node-cell>
	  description: node
	  name: (car node)
	  size: (make-size (* n $basis) $basis)
	  handles: '()
	  origin: (make-point 0 (- $basis))
	  extern-repr: `(group
			 ;; only works for n==2 for now
			 (line start-x: ,$basis
			       start-y: ,(- $basis)
			       end-x: ,$basis
			       end-y: 0)
			 (box origin-y: ,(- $basis)
			      width: ,(* $basis n)
			      height: ,$basis)))))

(define (ofig-pass1 node)
  (case (cadr node)
    ((:var) (ofig-pass1/var node))
    ((:gvec) (ofig-pass1/gvec node))
    ((:hvec) (ofig-pass1/hvec node))))

(define (load-ofig-nodes (group <group>) nodes matrix)
  (let ((basic-boxes (make-symbol-table)))
    ;;
    (for-each
     (lambda (node)
       (table-insert! basic-boxes (car node) (ofig-pass1 node)))
     nodes)
    ;;
    (let* ((sizes (map
		   (lambda (row)
		     (map (lambda (name)
			    (if name
				(size (table-lookup basic-boxes name))
				$zero-size))
			  row))
		   matrix))
	   (col-ws (map (curry + 24)
			(apply map max
			       (map (curry map width) sizes))))
	   (row-hs (map (curry + 24)
			(map (curry apply max)
			     (map (curry map height) sizes)))))
      ;;
      (print sizes)
      (format #t "col-ws: ~s\n" col-ws)
      (format #t "row-hs: ~s\n" row-hs)
      ;;
      ;; insert nodes
      ;;
      (let ((y (+ 36 (apply + row-hs))))
	(for-each
	 (lambda (row rowh)
	   (format #t "row: ~s rowh: ~s\n" row rowh)
	   (for-each
	    (let ((x 36))
	      (lambda (name colw)
		(if name
		    (let* (((c <node-cell>) (table-lookup basic-boxes name))
			   (sz (size c))
			   (at (make-size x y)))
		      (set-origin! c (point+ (origin c) at))
		      (paste-from-extern (extern-repr c) group at)))
		      #|
		      (let ((nf (node-frame c)))
			(paste-from-extern (dbox nf '(rgb 1 0 0))
					   group
					   $zero-size))
		      |#
		(set! x (+ x colw))))
	    row
	    col-ws)
	   (set! y (- y rowh)))
	 matrix
	 row-hs))
      ;;
      ;; insert links
      ;;
      (for-each
       (lambda (node)
	 (let* (((c <node-cell>) (table-lookup basic-boxes (car node)))
		(links (gen-links c basic-boxes)))
	   (format #t "~s links: ~s\n" (car node) links)
	   (paste-from-extern links group $zero-size)))
       nodes)
      ;;
      (make-rect2 (make-point 18 18)
		  (make-size (+ 36 (apply + col-ws))
			     (+ 36 (apply + row-hs)))))))

(define (gen-cell-value (node <node-cell>)
			(node-index <symbol-table>)
			(cell-frame <rect>)
			cell)
  (dm "gen-cell-value: ~s in ~s" cell cell-frame)
  (cond
   ((pair? cell)
    (case (car cell)
      ((link)
       ;; a link following a specific winding path
       (let ((target (table-lookup node-index (cadr cell))))
	 (dm "  to ~s ~s using ~s" 
	     (name target) 
	     (node-frame target) 
	     (caddr cell))
	 (link-line cell-frame (node-frame target) (caddr cell))))
      ((quote)
       ;; do the value
       (let ((str (to-string (cadr cell))))
	 '(group)))))
   ;; a link to another object
   ((symbol? cell)
    (let ((target (table-lookup node-index cell)))
      (dm "  to ~s ~s" (name target) (node-frame target))
      (link-line cell-frame
		 (node-frame target)
		 (guess-link-line-winding cell-frame (node-frame target)))))
   (else
    ;; do the value
    (let ((pt (point+ (lower-right cell-frame) (make-size -3 4))))
      `(text string: ,(to-string cell)
	     alignment: right
	     font: (font "Times" "Roman" 10)
	     origin-x: ,(x pt)
	     origin-y: ,(y pt))))))

(define (new-ofig-doc file)
  (bind ((nodes matrix (with-input-from-file file
			 (lambda () 
			   (values (read) (read)))))
	 (doc (make-new-doc))
	 (view (car (document-views doc)))
	 (page (view-page view))
	 (bbox (load-ofig-nodes (page-contents page) nodes matrix))
	 (bbox (bounding-box (page-contents page))))
    ;
    (set-property! doc 'eps #t)
    (set-property! page 'page-bbox bbox)
    (set-page-size! page (size+ (size bbox) (make-size 36 36)))
    ;
    (print-page page 
		(pathname->string
		 (extension-related-path (string->file file) "eps")))
    (set-view-frame! view (make-rect2
			   (make-point 50 50)
			   (page-size (view-page view))))
    (reconfig-to-fit-window view)
    doc))

(define-interactive (tofu)
  (interactive)
  (open-document (new-ofig-doc "test.ofig")))

(define (main args)
  (let ((open-them #f))
    (let loop ((a args)
	       (d '()))
      (if (null? a)
	  (if open-them
	      (with-client
	       (make-client (getenv "DISPLAY"))
	       (lambda ()
		 (for-each open-document d)
		 (with-module repl
		   (cmd-loop *self* "dvo[~d]=>"))))
	      (values))
	  (if (string=? (car a) "-i")
	      (begin
		(set! open-them #t)
		(loop (cdr a)))
	      (loop (cdr a) (cons (new-ofig-doc (car a)) d)))))))

(define (t)
  (main '("/u/donovan/rscheme/doc/using-docbook/figs/list3.ofig")))
