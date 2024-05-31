import Foundation
import Swinject

protocol DependencyAssemlable {
    
    func assemble(_ assemblies: [Assembly])
    func register<T>(_ service: T.Type, _ object: T)
}

protocol DependencyResolvable {
    
    func resolve<T>(_ service: T.Type) -> T
}

typealias DependencyInjector = DependencyAssemlable & DependencyResolvable


class DefaultDependencyInjector: DependencyInjector {

    static let `default`: DefaultDependencyInjector = .init()
    
    private init() { }
    
    let container = Container()
    
    func assemble(_ assemblies: [Swinject.Assembly]) {
        assemblies.forEach {
            $0.assemble(container: container)
        }
    }
    
    func register<T>(_ service: T.Type, _ object: T) {
        
        container.register(service) { _ in object }
    }
    
    func resolve<T>(_ service: T.Type) -> T {
        
        container.resolve(service)!
    }
}
