import GiniBankAPILibrary

public enum APIEnvironment: String {
    case production = "Prod"
    case stage = "Stage"

    public var api: APIDomain {
        switch self {
        case .production:
            return .default
        case .stage:
            return .custom(domain: "pay-api.pia.stage.gini.net", tokenSource: nil)
        }
    }

    public var userApi: UserDomain {
        switch self {
        case .production:
            return .default
        case .stage:
            return .custom(domain: "user.stage.gini.net")
        }
    }
}
