;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Package: ASDF-USER -*-
(in-package :asdf-user)

(defsystem :html-sanitizer 
  :description ""
  :author "Ed L <edward@elangley.org>"
  :license "MIT"
  :depends-on (:alexandria
               :uiop
               :serapeum
               :plump
               :lquery
               :fiveam)
  :serial t
  :components ((:file "package")
               (:file "html-sanitizer")))
