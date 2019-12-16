(define (script-fu-save-layers-as-png image drawable)
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
	
	; get list of top-level layers
	(set! layers (cdr (gimp-image-get-layers image)))
	; get list of child levels
	
	(define layers-get-all-child (top-layers)
		; for-each layer do
		;   if [gimp-item-is-group layer] then 
		;      [set child-layers gimp-item-get-children]
		;      
		;   else [cons top-layers layer]
	)
	; (gimp-drawable-width layer)
    ; (gimp-drawable-height layer)
    ; (gimp-drawable-offsets layer)
	; (gimp-item-is-group layer)
	; (gimp-item-get-children layer)
	; (gimp-layer-get-name layer)
	; 
	(gimp-image-undo-group-end image)
	(gimp-displays-flush)
	(gimp-context-pop)
)

(script-fu-register "script-fu-save-layers-as-png"
	"Web: save layers to PNG-files"
	"."
	"Pum <barbos@inbox.ru>"
	"Handmade"
	"2017/11/18"
	"RGB*"
	SF-IMAGE      "Image"      0
	SF-DRAWABLE   "Drawable"   0
)

(script-fu-menu-register "script-fu-save-layers-as-png"
                         "<Image>/Filters/Web"
)