
import Foundation

protocol HeightCaching {
    mutating func setHeight(_ height: CGFloat?)
    func getCachedHeight() -> CGFloat?
}
