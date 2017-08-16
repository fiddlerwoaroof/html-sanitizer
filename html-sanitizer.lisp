(in-package :html-sanitizer)

(defparameter *serialization-mode* :xml)
(defparameter +plump-dont-self-close-tags+ '("span" "div" "iframe" "script"))  ; insert more tags if needed

(defmethod plump:serialize-object :around ((node plump:element))
  (let ((tag-name (plump:tag-name node)))
    (if (and (eq *serialization-mode* :html)
             (= 0 (length (plump:children node)))
             (member tag-name +plump-dont-self-close-tags+ :test #'string-equal))
        (progn
          (format plump:*stream* "<~A" tag-name)
          (plump:serialize (plump:attributes node) plump:*stream*)
          (format plump:*stream* "></~A>" tag-name))
        (call-next-method node))))

(defparameter +safe-tags+
  (list "a" "abbr" "acronym" "address" "area" "article" "aside"
        "audio" "b" "bdi" "bdo" "big" "blink" "blockquote" "body" "br"
        "caption" "center" "cite" "code" "col" "colgroup" "content"
        "data" "datalist" "dd" "decorator" "del" "details" "dfn" "dir"
        "div" "dl" "dt" "element" "em" "fieldset" "figcaption"
        "figure" "font" "footer" "form" "h1" "h2" "h3" "h4" "h5" "h6"
        "head" "header" "hgroup" "hr" "html" "i" "img" "ins" "kbd"
        "label" "legend" "li" "main" "map" "mark" "marquee" "menu"
        "menuitem" "meter" "nav" "nobr" "ol" "optgroup" "option"
        "output" "p" "pre" "progress" "q" "rp" "rt" "ruby" "s" "samp"
        "section" "select" "shadow" "small" "source" "spacer" "span"
        "strike" "strong" "sub" "summary" "sup" "table" "tbody" "td"
        "template" "textarea" "tfoot" "th" "thead" "time" "tr" "track"
        "tt" "u" "ul" "var" "video" "wbr"))


(defparameter +safe-attrs+
  (list "accept" "action" "align" "alt" "autocomplete" "background"
        "bgcolor" "border" "cellpadding" "cellspacing" "checked" "cite"
        "class" "clear" "color" "cols" "colspan" "coords" "datetime"
        "default" "dir" "disabled" "download" "enctype" "face" "for"
        "headers" "height" "hidden" "high" "href" "hreflang" "id"
        "ismap" "label" "lang" "list" "loop" "low" "max" "maxlength"
        "media" "method" "min" "multiple" "name" "noshade" "novalidate"
        "nowrap" "open" "optimum" "pattern" "placeholder" "poster"
        "preload" "pubdate" "radiogroup" "readonly" "rel" "required"
        "rev" "reversed" "role" "rows" "rowspan" "spellcheck" "scope"
        "selected" "shape" "size" "span" "srclang" "start" "src" "step"
        "summary" "tabindex" "title" "type" "usemap" "valign" "value"
        "width" "xmlns"))

(defparameter *comment-mode* :strip
  ;;TODO: strip-conditional to only strip conditional
  ;;      comments (e.g. <!--[if ...]>...<![endif]-->)
  )

(defgeneric sanitize-node (node)
  (:documentation "")
  (:method (node)
    node)

  (:method ((node plump:comment))
    (when (plump:parent node)
      (plump:remove-child node)))

  (:method :after ((node plump:nesting-node))
    (map nil #'sanitize-node
        (plump:children node)))

  (:method ((node plump:element))
    (if (member (plump:tag-name node)
                +safe-tags+
                :test 'equalp)
        (progn
          (loop for attr being the hash-keys in (plump:attributes node)
             unless (member attr +safe-attrs+ :test 'equalp) do
               (plump:remove-attribute node attr))
          node)
        (when (plump:parent node)
          (plump:remove-child node)))))

(defun sanitize (html)
  (let ((result (plump:parse html))
        (*serialization-mode* :html))
    (sanitize-node result)
    (plump:serialize result nil)))

(defpackage :html-sanitizer.test
  (:use :cl :fiveam))
(in-package :html-sanitizer.test)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (import 'html-sanitizer::sanitize))

(def-suite :html-sanitizer)
(in-suite :html-sanitizer)

(test removes-script-tags
  (is (equal "<div></div>"
             (sanitize "<div><script></script></div>"))))

(test removes-style-tags
  (is (equal "<div></div>"
             (sanitize "<div><style></style></div>"))))

(test removes-style-attrs
  (is (equal "<div></div>"
             (sanitize "<div style=\"a: 1\"></div>"))))

(test removes-comments
  (is (equal ""
             (sanitize "<!-- -->"))))
