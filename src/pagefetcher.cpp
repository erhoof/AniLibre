#include <QObject>
#include <QStandardPaths>
#include <QFileInfo>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

#include "pagefetcher.h"

PageFetcher::PageFetcher(QObject *parent) : QObject(parent) {
}

bool PageFetcher::isFavorite(const QString &id) {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/favorites.json";

    QFile file(fullPath);
    if (!file.exists()) {
        return false;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open file for reading:" << file.errorString();
        return false;
    }

    QByteArray jsonData = file.readAll();
    file.close();

    QJsonDocument jsonDoc(QJsonDocument::fromJson(jsonData));
    if (jsonDoc.isNull() || !jsonDoc.isArray()) {
        qWarning() << "Failed to create JSON doc or not an array.";
        return false;
    }

    QJsonArray jsonArray = jsonDoc.array();
    for(const QJsonValue &value : jsonArray) {
        QJsonObject jsonObject = value.toObject();
        if(jsonObject["id"].toString() == id)
            return true;
    }

    return false;
}

void PageFetcher::setFavorite(const QString &id, bool value, QString cover) {
    bool alreadyFavorite = isFavorite(id);
    if(value && alreadyFavorite) {
        qDebug() << id << "is already favorite";
        return;
    } else if(!value && !alreadyFavorite) {
        qDebug() << id << "already not favorite";
        return;
    }

    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/favorites.json";

    QFile file(fullPath);
    QJsonDocument jsonDoc;
    if (file.open(QIODevice::ReadOnly)) {
        QByteArray jsonData = file.readAll();
        file.close();

        jsonDoc = QJsonDocument::fromJson(jsonData);
    }

    QJsonArray finalArray;
    if(!jsonDoc.isArray()) {
        if(!value) {
            return;
        }

        QJsonObject jsonObject;
        jsonObject["id"] = id;
        jsonObject["cover"] = cover;
        finalArray.append(jsonObject);
    } else {
        if(value) {
            finalArray = jsonDoc.array();

            QJsonObject jsonObject;
            jsonObject["id"] = id;
            jsonObject["cover"] = cover;
            finalArray.append(jsonObject);
        } else {
            foreach (const QJsonValue &value, jsonDoc.array()) {
                QJsonObject jsonObject = value.toObject();
                if(jsonObject["id"] == id) {
                    continue;
                }

                finalArray.append(jsonObject);
            }
        }
    }

    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Could not open output file for writing:" << file.errorString();
        return;
    }

    QJsonDocument filteredDoc(finalArray);
    file.write(filteredDoc.toJson());
    file.close();

    qDebug() << "Updated favorites file";
}

QJsonArray PageFetcher::getFavorites() {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/favorites.json";

    QFile file(fullPath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open file for reading:" << file.errorString();
        return QJsonArray();
    }

    QByteArray jsonData = file.readAll();
    file.close();

    QJsonDocument jsonDoc(QJsonDocument::fromJson(jsonData));
    if (jsonDoc.isNull() || !jsonDoc.isArray()) {
        qWarning() << "Failed to create JSON doc or not an array.";
        return QJsonArray();
    }

    return jsonDoc.array();
}

QJsonObject PageFetcher::getWatchStatus(const QString &id) {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/status-" + id + ".json";

    QFile file(fullPath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open file for reading:" << file.errorString();
        return QJsonObject();
    }

    QByteArray jsonData = file.readAll();
    file.close();

    QJsonDocument jsonDoc(QJsonDocument::fromJson(jsonData));
    return jsonDoc.object();
}

void PageFetcher::setWatchStatus(const QString &id, const QString &episode) {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/status-" + id + ".json";

    QFile file(fullPath);
    QJsonDocument jsonDoc;
    if (file.open(QIODevice::ReadOnly)) {
        QByteArray jsonData = file.readAll();
        file.close();

        jsonDoc = QJsonDocument::fromJson(jsonData);
    }

    QJsonObject jsonObject;
    jsonObject["id"] = id;
    jsonObject["episode"] = episode;

    QJsonObject rootObject = jsonDoc.object();
    rootObject["status"] = jsonObject;

    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Could not open output file for writing:" << file.errorString();
        return;
    }

    file.write(QJsonDocument(rootObject).toJson());
    file.close();
}
