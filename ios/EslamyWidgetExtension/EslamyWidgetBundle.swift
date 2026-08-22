import WidgetKit
import SwiftUI

@main
struct EslamyWidgetBundle: WidgetBundle {
    var body: some Widget {
        EslamyWidget()
        EslamyPrayerLockWidget()
        EslamyAyahLockWidget()
        EslamyDuaLockWidget()
        EslamyHijriLockWidget()
    }
}
