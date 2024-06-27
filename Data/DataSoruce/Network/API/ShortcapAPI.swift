import Foundation
import Alamofire
import JunimoFire
import KeychainAccess

public class ShortcapAPI {
    
    let configuration: NetworkConfigurable
    let credential: AuthCrendentialable
    let tokenInterceptor: TokenInterceptor
    
    public init(
        configuration: NetworkConfigurable,
        credential: AuthCrendentialable
    ) {
        self.configuration = configuration
        self.credential = credential
        self.tokenInterceptor = TokenInterceptor(
            configuration: configuration,
            credential: credential
        )
    }
}
