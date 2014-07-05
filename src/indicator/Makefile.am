# vim: set ft=automake ts=8 sts=8 sw=8 :
include $(top_srcdir)/Makefile.common

synapselibdir = $(INDICATORDIR)
synapselib_LTLIBRARIES = libsynapse.la

VAPIDIR = $(top_srcdir)/vapi

libsynapse_la_VALAFLAGS = \
	--pkg dbus-glib-1 \
	--pkg gtk+-3.0 \
	--pkg gdk-x11-3.0 \
	--pkg gio-2.0 \
	--pkg gio-unix-2.0 \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg libnotify \
	--pkg clutter-gtk-1.0 \
	--pkg libwnck-3.0 \
	--pkg keybinder-3.0 \
	--vapidir $(top_builddir)/src/core \
	--pkg synapse-core \
	--vapidir $(top_builddir)/src/plugins \
	--pkg plugins \
	--vapidir $(VAPIDIR) \
	$(VAPIDIR)/indicator3-0.4.vapi \
	$(VAPIDIR)/config.vapi \
	$(NULL)

libsynapse_la_CFLAGS = \
	$(SYNAPSE_MODULES_CFLAGS) \
	-include config.h -w \
	-DWNCK_I_KNOW_THIS_IS_UNSTABLE \
	-I$(top_builddir)/src/core \
	-I$(top_builddir)/src/plugins \
	$(NULL)

libsynapse_la_LIBADD = \
	$(SYNAPSE_MODULES_LIBS) \
	$(top_builddir)/src/core/libsynapsecore.la \
	$(top_builddir)/src/plugins/libplugins.la \
	-lm \
	$(NULL)

libsynapse_la_LDFLAGS = \
	-avoid-version \
	-no-undefined \
	-no_static \
	-shared \
	$(NULL)

if HAVE_INDICATOR
libsynapse_la_VALAFLAGS += --pkg appindicator3-0.1 -D HAVE_INDICATOR
libsynapse_la_CFLAGS += $(APP_INDICATOR_CFLAGS)
libsynapse_la_LIBADD += $(APP_INDICATOR_LIBS)
endif

if HAVE_LIBREST
libsynapse_la_VALAFLAGS += -D HAVE_LIBREST
libsynapse_la_CFLAGS += $(REST_CFLAGS)
libsynapse_la_LIBADD += $(REST_LIBS)
endif

if HAVE_ZEITGEIST
libsynapse_la_VALAFLAGS += --pkg zeitgeist-2.0 -D HAVE_ZEITGEIST
libsynapse_la_CFLAGS += $(ZEITGEIST_CFLAGS)
libsynapse_la_LIBADD += $(ZEITGEIST_LIBS)
endif

libsynapse_la_VALASOURCES = \
	main.vala \
	match-item.vala \
	menu.vala \
	$(NULL)

GENERATED_C_FILES = $(libsynapse_la_VALASOURCES:.vala=.c)
libsynapse_la_SOURCES = \
	$(libsynapse_la_VALASOURCES:.vala=.c) \
	indicator-search.c \
	indicator-search.h \
	$(NULL)

# we can't let make handle this, otherwise tarballs won't support configure
# flags (ie --disable-indicator won't rebuild the Vala sources)

$(builddir)/libsynapse.h: libsynapse_la_vala.stamp
#libsynapse_la_vala.stamp: $(addprefix $(srcdir)/,$(libsynapse_la_VALASOURCES)) Makefile
libsynapse_la_vala.stamp: $(libsynapse_la_VALASOURCES) Makefile
	$(AM_V_VALA)$(VALAC) $(libsynapse_la_VALAFLAGS) $(VALAFLAGS) -C $(filter %.vala %.c,$^) -H libsynapse.h
	$(AM_V_at)touch $@

BUILT_SOURCES = libsynapse_la_vala.stamp $(builddir)/libsynapse.h

DISTCLEANFILES = $(GENERATED_C_FILES) libsynapse_la_vala.stamp $(builddir)/libsynapse.h
EXTRA_DIST = $(libsynapse_la_VALASOURCES)

# need to make sure the vala sources are rebuilt
dist-hook:
	rm -f $(addprefix $(distdir)/,$(GENERATED_C_FILES))
