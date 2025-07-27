#include <auroraapp.h>
#include <QtQuick>

#include "pagefetcher.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.erhoof"));
    application->setApplicationName(QStringLiteral("AniLibre"));

    qmlRegisterType<PageFetcher>("ru.erhoof.pagefetcher", 1, 0, "PageFetcher");

    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/AniLibre.qml")));
    view->show();

    return application->exec();
}
