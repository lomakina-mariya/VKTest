
import Foundation

protocol HeightCaching {
    mutating func setHeight(_ height: CGFloat?)
    mutating func clearHeightCache()
    func getCachedHeight() -> CGFloat?
}
