#ifndef PAGEFETCHER_H
#define PAGEFETCHER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>

class PageFetcher : public QObject
{
    Q_OBJECT
public:
    explicit PageFetcher(QObject *parent = nullptr);

    Q_INVOKABLE bool isFavorite(const QString &id);
    Q_INVOKABLE void setFavorite(const QString &id, bool value, QString cover = "");
    Q_INVOKABLE QJsonArray getFavorites();

    Q_INVOKABLE QJsonObject getWatchStatus(const QString &id);
    Q_INVOKABLE void setWatchStatus(const QString &id, const QString &episode);

signals:

};

#endif // PAGEFETCHER_H
