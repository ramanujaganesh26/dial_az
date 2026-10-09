#ifndef NETWORKRECEIVER_H
#define NETWORKRECEIVER_H

#include <QObject>
#include <QUdpSocket>
#include <QNetworkDatagram>
#include <QtQml/qqmlregistration.h>

class NetworkReceiver : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(double azimuth READ azimuth WRITE setAzimuth NOTIFY azimuthChanged)
    Q_PROPERTY(double targetAzimuth READ targetAzimuth WRITE setTargetAzimuth NOTIFY targetAzimuthChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(bool isListening READ isListening NOTIFY isListeningChanged)
    Q_PROPERTY(QString lastSenderIp READ lastSenderIp NOTIFY lastSenderIpChanged)
    Q_PROPERTY(QString lastPacketRaw READ lastPacketRaw NOTIFY lastPacketRawChanged)
    Q_PROPERTY(int packetCount READ packetCount NOTIFY packetCountChanged)

public:
    explicit NetworkReceiver(QObject *parent = nullptr);
    ~NetworkReceiver();

    double azimuth() const { return m_azimuth; }
    void setAzimuth(double val);

    double targetAzimuth() const { return m_targetAzimuth; }
    void setTargetAzimuth(double val);

    int port() const { return m_port; }
    void setPort(int p);

    bool isListening() const { return m_isListening; }
    QString lastSenderIp() const { return m_lastSenderIp; }
    QString lastPacketRaw() const { return m_lastPacketRaw; }
    int packetCount() const { return m_packetCount; }

    Q_INVOKABLE bool startListening(int port = 5000);
    Q_INVOKABLE void stopListening();
    Q_INVOKABLE void sendSimulatedPacket(double degree, double target = -1.0);

signals:
    void azimuthChanged(double val);
    void targetAzimuthChanged(double val);
    void portChanged(int p);
    void isListeningChanged(bool listening);
    void lastSenderIpChanged(const QString &ip);
    void lastPacketRawChanged(const QString &raw);
    void packetCountChanged(int count);

private slots:
    void processPendingDatagrams();

private:
    void parsePayload(const QByteArray &data, const QString &senderIp);

    QUdpSocket *m_udpSocket;
    double m_azimuth;
    double m_targetAzimuth;
    int m_port;
    bool m_isListening;
    QString m_lastSenderIp;
    QString m_lastPacketRaw;
    int m_packetCount;
};

#endif // NETWORKRECEIVER_H
