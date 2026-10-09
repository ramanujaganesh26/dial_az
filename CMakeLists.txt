cmake_minimum_required(VERSION 3.16)

project(HMI_Design VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_QML_GENERATE_QMLLS_INI ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Network)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appHMI_Design
    main.cpp
    networkreceiver.cpp
    networkreceiver.h
)

qt_add_qml_module(appHMI_Design
    URI HMI_Design
    QML_FILES
        qml/Main.qml
        qml/AzimuthDial.qml
)

set_target_properties(appHMI_Design PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appHMI_Design
    PRIVATE
        Qt6::Quick
        Qt6::Network
)

install(TARGETS appHMI_Design
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
