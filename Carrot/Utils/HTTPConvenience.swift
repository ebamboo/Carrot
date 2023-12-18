//
//  Created by ebamboo on 2023/12/15.
//
// 根据具体的项目约定，解析返回数据
//

import Foundation
import Alamofire

struct Payload {
    let headers: [String: Any]?
    let data: Any?
}

extension HTTP {
    
    /// data request -- 回调
    @discardableResult static func request(
        _ request: HTTPRequest,
        completionHandler: @escaping (_ result: Result<Payload, HTTPError>) -> Void
    ) -> DataRequest {
        return dataRequest(request) { result in
            parseBody(result: result, completionHandler: completionHandler)
        }
    }
    
    /// upload request -- 回调
    @discardableResult static func upload(
        _ request: HTTPRequest,
        files: [UploadFileModel],
        progressHandler: @escaping (_ progress: Progress) -> Void = { _ in },
        completionHandler: @escaping (_ result: Result<Payload, HTTPError>) -> Void
    ) -> UploadRequest {
        return uploadRequest(request, files: files, progressHandler: progressHandler) { result in
            parseBody(result: result, completionHandler: completionHandler)
        }
    }
    
    /// download request -- 回调
    @discardableResult static func download(
        _ request: HTTPRequest,
        with resumeData: Data? = nil,
        to destination: DownloadDestination? = nil,
        progressHandler: @escaping (_ progress: Progress) -> Void = { _ in },
        completionHandler: @escaping (_ result: Result<Payload, HTTPError>) -> Void
    ) -> DownloadRequest {
        return downloadRequest(request, with: resumeData, to: destination, progressHandler: progressHandler) { result in
            parseBody(result: result, completionHandler: completionHandler)
        }
    }
    
}

extension HTTP {
    
    /// data request -- async/await
    static func request(_ request: HTTPRequest) async throws -> Payload {
        try await withCheckedThrowingContinuation({ continuation in
            HTTP.request(request) { result in
                switch result {
                case .success(let payload):
                    continuation.resume(returning: payload)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
    /// upload request -- async/await
    static func upload(
        _ request: HTTPRequest,
        files: [UploadFileModel],
        progressHandler: @escaping (_ progress: Progress) -> Void = { _ in }
    ) async throws -> Payload {
        try await withCheckedThrowingContinuation({ continuation in
            HTTP.upload(request, files: files, progressHandler: progressHandler) { result in
                switch result {
                case .success(let payload):
                    continuation.resume(returning: payload)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
    /// download request -- async/await
    static func download(
        _ request: HTTPRequest,
        with resumeData: Data? = nil,
        to destination: DownloadDestination? = nil,
        progressHandler: @escaping (_ progress: Progress) -> Void = { _ in }
    ) async throws -> Payload {
        try await withCheckedThrowingContinuation({ continuation in
            HTTP.download(request, with: resumeData, to: destination, progressHandler: progressHandler) { result in
                switch result {
                case .success(let payload):
                    continuation.resume(returning: payload)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
}

private extension HTTP {
    
    /// 解析响应结果
    static func parseBody(result: Result<HTTPResponse, HTTPError>, completionHandler: @escaping (_ result: Result<Payload, HTTPError>) -> Void) {
        switch result {
        case .success(let info):
            guard
                let jsonObject = try? JSONSerialization.jsonObject(with: info.body, options: []) as? [String: Any],
                let success = jsonObject["success"] as? Bool else {
                completionHandler(.failure(.exceptionData))
                return
            }
            if success {
                completionHandler(.success(Payload(headers: info.headers, data: jsonObject["data"])))
            } else {
                let error = {
                    if let message = jsonObject["message"] as? String {
                        return HTTPError.error(message: message)
                    } else {
                        return HTTPError.noneMessage
                    }
                }()
                completionHandler(.failure(error))
            }
        case .failure(let error):
            completionHandler(.failure(error))
        }
    }
    
}
