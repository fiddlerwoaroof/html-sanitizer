# (insert clever name here)

A whitelist-based cleaner for html5 in Common Lisp.  It removes any
elements or attributes that don't match a whitelist and then dumps the
result as a string.  In order to deal with Microsoft conditionals, we
also strip out all the comments.  We depend on
[plump](https://github.com/Shinmera/plump) to handle html parsing, but
we extend it so with a HTML-compatible serialization mode that
prevents certain elements from self-closing.

Enhancements and security fixes welcome.
