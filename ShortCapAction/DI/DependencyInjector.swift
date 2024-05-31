import Foundation
import Swinject
import Domain
import Data
import Core

protocol DependencyAssemlable {
    
    func assemble(_ assemblies: [Assembly])
    func register<T>(_ service: T.Type, _ object: T)
}

protocol DependencyResolvable {
    
    func resolve<T>(_ service: T.Type) -> T
}

typealias DependencyInjector = DependencyAssemlable & DependencyResolvable


class DefaultDependencyInjector: DependencyInjector {

    static let shared: DefaultDependencyInjector = .init()
    
    private init() { 
        
        assemble([
            DataAssembly(),
            DomainAssembly(),
            PresentationAssembly(),
        ])
        
    }
    
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

public struct DataAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(NetworkService.self) { _ in
            DefaultNetworkService(
                config: ApiDataNetworkConfig.default,
                sessionManager: DefaultNetworkSessionManager()
            )
        }
        
        container.register(DataTransferService.self) { resolver in

            DefaultDataTransferService(
                with: resolver.resolve(NetworkService.self)!
            )
        }
        
        container.register(ConvertUrlRepository.self) { resolver in
            DefaultConvertUrlRepository(
                dataTransferService: resolver.resolve(DataTransferService.self)!
            )
        }
        
        container.register(SaveVideoIdentityRepository.self) { _ in
            DefaultSaveVideoIdentityRepository(
                videoIdentityStorage: CoreDataVideoIdentityStorage(coreDataStorage: .shared)
            )
        }
        
        container.register(GetAuthTokenRepository.self) { resolver in
            
            DefaultGetAuthTokenRepository(
                dataTransferService: resolver.resolve(DataTransferService.self)!
            )
        }
    }
}

public struct DomainAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(SaveVideoIndentityUserCase.self) { resolver in
            
            DefualtSaveVideoIndentityUseCase(
                saveVideoIdentityRepository: resolver.resolve(SaveVideoIdentityRepository.self)!
            )
        }
        
        container.register(ConvertUrlToVideoCodeUseCase.self) { resolver in
            
            DefaultConvertUrlToVideoCodeUseCase(
                convertUrlRepository: resolver.resolve(ConvertUrlRepository.self)!
            )
        }
        
        container.register(UrlValidationUseCase.self) { _ in
            
            DefaultUrlValidationUseCase()
        }
    }
}

public struct PresentationAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(ActionViewModel.self) { resolver in
            
            ActionViewModel(
                saveVideoIndentityUserCase: resolver.resolve(SaveVideoIndentityUserCase.self)!,
                convertUrlUseCase: resolver.resolve(ConvertUrlToVideoCodeUseCase.self)!,
                urlValidationUseCase: resolver.resolve(UrlValidationUseCase.self)!,
                authTokenRepository: resolver.resolve(GetAuthTokenRepository.self)!
            )
        }
    }
}
