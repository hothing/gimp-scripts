(define (script-fu-selection-save-png image drawable)
	(define (filename-modify orig-name new-extension name-suffix)
		(let* ((buffer (vector "" "" "")))
			(if (re-match "^(.*)[.]([^.]+)$" orig-name buffer)
			(string-append 
				(substring orig-name 0 (- (car (vector-ref buffer 2)) 1)) 
				name-suffix
				"."
				new-extension)
			orig-name)
	))

	(gimp-context-push)
	(gimp-image-set-active-layer image drawable)
	(gimp-image-undo-group-start image)
	(gimp-edit-copy drawable)
	(let* ( (img2 (car (gimp-edit-paste-as-new)))
			(draw2 (car (gimp-image-get-active-drawable img2)))
			(fname (filename-modify	(car (gimp-image-get-filename image))
							"png" 
							(string-append "-S" (number->string draw2)))))
		;(gimp-message (string-append "Filename: " fname))
		(if (and (> img2 0) (> draw2 0))
			(begin 
				(file-png-save2 RUN-INTERACTIVE img2 draw2 
				fname fname 0 9 0 0 0 1 0 0 0)
				(gimp-image-delete img2))
			(gimp-message "Cannot create new image")
		)
	)
	(gimp-image-undo-group-end image)
	(gimp-displays-flush)
	(gimp-context-pop)
)

(script-fu-register "script-fu-selection-save-png"
	"Screenshot: save selection to PNG-file"
	"."
	"Pupkin <pupkin@example.com>"
	"Gehörn und Spitzbeine GmbH"
	"2010/10/6"
	"RGB*"
	SF-IMAGE      "Image"      0
	SF-DRAWABLE   "Drawable"   0
)

(script-fu-menu-register "script-fu-selection-save-png"
                         "<Image>/Filters/Screenshots"
)