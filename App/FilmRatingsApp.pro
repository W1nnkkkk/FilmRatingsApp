QT += quick core gui network

C++=17
# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        basemodel.cpp \
        filtercontroller.cpp \
        main.cpp \
        requester.cpp \
        reviewmodel.cpp

RESOURCES += qml.qrc \
    icons.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =
QMAKEPATH=/usr/lib/qt5/bin
PATH=$QMAKEPATH:$PATH

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# CONFIG += console
# CONFIG += debug

include(./src/PullToRefreshHandler.pri)

HEADERS += \
    basemodel.h \
    filtercontroller.h \
    requester.h \
    reviewmodel.h
