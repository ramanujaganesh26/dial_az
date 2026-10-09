#include "networkreceiver.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QDebug>

NetworkReceiver::NetworkReceiver(QObject *parent)
    : QObject(parent)
    , m_udpSocket(new QUdpSocket(this))
    , m_azimuth(0.0)
    , m_targetAzimuth(45.0)
    , m_port(5000)
    , m_isListening(false)
    , m_lastSenderIp("N/A")
    , m_lastPacketRaw("None")
    , m_packetCount(0)
{
    connect(m_udpSocket, &QUdpSocket::readyRead, this, &NetworkReceiver::processPendingDatagrams);
    startListening(m_port);
}

NetworkReceiver::~NetworkReceiver()
{
    stopListening();
}

void NetworkReceiver::setAzimuth(double val)
{
    double norm = std::fmod(val, 360.0);
    if (norm < 0) norm += 360.0;

    if (!qFuzzyCompare(m_azimuth, norm)) {
        m_azimuth = norm;
        emit azimuthChanged(m_azimuth);
    }
}

void NetworkReceiver::setTargetAzimuth(double val)
{
    double norm = std::fmod(val, 360.0);
    if (norm < 0) norm += 360.0;

    if (!qFuzzyCompare(m_targetAzimuth, norm)) {
        m_targetAzimuth = norm;
        emit targetAzimuthChanged(m_targetAzimuth);
    }
}

void NetworkReceiver::setPort(int p)
{
    if (m_port != p && p > 0 && p <= 65535) {
        m_port = p;
        emit portChanged(m_port);
        if (m_isListening) startListening(m_port);
    }
}

bool NetworkReceiver::startListening(int port)
{
    stopListening();
    m_port = port;

    bool bound = m_udpSocket->bind(QHostAddress::AnyIPv4, m_port, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint);
    m_isListening = bound;
    emit isListeningChanged(m_isListening);
    return bound;
}

void NetworkReceiver::stopListening()
{
    if (m_udpSocket->isOpen()) m_udpSocket->close();
    if (m_isListening) {
        m_isListening = false;
        emit isListeningChanged(false);
    }
}

void NetworkReceiver::processPendingDatagrams()
{
    while (m_udpSocket->hasPendingDatagrams()) {
        QNetworkDatagram datagram = m_udpSocket->receiveDatagram();
        parsePayload(datagram.data(), datagram.senderAddress().toString());
    }
}

void NetworkReceiver::parsePayload(const QByteArray &data, const QString &senderIp)
{
    m_packetCount++;
    m_lastSenderIp = senderIp;
    m_lastPacketRaw = QString::fromUtf8(data).trimmed();

    emit packetCountChanged(m_packetCount);
    emit lastSenderIpChanged(m_lastSenderIp);
    emit lastPacketRawChanged(m_lastPacketRaw);

    // 1. JSON Format Parser: {"azimuth": 184.5, "target": 45.0}
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isObject()) {
        QJsonObject obj = doc.object();
        for (const QString &key : {"azimuth", "az", "degree", "heading", "angle", "val"}) {
            if (obj.contains(key)) { setAzimuth(obj[key].toDouble()); break; }
        }
        for (const QString &key : {"target", "targetAzimuth", "tgt", "bug"}) {
            if (obj.contains(key)) { setTargetAzimuth(obj[key].toDouble()); break; }
        }
        return;
    }

    // 2. Text / CSV Format Parser: "184.5" or "184.5, 45.0"
    QString str = m_lastPacketRaw;
    if (str.contains(",")) {
        QStringList parts = str.split(",");
        bool ok = false;
        double az = parts[0].trimmed().toDouble(&ok);
        if (ok) setAzimuth(az);
        if (parts.size() > 1) {
            double tgt = parts[1].trimmed().toDouble(&ok);
            if (ok) setTargetAzimuth(tgt);
        }
        return;
    }

    // Plain text number: "184.5"
    bool ok = false;
    double val = str.toDouble(&ok);
    if (ok) {
        setAzimuth(val);
        return;
    }

    // 3. Binary Format Parser: 4-byte float or 8-byte float pair
    if (data.size() == 4) {
        float fVal;
        std::memcpy(&fVal, data.constData(), 4);
        setAzimuth(static_cast<double>(fVal));
    } else if (data.size() == 8) {
        float f1, f2;
        std::memcpy(&f1, data.constData(), 4);
        std::memcpy(&f2, data.constData() + 4, 4);
        setAzimuth(static_cast<double>(f1));
        setTargetAzimuth(static_cast<double>(f2));
    }
}

void NetworkReceiver::sendSimulatedPacket(double degree, double target)
{
    QUdpSocket sender;
    QByteArray payload = QString("{\"azimuth\": %1, \"target\": %2}")
                             .arg(degree, 0, 'f', 1)
                             .arg(target >= 0 ? target : m_targetAzimuth, 0, 'f', 1)
                             .toUtf8();
    sender.writeDatagram(payload, QHostAddress::LocalHost, static_cast<quint16>(m_port));
}
