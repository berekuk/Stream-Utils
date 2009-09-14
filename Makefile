build:
	mkdir -p man
	pod2man bin/stream man/stream.1

test:
	perl -c bin/stream

install:
	mkdir -p $(DESTDIR)/usr/bin/
	cp bin/stream $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/usr/share/man/man1/
	cp man/stream.1 $(DESTDIR)/usr/share/man/man1/
	mkdir -p $(DESTDIR)/etc/bash_completion.d/
	cp bash_completion $(DESTDIR)/etc/bash_completion.d/stream

clean:
	rm -rf man
