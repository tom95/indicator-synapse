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

/* GStuff */
#include <glib-object.h>
#include <gio/gio.h>

#include "indicator-search.h"
#include "libsynapse.h"

#define ICON "edit-find"

struct _IndicatorSearchPrivate
{
  GtkMenu   *menu;

  Main     *main;
  GtkLabel *label;
  GtkImage *status_image;
  gchar    *accessible_desc;
};


/* LCOV_EXCL_START */
INDICATOR_SET_VERSION
INDICATOR_SET_TYPE (INDICATOR_SEARCH_TYPE)
/* LCOV_EXCL_STOP */

/* Prototypes */
static void             indicator_search_dispose         (GObject *object);
static void             indicator_search_finalize        (GObject *object);

static GtkLabel*        get_label                       (IndicatorObject * io);
static GtkImage*        get_image                       (IndicatorObject * io);
static GtkMenu*         get_menu                        (IndicatorObject * io);
static const gchar*     get_accessible_desc             (IndicatorObject * io);
static const gchar*     get_name_hint                   (IndicatorObject * io);


static void             set_accessible_desc             (IndicatorSearch * self, const gchar * desc);


/* LCOV_EXCL_START */
G_DEFINE_TYPE (IndicatorSearch, indicator_search, INDICATOR_OBJECT_TYPE);
/* LCOV_EXCL_STOP */

static void
indicator_search_class_init (IndicatorSearchClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  IndicatorObjectClass *io_class = INDICATOR_OBJECT_CLASS (klass);

  g_type_class_add_private (klass, sizeof (IndicatorSearchPrivate));

  object_class->dispose = indicator_search_dispose;
  object_class->finalize = indicator_search_finalize;

  io_class->get_label = get_label;
  io_class->get_image = get_image;
  io_class->get_menu = get_menu;
  io_class->get_accessible_desc = get_accessible_desc;
  io_class->get_name_hint = get_name_hint;
}

static void
indicator_search_init (IndicatorSearch *self)
{
  IndicatorSearchPrivate * priv;
  GIcon *gicon;

  priv = G_TYPE_INSTANCE_GET_PRIVATE (self, INDICATOR_SEARCH_TYPE, IndicatorSearchPrivate);

  priv->main = main_new ();
  priv->accessible_desc = NULL;
  priv->menu = main_get_menu (priv->main);

  self->priv = priv;
  priv->label = GTK_LABEL (gtk_label_new (""));
  g_object_ref_sink (priv->label);

  gicon = g_themed_icon_new (ICON);
  priv->status_image = GTK_IMAGE (gtk_image_new_from_gicon (gicon, GTK_ICON_SIZE_LARGE_TOOLBAR));
  g_object_ref_sink (priv->status_image);
  g_object_unref (gicon);
  gtk_widget_show (GTK_WIDGET (priv->status_image));

  set_accessible_desc (self, "Search");
}

static void
indicator_search_dispose (GObject *object)
{
  IndicatorSearch *self = INDICATOR_SEARCH(object);
  IndicatorSearchPrivate * priv = self->priv;

  g_clear_object (&priv->label);
  g_clear_object (&priv->status_image);

  G_OBJECT_CLASS (indicator_search_parent_class)->dispose (object);
}

static void
indicator_search_finalize (GObject *object)
{
  IndicatorSearch *self = INDICATOR_SEARCH(object);
  IndicatorSearchPrivate * priv = self->priv;

  g_free (priv->accessible_desc);

  G_OBJECT_CLASS (indicator_search_parent_class)->finalize (object);
}

static void
set_accessible_desc (IndicatorSearch *self, const gchar *desc)
{
  if (desc && *desc)
  {
    /* update our copy of the string */
    char * oldval = self->priv->accessible_desc;
    self->priv->accessible_desc = g_strdup (desc);

    /* ensure that the entries are using self's accessible description */
    GList * l;
    GList * entries = indicator_object_get_entries(INDICATOR_OBJECT(self));
    for (l=entries; l!=NULL; l=l->next) {
      if (((IndicatorObjectEntry*)l->data)->accessible_desc != desc) {
         ((IndicatorObjectEntry*)l->data)->accessible_desc = desc;
         g_signal_emit (self, INDICATOR_OBJECT_SIGNAL_ACCESSIBLE_DESC_UPDATE_ID, 0, l->data);
	  }
	}

    /* cleanup */
    g_list_free (entries);
    g_free (oldval);
  }
}

static GtkLabel *
get_label (IndicatorObject *io)
{
  IndicatorSearch *self = INDICATOR_SEARCH (io);
  IndicatorSearchPrivate * priv = self->priv;

  return priv->label;
}

static GtkImage *
get_image (IndicatorObject *io)
{
  IndicatorSearch *self = INDICATOR_SEARCH (io);
  IndicatorSearchPrivate * priv = self->priv;

  return priv->status_image;
}

static GtkMenu *
get_menu (IndicatorObject *io)
{
  IndicatorSearch *self = INDICATOR_SEARCH (io);

  return GTK_MENU (self->priv->menu);
}

static const gchar *
get_accessible_desc (IndicatorObject *io)
{
  IndicatorSearch *self = INDICATOR_SEARCH (io);

  return self->priv->accessible_desc;
}

static const gchar *
get_name_hint (IndicatorObject *io)
{
  return "sadlifj";
}
