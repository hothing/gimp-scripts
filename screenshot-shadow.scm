(define (script-fu-quick-shadow image drawable)
	(gimp-context-push)
	(gimp-image-set-active-layer image drawable)
	(gimp-image-undo-group-start image)

	; Вызов стандартной процедуры script-fu-drop-shadow
	(script-fu-drop-shadow image drawable 3 4 10 '(0 0 0) 40 TRUE)   

	(gimp-image-undo-group-end image)
	(gimp-displays-flush)
	(gimp-context-pop)
)

(script-fu-register "script-fu-quick-shadow"
	"Screenshot: shadow"
	"Do effect of shadow with aparmeters:
	OffsetX = 3,
	OffsetY = 4, 
	BlurRadius = 10,
	Color = Black, Transparency = 40%."
	"Pupkin <pupkin@example.com>"
	"Gehörn und Spitzbeine GmbH"
	"2010/10/6"
	"RGB*"
	SF-IMAGE      "Image"      0
	SF-DRAWABLE   "Drawable"   0
)

(script-fu-menu-register "script-fu-quick-shadow"
                         "<Image>/Filters/Screenshots"
)