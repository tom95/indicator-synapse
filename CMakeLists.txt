# required for building via debhelper on xenial :(

cmake_minimum_required (VERSION 2.6)
cmake_policy (VERSION 2.6)

# Set the Title to use for the Indicator (May be used in future features)
set (INDICATORTITLE "Synapse")

# The description of what your Indicator is
set (INDICATORDESCRIPTION "Search Indicator")

# Projectname
project (synapse)

#########################################################
# Only alter stuff below if you know what you are doing #
#########################################################

# Configuration
include (GNUInstallDirs)
set (DATADIR "${CMAKE_INSTALL_FULL_LIBDIR}/wingpanel")
set (PKGDATADIR "${DATADIR}")
set (GETTEXT_PACKAGE "${CMAKE_PROJECT_NAME}-indicator")
set (VERSION "2.1.1")
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Configure file
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

# Comment this out to enable C compiler warnings
add_definitions (-w)

# Files
file (GLOB resources "${CMAKE_CURRENT_SOURCE_DIR}/data/*")

# Code
add_subdirectory (src)

# Uninstall target
configure_file(
    "${CMAKE_SOURCE_DIR}/cmake/Uninstall.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/Uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/Uninstall.cmake)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.tom95.indicator-synapse.appdata.xml DESTINATION ${CMAKE_INSTALL_PREFIX}/share/metainfo/)

install (FILES data/icons/com.github.tom95.indicator-synapse.svg DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/icons/hicolor/)
install (FILES data/icons/16/com.github.tom95.indicator-synapse.png DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/icons/hicolor/16x16/apps/)
install (FILES data/icons/24/com.github.tom95.indicator-synapse.png DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/icons/hicolor/24x24/apps/)
install (FILES data/icons/32/com.github.tom95.indicator-synapse.png DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/icons/hicolor/32x32/apps/)
install (FILES data/icons/48/com.github.tom95.indicator-synapse.png DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/icons/hicolor/48x48/apps/)
install (FILES data/icons/com.github.tom95.indicator-synapse.svg DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/icons/hicolor/64x64/apps/)
install (FILES data/icons/com.github.tom95.indicator-synapse.svg DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/icons/hicolor/128x128/apps/)
