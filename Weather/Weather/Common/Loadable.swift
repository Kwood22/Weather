import Foundation

enum Loadable<T,D> {
    case loading
    case loaded(T)
    case error(D)
}
