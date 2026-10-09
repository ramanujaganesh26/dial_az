#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "networkreceiver.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Ethernet UDP Network Receiver backend instance
    NetworkReceiver networkReceiver;
    engine.rootContext()->setContextProperty("networkReceiver", &networkReceiver);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("HMI_Design", "Main");

    return QGuiApplication::exec();
}
