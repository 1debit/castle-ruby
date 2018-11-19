class ChimeCastle::Error < Exception; end

class ChimeCastle::RequestError < ChimeCastle::Error; end
class ChimeCastle::SecurityError < ChimeCastle::Error; end
class ChimeCastle::ConfigurationError < ChimeCastle::Error; end

class ChimeCastle::ApiError < ChimeCastle::Error; end

class ChimeCastle::BadRequestError < ChimeCastle::ApiError; end
class ChimeCastle::ForbiddenError < ChimeCastle::ApiError; end
class ChimeCastle::NotFoundError < ChimeCastle::ApiError; end
class ChimeCastle::UserUnauthorizedError < ChimeCastle::ApiError; end
class ChimeCastle::InvalidParametersError < ChimeCastle::ApiError; end

class ChimeCastle::UnauthorizedError < ChimeCastle::ApiError; end
