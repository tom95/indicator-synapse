/*
An indicator to search related information in the menubar.

Copyright 2011 Canonical Ltd.

Authors:
    Javier Jardon <javier.jardon@codethink.co.uk>

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License version 3, as published 
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranties of
MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/* Gtk required */
#include <gtk/gtk.h>

/* parent class */
#include <libindicator/indicator.h>
#include <libindicator/indicator-object.h>

G_BEGIN_DECLS

#define INDICATOR_SEARCH_TYPE            (indicator_search_get_type ())
#define INDICATOR_SEARCH(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), INDICATOR_SEARCH_TYPE, IndicatorSearch))
#define INDICATOR_SEARCH_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), INDICATOR_SEARCH_TYPE, IndicatorSearchClass))
#define IS_INDICATOR_SEARCH(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), INDICATOR_SEARCH_TYPE))
#define IS_INDICATOR_SEARCH_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), INDICATOR_SEARCH_TYPE))
#define INDICATOR_SEARCH_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), INDICATOR_SEARCH_TYPE, IndicatorSearchClass))

typedef struct _IndicatorSearch         IndicatorSearch;
typedef struct _IndicatorSearchClass    IndicatorSearchClass;
typedef struct _IndicatorSearchPrivate  IndicatorSearchPrivate;

struct _IndicatorSearchClass
{
  IndicatorObjectClass parent_class;
};

struct _IndicatorSearch
{
  IndicatorObject parent_instance;
  IndicatorSearchPrivate * priv;
};

GType indicator_search_get_type (void) G_GNUC_CONST;

G_END_DECLS
